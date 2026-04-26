import Foundation
@testable import ChessNotation

enum TestFixtures {
    static let operaGame = NotationGame(
        id: "opera-game-1858",
        title: "Opera Game",
        white: "Paul Morphy",
        black: "Duke Karl / Count Isouard",
        year: 1858,
        opening: "Philidor Defense",
        difficulty: .beginner,
        moves: [
            NotationMove(
                moveNumber: 1,
                side: .white,
                fenBefore: "startpos",
                from: "e2",
                to: "e4",
                san: "e4",
                coordinate: "e2e4",
                tags: [.pawnMove],
                engineEvaluation: nil
            ),
            NotationMove(
                moveNumber: 1,
                side: .black,
                fenBefore: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1",
                from: "e7",
                to: "e5",
                san: "e5",
                coordinate: "e7e5",
                tags: [.pawnMove],
                engineEvaluation: nil
            )
        ]
    )

    static let advancedGame = NotationGame(
        id: "evergreen-game-1852",
        title: "Evergreen Game",
        white: "Adolf Anderssen",
        black: "Jean Dufresne",
        year: 1852,
        opening: "Evans Gambit",
        difficulty: .advanced,
        moves: [
            NotationMove(
                moveNumber: 1,
                side: .white,
                fenBefore: "startpos",
                from: "e2",
                to: "e4",
                san: "e4",
                coordinate: "e2e4",
                tags: [.pawnMove],
                engineEvaluation: nil
            )
        ]
    )
}
