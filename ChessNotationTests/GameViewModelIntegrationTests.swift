import Foundation
import Testing
@testable import ChessNotation

struct GameViewModelIntegrationTests {
    @Test
    func correctAnswerAdvancesAndRecordsSuccess() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame)

        viewModel.answerText = "e4"
        viewModel.submitAnswer()

        #expect(viewModel.currentMoveIndex == 1)
        #expect(viewModel.records.count == 1)
        #expect(viewModel.records[0].wasCorrect)
        #expect(viewModel.records[0].attemptsUsed == 1)
        #expect(viewModel.answerText.isEmpty)
        #expect(viewModel.feedback == "Enter the notation for the highlighted move.")
    }

    @Test
    func currentPositionEvaluationUsesReachedPositionOnly() throws {
        let viewModel = GameViewModel(game: TestFixtures.evaluatedGame)

        #expect(viewModel.hasStoredEvaluations)
        #expect(viewModel.currentPositionEvaluation == nil)

        viewModel.answerText = "e4"
        viewModel.submitAnswer()

        let evaluation = try #require(viewModel.currentPositionEvaluation)
        #expect(evaluation.displayText == "+0.4")
        #expect(evaluation.depth == 12)
        #expect(evaluation.engine == "Stockfish")
        #expect(viewModel.currentMove?.san == "e5")
    }

    @Test
    func gameWithoutStoredEvaluationsDoesNotRequestEvaluationBar() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame)

        #expect(!viewModel.hasStoredEvaluations)
        #expect(viewModel.currentPositionEvaluation == nil)
    }

    @Test
    func notationKeyboardInputBuildsAndEditsAnswer() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame)

        viewModel.appendToAnswer("N")
        viewModel.appendToAnswer("f")
        viewModel.appendToAnswer("3")
        #expect(viewModel.answerText == "Nf3")

        viewModel.removeLastAnswerCharacter()
        #expect(viewModel.answerText == "Nf")

        viewModel.clearAnswer()
        #expect(viewModel.answerText.isEmpty)
    }

    @Test
    func exhaustingAttemptsRevealsAnswerAndContinues() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame)

        viewModel.answerText = "Nc3"
        viewModel.submitAnswer()
        viewModel.answerText = "Bb5"
        viewModel.submitAnswer()
        viewModel.answerText = "Qh5"
        viewModel.submitAnswer()

        #expect(viewModel.currentMoveIndex == 1)
        #expect(viewModel.records.count == 1)
        #expect(!viewModel.records[0].wasCorrect)
        #expect(viewModel.records[0].attemptsUsed == 3)
        #expect(viewModel.revealedAnswer == nil)
        #expect(viewModel.attemptsRemaining == 3)
    }

    @Test
    func skipMoveMarksMoveIncorrectAndResetsSession() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame)

        viewModel.skipMove()

        #expect(viewModel.records.count == 1)
        #expect(!viewModel.records[0].wasCorrect)
        #expect(viewModel.currentMoveIndex == 1)

        viewModel.reset()

        #expect(viewModel.currentMoveIndex == 0)
        #expect(viewModel.records.isEmpty)
        #expect(!viewModel.isFinished)
        #expect(viewModel.feedback == "Enter the notation for the highlighted move.")
    }

    @Test
    func incorrectAnswerHintsDoNotRevealSanOrDestination() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame)

        viewModel.answerText = "a3"
        viewModel.submitAnswer()
        #expect(!viewModel.feedback.contains("e4"))
        #expect(!viewModel.feedback.contains("e2"))
        #expect(!viewModel.feedback.contains("e4"))

        viewModel.answerText = "h4"
        viewModel.submitAnswer()
        #expect(!viewModel.feedback.contains("e4"))
        #expect(!viewModel.feedback.contains("starts with"))
        #expect(viewModel.feedback.contains("pawn"))
    }

    @Test
    func timedSessionStartsWithSelectedDurationAndTicksDown() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame, mode: .timed(durationSeconds: 180))

        #expect(viewModel.remainingSeconds == 180)
        #expect(viewModel.currentMoveIndex == 0)
        #expect(viewModel.timerText == "3:00")
        #expect(!viewModel.isLowTime)

        viewModel.tickTimer()

        #expect(viewModel.remainingSeconds == 179)
        #expect(!viewModel.isFinished)
    }

    @Test
    func timedSessionEntersLowTimeWarningState() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame, mode: .timed(durationSeconds: 11))

        #expect(!viewModel.isLowTime)

        viewModel.tickTimer()

        #expect(viewModel.remainingSeconds == 10)
        #expect(viewModel.isLowTime)
    }

    @Test
    func timedSessionFinishesOnTimeoutAndIgnoresFurtherSubmissions() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame, mode: .timed(durationSeconds: 1))

        viewModel.tickTimer()
        #expect(viewModel.isFinished)
        #expect(viewModel.summary.finishReason == .timedOut)

        viewModel.answerText = "e4"
        viewModel.submitAnswer()
        viewModel.tickTimer()

        #expect(viewModel.records.isEmpty)
        #expect(viewModel.currentMoveIndex == 0)
        #expect(viewModel.summary.finishReason == .timedOut)
    }

    @Test
    func timedSessionCompletesFinalMoveBeforeTimeout() {
        let viewModel = GameViewModel(game: TestFixtures.advancedGame, mode: .timed(durationSeconds: 60))

        viewModel.answerText = "e4"
        viewModel.submitAnswer()

        #expect(viewModel.isFinished)
        #expect(viewModel.summary.finishReason == .completed)
        #expect(viewModel.summary.selectedDurationSeconds == 60)
        #expect(viewModel.summary.timeUsedSeconds == 0)
        #expect(viewModel.summary.completedMoves == 1)
        #expect(viewModel.summary.correctMoves == 1)
        #expect(viewModel.summary.incorrectMoves == 0)
        #expect(viewModel.summary.accuracy == 1)
        #expect(viewModel.summary.finishedAt == viewModel.finishedAt)
    }

    @Test
    func notationHistoryRecordCapturesUntimedMetrics() throws {
        let viewModel = GameViewModel(game: TestFixtures.operaGame)

        viewModel.answerText = "e4"
        viewModel.submitAnswer()
        viewModel.skipMove()

        let record = NotationTrainingHistoryRecord(summary: viewModel.summary)

        #expect(record.schemaVersion == 1)
        #expect(record.gameType == "notation")
        #expect(record.gameID == TestFixtures.operaGame.id)
        #expect(record.completedMoves == 2)
        #expect(record.totalMoves == 2)
        #expect(record.correctMoves == 1)
        #expect(record.incorrectMoves == 1)
        #expect(record.firstTryCorrectCount == 1)
        #expect(record.skippedOrRevealedCount == 1)
        #expect(record.completionPercentage == 1)
        #expect(record.attemptsDistribution[1] == 1)
        #expect(record.attemptsDistribution[0] == 1)
        #expect(record.mistakesByTag[MoveTypeTag.pawnMove.rawValue] == 1)
    }

    @Test
    func notationHistoryRecordCapturesTimedMetricsAndStoreDeduplicates() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let store = NotationTrainingHistoryStore(fileURL: fileURL)
        let viewModel = GameViewModel(game: TestFixtures.operaGame, mode: .timed(durationSeconds: 60))

        viewModel.tickTimer()
        viewModel.answerText = "e4"
        viewModel.submitAnswer()

        let record = NotationTrainingHistoryRecord(summary: viewModel.summary)
        try store.saveResult(record)
        try store.saveResult(record)

        let loaded = try store.loadResults()
        #expect(loaded.count == 1)
        #expect(loaded[0].gameType == "timedNotation")
        #expect(loaded[0].selectedDurationSeconds == 60)
        #expect(loaded[0].timeUsedSeconds == 1)
        #expect(loaded[0].movesPerMinute == 60)
        #expect(loaded[0].completionPercentage == 0.5)

        try? FileManager.default.removeItem(at: fileURL)
    }

    @Test
    func historyRangeFiltersTrailingWindows() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let eightDaysAgo = now.addingTimeInterval(-8 * 24 * 60 * 60)
        let twoMonthsAgo = now.addingTimeInterval(-62 * 24 * 60 * 60)

        #expect(HistoryRange.lastWeek.contains(now.addingTimeInterval(-2 * 24 * 60 * 60), now: now))
        #expect(!HistoryRange.lastWeek.contains(eightDaysAgo, now: now))
        #expect(HistoryRange.lastMonth.contains(eightDaysAgo, now: now))
        #expect(!HistoryRange.lastMonth.contains(twoMonthsAgo, now: now))
        #expect(HistoryRange.lastYear.contains(twoMonthsAgo, now: now))
    }

    @Test
    func historyRangeFiltersTodayAndKeepsAxisLabelsSparse() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = Date(timeIntervalSince1970: 1_783_069_200)
        let earlierToday = now.addingTimeInterval(-6 * 60 * 60)
        let yesterday = now.addingTimeInterval(-26 * 60 * 60)
        let dates = [
            now.addingTimeInterval(-11 * 60 * 60),
            now.addingTimeInterval(-8 * 60 * 60),
            now.addingTimeInterval(-3 * 60 * 60),
            now
        ]

        #expect(HistoryRange.today.contains(earlierToday, now: now, calendar: calendar))
        #expect(!HistoryRange.today.contains(yesterday, now: now, calendar: calendar))
        #expect(HistoryRange.today.axisLabels(for: dates).count == 3)
        #expect(HistoryRange.lastMonth.axisLabels(for: Array(dates.prefix(2))).count == 2)
    }

    @Test
    func timedSessionResetRestoresOriginalDuration() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame, mode: .timed(durationSeconds: 60))

        viewModel.answerText = "e4"
        viewModel.submitAnswer()
        viewModel.tickTimer()
        viewModel.reset()

        #expect(viewModel.remainingSeconds == 60)
        #expect(viewModel.currentMoveIndex == 0)
        #expect(viewModel.records.isEmpty)
        #expect(!viewModel.isFinished)
    }

    @Test
    func untimedSessionDoesNotFinishFromTimerTick() {
        let viewModel = GameViewModel(game: TestFixtures.operaGame)

        viewModel.tickTimer()

        #expect(viewModel.remainingSeconds == nil)
        #expect(!viewModel.isFinished)
        #expect(viewModel.currentMoveIndex == 0)
    }
}
