import Testing
@testable import ChessNotation

struct MiniGameStateAccessibilityTests {
    @Test
    func pieceMovementAnnouncesEveryVisualSquareRoleWithoutColor() throws {
        let source = try #require(ChessSquare("e4"))
        let friendly = try #require(ChessSquare("e6"))
        let enemy = try #require(ChessSquare("e2"))
        let selected = try #require(ChessSquare("f4"))
        let empty = try #require(ChessSquare("a1"))
        let prompt = try #require(PieceMovementPromptFactory.makePrompt(
            piece: .rook,
            side: .white,
            source: source,
            occupancy: PieceMovementOccupancy(friendly: [friendly], enemy: [enemy]),
            orientation: .black,
            difficulty: .advanced
        ))

        let cells = PieceMovementBoardCellPresentation.cells(prompt: prompt, selected: [selected])
        let bySquare = Dictionary(uniqueKeysWithValues: cells.map { ($0.square, $0) })

        #expect(bySquare[source]?.accessibilityLabel.contains("source white rook") == true)
        #expect(bySquare[friendly]?.accessibilityLabel.contains("friendly blocker") == true)
        #expect(bySquare[enemy]?.accessibilityLabel.contains("enemy piece") == true)
        #expect(bySquare[selected]?.accessibilityLabel.contains("selected") == true)
        #expect(bySquare[empty]?.accessibilityLabel.contains("Square a1") == true)

        #expect(bySquare[source]?.role == .source)
        #expect(bySquare[friendly]?.role == .friendly)
        #expect(bySquare[enemy]?.role == .enemy)
        #expect(bySquare[selected]?.role == .selected)
        #expect(bySquare[empty]?.role == .empty)
    }

    @Test
    func pieceMovementOrientationChangesDisplayOrderButNotSquareIdentity() throws {
        let source = try #require(ChessSquare("c3"))
        let whitePrompt = try #require(PieceMovementPromptFactory.makePrompt(
            piece: .bishop,
            side: .black,
            source: source,
            occupancy: PieceMovementOccupancy(),
            orientation: .white,
            difficulty: .beginner
        ))
        let blackPrompt = try #require(PieceMovementPromptFactory.makePrompt(
            piece: .bishop,
            side: .black,
            source: source,
            occupancy: PieceMovementOccupancy(),
            orientation: .black,
            difficulty: .beginner
        ))

        let whiteCells = PieceMovementBoardCellPresentation.cells(prompt: whitePrompt, selected: [])
        let blackCells = PieceMovementBoardCellPresentation.cells(prompt: blackPrompt, selected: [])

        #expect(Set(whiteCells.map(\.square)) == Set(blackCells.map(\.square)))
        #expect(whiteCells.first?.square != blackCells.first?.square)
        #expect(whiteCells.first(where: { $0.square == source })?.id == source.description)
        #expect(blackCells.first(where: { $0.square == source })?.id == source.description)
    }

    @Test
    func positionRecallAnnouncesVisibleMaskedAndReconstructedStates() throws {
        let clock = TestMonotonicClock(now: 10)
        let snapshot = PositionRecallSnapshot(pieces: [
            PositionRecallPlacedPiece(
                square: try #require(ChessSquare("e4")),
                piece: PositionRecallPiece(piece: .king, side: .white)
            ),
            PositionRecallPlacedPiece(
                square: try #require(ChessSquare("a8")),
                piece: PositionRecallPiece(piece: .queen, side: .black)
            ),
            PositionRecallPlacedPiece(
                square: try #require(ChessSquare("c3")),
                piece: PositionRecallPiece(piece: .knight, side: .white)
            ),
            PositionRecallPlacedPiece(
                square: try #require(ChessSquare("h1")),
                piece: PositionRecallPiece(piece: .rook, side: .black)
            )
        ])
        let viewModel = try #require(PositionRecallReconstructionViewModel(
            configuration: PositionRecallReconstructionConfiguration(
                difficulty: .beginner,
                orientation: .black,
                promptLimit: 1,
                studyDuration: 30
            ),
            snapshots: [snapshot],
            randomizer: SeededChallengeRandomizer(seed: 2),
            clock: clock,
            historyStore: AccessibilityMemoryPositionRecallHistoryStore()
        ))
        let masked = try #require(viewModel.prompt.maskedSquares.first)

        let studyingLabel = viewModel.accessibilityLabel(for: masked)
        #expect(studyingLabel.contains(masked.description))
        #expect(studyingLabel.contains("visible"))

        viewModel.hideNow()
        let maskedLabel = viewModel.accessibilityLabel(for: masked)
        #expect(maskedLabel.contains(masked.description))
        #expect(maskedLabel.contains("masked square"))
        #expect(!maskedLabel.contains("visible"))

        viewModel.place(PositionRecallPiece(piece: .bishop, side: .white), at: masked)
        let reconstructedLabel = viewModel.accessibilityLabel(for: masked)
        #expect(reconstructedLabel.contains(masked.description))
        #expect(reconstructedLabel.contains("masked square"))
        #expect(reconstructedLabel.contains("reconstructed white bishop"))
    }
}

private final class AccessibilityMemoryPositionRecallHistoryStore: PositionRecallReconstructionHistoryStoring {
    func loadResults() throws -> [PositionRecallSessionResult] { [] }
    func saveResult(_ result: PositionRecallSessionResult) throws {}
}
