import Foundation
import Testing
@testable import ChessNotation

struct NotationServicesTests {
    @Test
    func notationValidatorNormalizesCastlingAndWhitespace() {
        let move = TestFixtures.operaGame.moves[0]

        #expect(NotationAnswerValidator.isCorrect("  e4  ", for: move))
        #expect(NotationAnswerValidator.normalize("0-0") == "O-O")
        #expect(NotationAnswerValidator.normalize("0-0-0") == "O-O-O")
    }

    @Test
    func fenParserBuildsCompleteBoardFromStartPosition() {
        let squares = FENParser.squares(from: "startpos")

        #expect(squares.count == 64)
        #expect(squares.first(where: { $0.coordinate == "a1" })?.piece?.symbol == "♖")
        #expect(squares.first(where: { $0.coordinate == "e1" })?.piece?.symbol == "♔")
        #expect(squares.first(where: { $0.coordinate == "d8" })?.piece?.symbol == "♛")
        #expect(squares.first(where: { $0.coordinate == "e4" })?.piece == nil)
    }

    @Test
    func libraryFiltersByDifficultyOpeningAndSearch() {
        let games = [TestFixtures.operaGame, TestFixtures.advancedGame]
        var filters = GameLibraryFilters()

        filters.difficulty = .advanced
        #expect(filters.apply(to: games).map(\.id) == ["evergreen-game-1852"])

        filters.difficulty = .all
        filters.opening = OpeningFilter(name: "Philidor Defense")
        #expect(filters.apply(to: games).map(\.id) == ["opera-game-1858"])

        filters.opening = .all
        filters.searchText = "anderssen"
        #expect(filters.apply(to: games).map(\.id) == ["evergreen-game-1852"])

        let openings = filters.availableOpeningFilters(from: games).map(\.displayName)
        #expect(openings == ["All Openings", "Evans Gambit", "Philidor Defense"])
    }

    @Test
    func bundledGameLibraryDecodesSingleGamePayload() throws {
        let data = try #require(
            """
            {
              "id": "single-game",
              "title": "Single Game",
              "white": "White",
              "black": "Black",
              "year": 2024,
              "opening": "Test Opening",
              "difficulty": "beginner",
              "moves": [
                {
                  "moveNumber": 1,
                  "side": "white",
                  "fenBefore": "startpos",
                  "from": "e2",
                  "to": "e4",
                  "san": "e4",
                  "coordinate": "e2e4",
                  "tags": ["pawnMove"]
                }
              ]
            }
            """.data(using: .utf8)
        )

        let games = try BundledGameLibraryService.decodeGames(from: data)

        #expect(games.count == 1)
        #expect(games[0].id == "single-game")
        #expect(games[0].moves.count == 1)
    }

    @Test
    func bundledGameLibraryDecodesGameArrayPayload() throws {
        let data = try #require(
            """
            [
              {
                "id": "array-game-1",
                "title": "Array Game 1",
                "white": "White",
                "black": "Black",
                "year": 2024,
                "opening": "Test Opening",
                "difficulty": "beginner",
                "moves": [
                  {
                    "moveNumber": 1,
                    "side": "white",
                    "fenBefore": "startpos",
                    "from": "e2",
                    "to": "e4",
                    "san": "e4",
                    "coordinate": "e2e4",
                    "tags": ["pawnMove"]
                  }
                ]
              },
              {
                "id": "array-game-2",
                "title": "Array Game 2",
                "white": "White",
                "black": "Black",
                "year": 2025,
                "opening": "Other Opening",
                "difficulty": "advanced",
                "moves": [
                  {
                    "moveNumber": 1,
                    "side": "white",
                    "fenBefore": "startpos",
                    "from": "d2",
                    "to": "d4",
                    "san": "d4",
                    "coordinate": "d2d4",
                    "tags": ["pawnMove"]
                  }
                ]
              }
            ]
            """.data(using: .utf8)
        )

        let games = try BundledGameLibraryService.decodeGames(from: data)

        #expect(games.count == 2)
        #expect(games.map(\.id) == ["array-game-1", "array-game-2"])
    }

    @Test
    @MainActor
    func notationMoveDecodesWithoutEngineEvaluation() throws {
        let data = try #require(
            """
            {
              "moveNumber": 1,
              "side": "white",
              "fenBefore": "startpos",
              "from": "e2",
              "to": "e4",
              "san": "e4",
              "coordinate": "e2e4",
              "tags": ["pawnMove"]
            }
            """.data(using: .utf8)
        )

        let move = try JSONDecoder().decode(NotationMove.self, from: data)

        #expect(move.engineEvaluation == nil)
    }

    @Test
    @MainActor
    func engineEvaluationDecodesCentipawnScore() throws {
        let data = try #require(
            """
            {
              "engine": "Stockfish",
              "depth": 18,
              "fen": "startpos",
              "score": {
                "kind": "centipawn",
                "whiteCentipawns": 125,
                "mateIn": null
              }
            }
            """.data(using: .utf8)
        )

        let evaluation = try JSONDecoder().decode(EngineEvaluation.self, from: data)

        #expect(evaluation.score?.kind == .centipawn)
        #expect(evaluation.score?.whiteCentipawns == 125)
        #expect(evaluation.displayText == "+1.2")
    }

    @Test
    @MainActor
    func engineEvaluationDecodesMateScore() throws {
        let data = try #require(
            """
            {
              "engine": "Stockfish",
              "depth": 20,
              "fen": "startpos",
              "score": {
                "kind": "mate",
                "whiteCentipawns": null,
                "mateIn": -3
              }
            }
            """.data(using: .utf8)
        )

        let evaluation = try JSONDecoder().decode(EngineEvaluation.self, from: data)

        #expect(evaluation.score?.kind == .mate)
        #expect(evaluation.score?.mateIn == -3)
        #expect(evaluation.displayText == "-M3")
    }

    @Test
    func engineEvaluationDisplayTextMatchesScoreKind() {
        let centipawn = EngineEvaluation(
            engine: "Stockfish",
            depth: 16,
            fen: "startpos",
            score: EngineScore(kind: .centipawn, whiteCentipawns: 62, mateIn: nil)
        )
        let mate = EngineEvaluation(
            engine: "Stockfish",
            depth: 20,
            fen: "startpos",
            score: EngineScore(kind: .mate, whiteCentipawns: nil, mateIn: 4)
        )

        #expect(centipawn.displayText == "+0.6")
        #expect(mate.displayText == "M4")
    }

    @Test
    func whiteAdvantageFractionUsesNeutralLogisticAndMateBehavior() {
        let noScore = EngineEvaluation(engine: "Stockfish", depth: 12, fen: "startpos", score: nil)
        let centered = EngineScore(kind: .centipawn, whiteCentipawns: 0, mateIn: nil)
        let clampedWinning = EngineScore(kind: .centipawn, whiteCentipawns: 1500, mateIn: nil)
        let whiteMate = EngineScore(kind: .mate, whiteCentipawns: nil, mateIn: 2)
        let blackMate = EngineScore(kind: .mate, whiteCentipawns: nil, mateIn: -2)

        #expect(noScore.whiteAdvantageFraction == 0.5)
        #expect(abs(centered.whiteAdvantageFraction - 0.5) < 0.0001)
        #expect(abs(clampedWinning.whiteAdvantageFraction - (1 / (1 + exp(-1000.0 / 350.0)))) < 0.0001)
        #expect(whiteMate.whiteAdvantageFraction == 1.0)
        #expect(blackMate.whiteAdvantageFraction == 0.0)
    }
}
