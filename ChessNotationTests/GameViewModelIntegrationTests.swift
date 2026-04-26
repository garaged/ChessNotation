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
}
