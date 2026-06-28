import Foundation
import Testing
@testable import ChessNotation

struct SquareRecognitionTests {
    @Test
    func defaultConfigurationUsesTenSecondBonusGameWithValidPrompt() {
        let store = InMemorySquareRecognitionHistoryStore()
        let viewModel = SquareRecognitionViewModel(historyStore: store, now: Date(timeIntervalSince1970: 100))

        #expect(viewModel.remainingTime == 10)
        #expect(viewModel.result == nil)
        #expect(SquareRecognitionViewModel.validCoordinates.count == 64)
        #expect(SquareRecognitionViewModel.validCoordinates.contains(viewModel.targetCoordinate))
        #expect(viewModel.targetCoordinate.range(of: #"^[a-h][1-8]$"#, options: .regularExpression) != nil)
    }

    @Test
    func bonusVariantCorrectAnswerDeductsLatencyAndAddsBonus() throws {
        let store = InMemorySquareRecognitionHistoryStore()
        let start = Date(timeIntervalSince1970: 100)
        let viewModel = SquareRecognitionViewModel(variant: .bonus, historyStore: store, now: start)
        let target = viewModel.targetCoordinate

        viewModel.selectSquare(target, at: start.addingTimeInterval(1.2))

        #expect(abs(viewModel.remainingTime - 9.3) < 0.001)
        #expect(viewModel.answers.last?.isCorrect == true)
        #expect(!viewModel.isFinished)
    }

    @Test
    func bonusVariantIncorrectAnswerOnlyDeductsLatency() throws {
        let store = InMemorySquareRecognitionHistoryStore()
        let start = Date(timeIntervalSince1970: 100)
        let viewModel = SquareRecognitionViewModel(variant: .bonus, historyStore: store, now: start)
        let wrongSquare = SquareRecognitionViewModel.validCoordinates.first { $0 != viewModel.targetCoordinate }!

        viewModel.selectSquare(wrongSquare, at: start.addingTimeInterval(1.2))

        #expect(abs(viewModel.remainingTime - 8.8) < 0.001)
        #expect(viewModel.answers.last?.isCorrect == false)
    }

    @Test
    func strictVariantDoesNotAddBonusForCorrectAnswer() throws {
        let store = InMemorySquareRecognitionHistoryStore()
        let start = Date(timeIntervalSince1970: 100)
        let viewModel = SquareRecognitionViewModel(variant: .strict, historyStore: store, now: start)
        let target = viewModel.targetCoordinate

        viewModel.selectSquare(target, at: start.addingTimeInterval(1.2))

        #expect(abs(viewModel.remainingTime - 8.8) < 0.001)
        #expect(viewModel.answers.last?.isCorrect == true)
    }

    @Test
    func feedbackDelayBlocksExtraClicksUntilNextPrompt() throws {
        let store = InMemorySquareRecognitionHistoryStore()
        let start = Date(timeIntervalSince1970: 100)
        let viewModel = SquareRecognitionViewModel(historyStore: store, now: start)
        let target = viewModel.targetCoordinate

        viewModel.selectSquare(target, at: start.addingTimeInterval(0.4))
        viewModel.selectSquare(target, at: start.addingTimeInterval(0.5))

        #expect(viewModel.answers.count == 1)
        #expect(viewModel.feedback == "Correct")

        viewModel.showNextPrompt(at: start.addingTimeInterval(0.7))

        #expect(viewModel.feedback == nil)
        #expect(viewModel.canAcceptAnswer)
    }

    @Test
    func customFeedbackDelayDoesNotChangeScoringRules() throws {
        let store = InMemorySquareRecognitionHistoryStore()
        let start = Date(timeIntervalSince1970: 100)
        let viewModel = SquareRecognitionViewModel(
            variant: .bonus,
            feedbackDelay: 0.6,
            historyStore: store,
            now: start
        )

        viewModel.selectSquare(viewModel.targetCoordinate, at: start.addingTimeInterval(1.2))

        #expect(abs(viewModel.remainingTime - 9.3) < 0.001)
        #expect(viewModel.feedbackDelay == 0.6)
    }


    @Test
    func answerThatConsumesRemainingTimeEndsSession() throws {
        let store = InMemorySquareRecognitionHistoryStore()
        let start = Date(timeIntervalSince1970: 100)
        let viewModel = SquareRecognitionViewModel(initialTime: 1, variant: .strict, historyStore: store, now: start)

        viewModel.selectSquare(viewModel.targetCoordinate, at: start.addingTimeInterval(1.1))

        #expect(viewModel.isFinished)
        #expect(viewModel.result?.totalPrompts == 1)
        #expect(store.results.count == 1)
    }

    @Test
    func timeoutCreatesZeroAnswerResultAndHistoryEntry() throws {
        let store = InMemorySquareRecognitionHistoryStore()
        let start = Date(timeIntervalSince1970: 100)
        let viewModel = SquareRecognitionViewModel(initialTime: 1, variant: .strict, historyStore: store, now: start)

        viewModel.expireIfNeeded(at: start.addingTimeInterval(1.1))

        let result = try #require(viewModel.result)
        #expect(viewModel.isFinished)
        #expect(result.score == 0)
        #expect(result.accuracy == 0)
        #expect(result.averageLatency == 0)
        #expect(store.results.count == 1)
    }

    @Test
    func resultCalculatesScoreAccuracyAndLatency() throws {
        let result = SquareRecognitionResult(
            initialTime: 10,
            variant: .bonus,
            answers: [
                SquareRecognitionAnswer(target: "a1", selected: "a1", isCorrect: true, latency: 0.4),
                SquareRecognitionAnswer(target: "b2", selected: "c3", isCorrect: false, latency: 1.1),
                SquareRecognitionAnswer(target: "h8", selected: "h8", isCorrect: true, latency: 0.8)
            ]
        )

        #expect(result.score == 2)
        #expect(result.totalPrompts == 3)
        #expect(abs(result.accuracy - (2.0 / 3.0)) < 0.001)
        #expect(abs(result.averageLatency - 0.766666) < 0.001)
        #expect(result.fastestCorrectLatency == 0.4)
        #expect(result.slowestLatency == 1.1)
        #expect(result.schemaVersion == 1)
        #expect(result.gameType == "squareRecognition")
    }

    @Test
    @MainActor
    func resultDecodesExistingHistoryWithoutSchemaVersion() throws {
        let data = try #require(
            """
            {
              "id": "00000000-0000-0000-0000-000000000001",
              "initialTime": 10,
              "variant": "bonus",
              "answers": [],
              "finishedAt": "2026-06-28T12:00:00Z",
              "gameType": "squareRecognition"
            }
            """.data(using: .utf8)
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let result = try decoder.decode(SquareRecognitionResult.self, from: data)

        #expect(result.schemaVersion == 1)
        #expect(result.score == 0)
        #expect(result.gameType == "squareRecognition")
    }

    @Test
    func historyStoreReturnsNewestResultFirst() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let store = SquareRecognitionHistoryStore(fileURL: fileURL)
        let oldResult = SquareRecognitionResult(initialTime: 10, variant: .bonus, answers: [], finishedAt: Date(timeIntervalSince1970: 1))
        let newResult = SquareRecognitionResult(initialTime: 30, variant: .strict, answers: [], finishedAt: Date(timeIntervalSince1970: 2))

        try store.saveResult(oldResult)
        try store.saveResult(newResult)

        let loaded = try store.loadResults()
        #expect(loaded.map(\.id) == [newResult.id, oldResult.id])

        try? FileManager.default.removeItem(at: fileURL)
    }
}

private final class InMemorySquareRecognitionHistoryStore: SquareRecognitionHistoryStoring {
    var results: [SquareRecognitionResult] = []

    func loadResults() throws -> [SquareRecognitionResult] {
        results.sorted { $0.finishedAt > $1.finishedAt }
    }

    func saveResult(_ result: SquareRecognitionResult) throws {
        results.append(result)
    }
}
