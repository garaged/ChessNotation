import Foundation
import Testing
@testable import ChessNotation

private final class MemoryPositionRecallHistoryStore: PositionRecallReconstructionHistoryStoring {
    var results: [PositionRecallSessionResult] = []
    func loadResults() throws -> [PositionRecallSessionResult] { results }
    func saveResult(_ result: PositionRecallSessionResult) throws { results.append(result) }
}

struct PositionRecallReconstructionViewModelTests {
    private func snapshot() throws -> PositionRecallSnapshot {
        PositionRecallSnapshot(pieces: [
            PositionRecallPlacedPiece(square: try #require(ChessSquare("e4")), piece: PositionRecallPiece(piece: .king, side: .white)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("a8")), piece: PositionRecallPiece(piece: .queen, side: .black)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("c3")), piece: PositionRecallPiece(piece: .knight, side: .white)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("h1")), piece: PositionRecallPiece(piece: .rook, side: .black))
        ])
    }

    @Test
    func studyPhaseShowsPiecesButAnswerPhaseMasksThem() throws {
        let clock = TestMonotonicClock(now: 10)
        let store = MemoryPositionRecallHistoryStore()
        let viewModel = try #require(PositionRecallReconstructionViewModel(
            configuration: PositionRecallReconstructionConfiguration(difficulty: .beginner, orientation: .black, promptLimit: 1, studyDuration: 3),
            snapshots: [snapshot()],
            randomizer: SeededChallengeRandomizer(seed: 2),
            clock: clock,
            historyStore: store
        ))
        let masked = try #require(viewModel.prompt.maskedSquares.first)
        let studyLabel = viewModel.pieceLabel(at: masked)
        clock.advance(by: 3)
        viewModel.refresh()

        #expect(viewModel.phase == .answering)
        #expect(studyLabel != "?")
        #expect(viewModel.pieceLabel(at: masked) == "?")
        #expect(viewModel.accessibilityLabel(for: masked).contains("masked square"))
        #expect(!viewModel.accessibilityLabel(for: masked).contains("visible"))
    }

    @Test
    func answerPlacementUpdatesLabelsAndSummary() throws {
        let clock = TestMonotonicClock(now: 20)
        let store = MemoryPositionRecallHistoryStore()
        let viewModel = try #require(PositionRecallReconstructionViewModel(
            configuration: PositionRecallReconstructionConfiguration(difficulty: .beginner, orientation: .white, promptLimit: 1, studyDuration: 0),
            snapshots: [snapshot()],
            randomizer: SeededChallengeRandomizer(seed: 3),
            clock: clock,
            historyStore: store
        ))
        viewModel.refresh()
        let masked = try #require(viewModel.prompt.maskedSquares.first)

        viewModel.place(PositionRecallPiece(piece: .queen, side: .black), at: masked)

        #expect(viewModel.pieceLabel(at: masked) == "BQ")
        #expect(viewModel.accessibilityLabel(for: masked).contains("reconstructed black queen"))
        #expect(viewModel.accessibilitySummary.contains("Reconstructed pieces"))
    }

    @Test
    func submitSavesResultAndFeedback() throws {
        let clock = TestMonotonicClock(now: 30)
        let store = MemoryPositionRecallHistoryStore()
        let viewModel = try #require(PositionRecallReconstructionViewModel(
            configuration: PositionRecallReconstructionConfiguration(difficulty: .beginner, orientation: .white, promptLimit: 1, studyDuration: 0),
            snapshots: [snapshot()],
            randomizer: SeededChallengeRandomizer(seed: 4),
            clock: clock,
            historyStore: store
        ))
        viewModel.refresh()
        for piece in viewModel.prompt.expectedPieces {
            viewModel.place(piece.piece, at: piece.square)
        }

        viewModel.submit()

        #expect(viewModel.phase == .finished)
        #expect(viewModel.feedback?.contains("Correct") == true)
        #expect(viewModel.savedResult?.exactCount == 1)
        #expect(store.results.count == 1)
    }

    @Test
    func blackOrientationMappingUsesSameCoordinateAfterTap() throws {
        let clock = TestMonotonicClock(now: 40)
        let viewModel = try #require(PositionRecallReconstructionViewModel(
            configuration: PositionRecallReconstructionConfiguration(difficulty: .beginner, orientation: .black, promptLimit: 1, studyDuration: 0),
            snapshots: [snapshot()],
            randomizer: SeededChallengeRandomizer(seed: 5),
            clock: clock,
            historyStore: MemoryPositionRecallHistoryStore()
        ))
        viewModel.refresh()
        let masked = try #require(viewModel.prompt.maskedSquares.first)
        let displayIndex = SquareBoardMapping.displayIndex(for: masked, orientation: .black)
        let tapped = try #require(SquareBoardMapping.square(forDisplayIndex: displayIndex, orientation: .black))

        viewModel.place(PositionRecallPiece(piece: .bishop, side: .white), at: tapped)

        #expect(tapped == masked)
        #expect(viewModel.answer.pieces.contains { $0.square == masked })
    }
}
