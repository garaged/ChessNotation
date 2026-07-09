import Foundation
import Testing
@testable import ChessNotation

private final class MemoryPieceMovementHistoryStore: PieceMovementHistoryStoring {
    var results: [PieceMovementSessionResult] = []
    func loadResults() throws -> [PieceMovementSessionResult] { results }
    func saveResult(_ result: PieceMovementSessionResult) throws { results.append(result) }
}

struct PieceMovementFeatureTests {
    @Test
    func historyStoreRoundTripsMovementResults() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("piece-history.json")
        let store = PieceMovementHistoryStore(fileURL: url)
        let result = PieceMovementSessionResult(
            pieceTypes: [.rook, .bishop],
            difficulty: .advanced,
            orientation: .alternating,
            promptCount: 3,
            exactCount: 2,
            partialCount: 1,
            missingSelectionCount: 4,
            extraSelectionCount: 1,
            averageLatency: 1.25,
            bestStreak: 2,
            finishReason: .completed
        )

        try store.saveResult(result)
        #expect(try store.loadResults() == [result])
    }

    @Test
    func presentationSummaryIncludesModeBoundariesAndProgress() throws {
        let source = try #require(ChessSquare("e4"))
        let prompt = try #require(PieceMovementPromptFactory.makePrompt(
            piece: .rook,
            side: .white,
            source: source,
            occupancy: PieceMovementOccupancy(),
            orientation: .black,
            difficulty: .beginner
        ))
        let presentation = PieceMovementPresentation.make(
            prompt: prompt,
            selected: [try #require(ChessSquare("e5"))],
            completed: 1,
            limit: 5,
            feedback: "Correct. All legal movement squares were selected."
        )

        #expect(presentation.accessibilitySummary.contains("white rook on e4"))
        #expect(presentation.accessibilitySummary.contains("ignores check"))
        #expect(presentation.accessibilitySummary.contains("Prompt 2 of 5"))
        #expect(presentation.accessibilitySummary.contains("Selected 1 squares"))
        #expect(presentation.accessibilitySummary.contains("Correct"))
    }

    @Test
    func viewModelAdvancesDisplayedPromptAfterNext() throws {
        let store = MemoryPieceMovementHistoryStore()
        let configuration = PieceMovementConfiguration(pieces: Set(TrainingPiece.allCases), difficulty: .beginner, orientation: .white, promptLimit: 3)
        let viewModel = try #require(PieceMovementViewModel(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 4),
            clock: TestMonotonicClock(),
            historyStore: store
        ))
        let firstPrompt = viewModel.prompt

        for square in firstPrompt.expectedDestinations { viewModel.toggle(square) }
        viewModel.submit()

        #expect(viewModel.canAdvanceToNextPrompt)

        viewModel.advanceOrFinish()

        #expect(!viewModel.isFinished)
        #expect(!viewModel.inputLocked)
        #expect(viewModel.selected.isEmpty)
        #expect(viewModel.prompt != firstPrompt)
        #expect(viewModel.presentation.task.contains(viewModel.prompt.source.description))
        #expect(viewModel.presentation.task.contains(viewModel.prompt.piece.rawValue))
        #expect(viewModel.presentation.progress == "Prompt 2 of 3")
        #expect(viewModel.presentation.feedback == nil)
    }

    @Test
    func finalSubmittedPromptShowsFinishActionInsteadOfNext() throws {
        let store = MemoryPieceMovementHistoryStore()
        let configuration = PieceMovementConfiguration(pieces: [.king], difficulty: .beginner, orientation: .white, promptLimit: 1)
        let viewModel = try #require(PieceMovementViewModel(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 4),
            clock: TestMonotonicClock(),
            historyStore: store
        ))

        for square in viewModel.prompt.expectedDestinations { viewModel.toggle(square) }
        viewModel.submit()

        #expect(viewModel.presentation.feedback != nil)
        #expect(!viewModel.canAdvanceToNextPrompt)
        #expect(!viewModel.isFinished)

        viewModel.advanceOrFinish()

        #expect(viewModel.isFinished)
        #expect(viewModel.result?.finishReason == .completed)
    }

    @Test
    func viewModelSavesCompletedResult() throws {
        let store = MemoryPieceMovementHistoryStore()
        let configuration = PieceMovementConfiguration(pieces: [.king], difficulty: .beginner, orientation: .white, promptLimit: 1)
        let viewModel = try #require(PieceMovementViewModel(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 4),
            clock: TestMonotonicClock(),
            historyStore: store
        ))

        for square in viewModel.prompt.expectedDestinations { viewModel.toggle(square) }
        viewModel.submit()
        viewModel.advanceOrFinish()

        #expect(viewModel.isFinished)
        #expect(viewModel.result?.finishReason == .completed)
        #expect(store.results.count == 1)
        #expect(store.results.first?.exactCount == 1)
    }

    @Test
    func viewModelFeedbackCommunicatesMissingAndExtraWithoutColor() throws {
        let store = MemoryPieceMovementHistoryStore()
        let configuration = PieceMovementConfiguration(pieces: [.rook], difficulty: .beginner, orientation: .black, promptLimit: 1)
        let viewModel = try #require(PieceMovementViewModel(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 10),
            clock: TestMonotonicClock(),
            historyStore: store
        ))
        let expected = try #require(viewModel.prompt.expectedDestinations.first)
        let extra = try #require(SquareRecognitionPromptFactory.allSquares.first { square in
            square != viewModel.prompt.source && !viewModel.prompt.expectedDestinations.contains(square)
        })
        viewModel.toggle(expected)
        viewModel.toggle(extra)
        viewModel.submit()

        #expect(viewModel.presentation.feedback?.contains("missing") == true)
        #expect(viewModel.presentation.feedback?.contains("not valid") == true)
        #expect(viewModel.inputLocked)
    }
}
