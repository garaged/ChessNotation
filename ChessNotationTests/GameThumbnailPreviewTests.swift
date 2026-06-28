import Testing
@testable import ChessNotation

struct GameThumbnailPreviewTests {
    @Test
    func previewUsesAppliedMovesForEightPlyGameAndHandlesCaptures() {
        let game = NotationGame(
            id: "thumbnail-capture",
            title: "Thumbnail Capture",
            white: "White",
            black: "Black",
            year: 2026,
            opening: "Test Opening",
            difficulty: .intermediate,
            moves: [
                Self.move(1, .white, from: "e2", to: "e4", san: "e4"),
                Self.move(1, .black, from: "e7", to: "e5", san: "e5"),
                Self.move(2, .white, from: "g1", to: "f3", san: "Nf3"),
                Self.move(2, .black, from: "b8", to: "c6", san: "Nc6"),
                Self.move(3, .white, from: "f1", to: "c4", san: "Bc4"),
                Self.move(3, .black, from: "g8", to: "f6", san: "Nf6"),
                Self.move(4, .white, from: "f3", to: "e5", san: "Nxe5", tags: [.capture]),
                Self.move(4, .black, from: "d7", to: "d6", san: "d6")
            ]
        )

        let preview = GameThumbnailGenerator.preview(for: game)

        #expect(preview.source == .appliedMoves)
        #expect(preview.appliedPlyCount == 8)
        #expect(preview.squares.first(where: { $0.coordinate == "e5" })?.piece?.side == .white)
        #expect(preview.squares.first(where: { $0.coordinate == "f3" })?.piece == nil)
        #expect(preview.squares.first(where: { $0.coordinate == "d6" })?.piece?.side == .black)
    }

    @Test
    func previewReportsShortGameFinalPosition() {
        let preview = GameThumbnailGenerator.preview(for: TestFixtures.advancedGame)

        #expect(preview.source == .shortGameFinalPosition)
        #expect(preview.appliedPlyCount == 1)
        #expect(preview.squares.first(where: { $0.coordinate == "e4" })?.piece?.side == .white)
    }

    @Test
    func previewUsesFinalAvailablePositionForFiveToSevenPlyGame() {
        let game = NotationGame(
            id: "thumbnail-six-ply",
            title: "Thumbnail Six Ply",
            white: "White",
            black: "Black",
            year: 2026,
            opening: "Six Ply Test",
            difficulty: .beginner,
            moves: [
                Self.move(1, .white, from: "e2", to: "e4", san: "e4"),
                Self.move(1, .black, from: "e7", to: "e5", san: "e5"),
                Self.move(2, .white, from: "g1", to: "f3", san: "Nf3"),
                Self.move(2, .black, from: "b8", to: "c6", san: "Nc6"),
                Self.move(3, .white, from: "f1", to: "c4", san: "Bc4"),
                Self.move(3, .black, from: "g8", to: "f6", san: "Nf6")
            ]
        )

        let preview = GameThumbnailGenerator.preview(for: game)

        #expect(preview.source == .shortGameFinalPosition)
        #expect(preview.appliedPlyCount == 6)
        #expect(preview.squares.first(where: { $0.coordinate == "c4" })?.piece?.kind == .bishop)
        #expect(preview.squares.first(where: { $0.coordinate == "f6" })?.piece?.kind == .knight)
        #expect(preview.squares.first(where: { $0.coordinate == "g8" })?.piece == nil)
    }

    @Test
    func previewFallsBackForUnsupportedSpecialMove() {
        let castlingGame = NotationGame(
            id: "thumbnail-castle",
            title: "Thumbnail Castle",
            white: "White",
            black: "Black",
            year: 2026,
            opening: "Castle Test",
            difficulty: .advanced,
            moves: [
                Self.move(1, .white, from: "e1", to: "g1", san: "O-O", tags: [.castling])
            ]
        )

        let preview = GameThumbnailGenerator.preview(for: castlingGame)

        #expect(preview.source == .fenFallback)
        #expect(preview.appliedPlyCount == 0)
        #expect(preview.squares.count == 64)
        #expect(preview.squares.first(where: { $0.coordinate == "e1" })?.piece?.kind == .king)
    }

    private static func move(
        _ moveNumber: Int,
        _ side: ChessSide,
        from: String,
        to: String,
        san: String,
        tags: [MoveTypeTag] = [.pieceMove]
    ) -> NotationMove {
        NotationMove(
            moveNumber: moveNumber,
            side: side,
            fenBefore: "startpos",
            from: from,
            to: to,
            san: san,
            coordinate: "\(from)\(to)",
            tags: tags,
            engineEvaluation: nil
        )
    }
}
