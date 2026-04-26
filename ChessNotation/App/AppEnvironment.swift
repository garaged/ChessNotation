import Foundation

enum AppEnvironment {
    static func makeLibraryService() -> GameLibraryProviding {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("UITEST_SAMPLE_LIBRARY") {
            return InMemoryGameLibraryService(games: sampleGames)
        }

        return BundledGameLibraryService()
    }

    private static let sampleGames: [NotationGame] = [
        NotationGame(
            id: "mini-opera",
            title: "Mini Opera",
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
                )
            ]
        ),
        NotationGame(
            id: "mini-evergreen",
            title: "Mini Evergreen",
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
                    from: "d2",
                    to: "d4",
                    san: "d4",
                    coordinate: "d2d4",
                    tags: [.pawnMove],
                    engineEvaluation: nil
                )
            ]
        )
    ]
}

private struct InMemoryGameLibraryService: GameLibraryProviding {
    let games: [NotationGame]

    func loadGames() throws -> [NotationGame] {
        games
    }
}
