from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path
from typing import Any, Iterable

import chess
import chess.engine


MOVE_LIST_KEYS = ("moves", "halfMoves", "plies")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Evaluate ChessNotation JSON games with local Stockfish."
    )

    parser.add_argument(
        "--input",
        required=True,
        help="Input JSON file or directory containing JSON files.",
    )

    parser.add_argument(
        "--output",
        required=True,
        help="Output JSON file or directory.",
    )

    parser.add_argument(
        "--stockfish",
        default="stockfish",
        help="Path to Stockfish binary. Defaults to resolving `stockfish` from PATH.",
    )

    parser.add_argument(
        "--depth",
        type=int,
        default=10,
        help="Stockfish analysis depth. Default: 10.",
    )

    parser.add_argument(
        "--threads",
        type=int,
        default=1,
        help="Stockfish thread count. Default: 1.",
    )

    parser.add_argument(
        "--hash-mb",
        type=int,
        default=64,
        help="Stockfish hash size in MB. Default: 64.",
    )

    parser.add_argument(
        "--force",
        action="store_true",
        help="Recompute existing engineEvaluation entries.",
    )

    return parser.parse_args()


def load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", encoding="utf-8") as file:
        json.dump(data, file, ensure_ascii=False, indent=2)
        file.write("\n")


def find_move_list(game: dict[str, Any]) -> list[dict[str, Any]]:
    for key in MOVE_LIST_KEYS:
        value = game.get(key)
        if isinstance(value, list):
            return value

    raise ValueError(
        f"Could not find move list. Expected one of these keys: {', '.join(MOVE_LIST_KEYS)}"
    )


def get_games_container(data: Any) -> tuple[list[dict[str, Any]], str]:
    """
    Supports:
    1. Single game:
       { "title": "...", "moves": [...] }

    2. Game collection:
       { "games": [ { "moves": [...] } ] }

    3. Raw list:
       [ { "moves": [...] }, { "moves": [...] } ]
    """

    if isinstance(data, dict) and isinstance(data.get("games"), list):
        return data["games"], "games"

    if isinstance(data, dict):
        # Single game file.
        find_move_list(data)
        return [data], "single"

    if isinstance(data, list):
        return data, "list"

    raise ValueError("Unsupported JSON structure.")


def starting_fen_for_game(game: dict[str, Any]) -> str:
    return (
        game.get("initialFen")
        or game.get("startFen")
        or game.get("startingFen")
        or chess.STARTING_FEN
    )


def clean_san(value: str) -> str:
    """
    Handles plain SAN like:
      e4
      Nf3
      O-O

    Also tolerates accidental move-number prefixes:
      1. e4
      23...Qh4+
    """

    value = value.strip()
    value = re.sub(r"^\d+\.(\.\.)?", "", value).strip()
    return value


def move_to_board_position(board: chess.Board, move_entry: dict[str, Any]) -> chess.Board:
    """
    Advances the board to the position after this move.

    Preference order:
    1. uci
    2. san
    3. notation
    4. move
    5. fenAfter / afterFen
    """

    next_board = board.copy(stack=False)

    uci = move_entry.get("uci")
    if isinstance(uci, str) and uci.strip():
        next_board.push_uci(uci.strip())
        return next_board

    for san_key in ("san", "notation", "move"):
        san = move_entry.get(san_key)
        if isinstance(san, str) and san.strip():
            next_board.push_san(clean_san(san))
            return next_board

    for fen_key in ("fenAfter", "afterFen"):
        fen = move_entry.get(fen_key)
        if isinstance(fen, str) and fen.strip():
            return chess.Board(fen)

    raise ValueError(f"Could not determine move from entry: {move_entry}")


def evaluation_from_info(
    info: dict[str, Any],
    board: chess.Board,
    depth: int,
) -> dict[str, Any]:
    score = info["score"].pov(chess.WHITE)

    mate = score.mate()
    cp = score.score(mate_score=100000)

    if mate is not None:
        return {
            "engine": "stockfish",
            "depth": depth,
            "fen": board.fen(),
            "score": {
                "kind": "mate",
                "whiteCentipawns": None,
                "mateIn": mate,
            },
        }

    return {
        "engine": "stockfish",
        "depth": depth,
        "fen": board.fen(),
        "score": {
            "kind": "centipawn",
            "whiteCentipawns": cp,
            "mateIn": None,
        },
    }


def evaluate_game(
    game: dict[str, Any],
    engine: chess.engine.SimpleEngine,
    depth: int,
    force: bool,
) -> int:
    moves = find_move_list(game)
    board = chess.Board(starting_fen_for_game(game))

    evaluated_count = 0

    for index, move_entry in enumerate(moves):
        if not isinstance(move_entry, dict):
            raise ValueError(f"Move at index {index} is not an object: {move_entry}")

        board = move_to_board_position(board, move_entry)

        if move_entry.get("engineEvaluation") is not None and not force:
            continue

        info = engine.analyse(board, chess.engine.Limit(depth=depth))
        move_entry["engineEvaluation"] = evaluation_from_info(
            info=info,
            board=board,
            depth=depth,
        )

        evaluated_count += 1

    game["engineAnalysis"] = {
        "engine": "stockfish",
        "depth": depth,
        "scoreConvention": "Positive whiteCentipawns means White is better. Negative means Black is better.",
    }

    return evaluated_count


def input_files(input_path: Path) -> list[Path]:
    if input_path.is_file():
        return [input_path]

    if input_path.is_dir():
        return sorted(input_path.glob("*.json"))

    raise FileNotFoundError(f"Input path does not exist: {input_path}")


def output_path_for(input_file: Path, input_root: Path, output_root: Path) -> Path:
    if input_root.is_file():
        return output_root

    return output_root / input_file.name


def main() -> None:
    args = parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)

    files = input_files(input_path)

    if not files:
        raise SystemExit(f"No JSON files found at: {input_path}")

    print(f"Using Stockfish: {args.stockfish}")
    print(f"Depth: {args.depth}")
    print(f"Files: {len(files)}")

    with chess.engine.SimpleEngine.popen_uci(args.stockfish) as engine:
        engine.configure(
            {
                "Threads": args.threads,
                "Hash": args.hash_mb,
            }
        )

        total_evaluated = 0

        for file_path in files:
            data = load_json(file_path)
            games, _ = get_games_container(data)

            file_evaluated = 0

            for game in games:
                file_evaluated += evaluate_game(
                    game=game,
                    engine=engine,
                    depth=args.depth,
                    force=args.force,
                )

            destination = output_path_for(
                input_file=file_path,
                input_root=input_path,
                output_root=output_path,
            )

            write_json(destination, data)

            print(f"{file_path.name}: evaluated {file_evaluated} positions")
            total_evaluated += file_evaluated

    print(f"Done. Total evaluated positions: {total_evaluated}")


if __name__ == "__main__":
    main()
