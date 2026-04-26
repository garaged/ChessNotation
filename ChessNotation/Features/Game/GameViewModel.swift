import Foundation
import Observation

@Observable
final class GameViewModel {
    let game: NotationGame

    private(set) var currentMoveIndex = 0
    private(set) var attemptsRemaining = 3
    private(set) var submittedAnswers: [String] = []
    private(set) var feedback: String = "Enter the notation for the highlighted move."
    private(set) var records: [MoveAttemptRecord] = []
    private(set) var isFinished = false
    private(set) var revealedAnswer: String?

    var answerText = ""

    private var moveStartedAt = Date()

    init(game: NotationGame) {
        self.game = game
    }

    var currentMove: NotationMove? {
        guard currentMoveIndex < game.moves.count else { return nil }
        return game.moves[currentMoveIndex]
    }

    var progressText: String {
        "Move \(min(currentMoveIndex + 1, game.moves.count)) of \(game.moves.count)"
    }

    var attemptsText: String {
        "Attempts remaining: \(attemptsRemaining)"
    }

    var summary: TrainingSessionSummary {
        TrainingSessionSummary(game: game, records: records)
    }

    var completedMoves: Int {
        records.count
    }

    var firstTryCorrectMoves: Int {
        records.filter { $0.wasCorrect && $0.attemptsUsed == 1 }.count
    }

    var accuracyText: String {
        guard !records.isEmpty else { return "0%" }
        let accuracy = Double(summary.correctMoves) / Double(records.count)
        return "\(Int((accuracy * 100).rounded()))%"
    }

    func submitAnswer() {
        guard let move = currentMove, !isFinished else { return }
        let answer = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else {
            feedback = "Type your answer first."
            return
        }

        submittedAnswers.append(answer)

        if NotationAnswerValidator.isCorrect(answer, for: move) {
            recordCurrentMove(wasCorrect: true)
            feedback = "Correct: \(move.san)"
            advanceToNextMove()
            return
        }

        attemptsRemaining -= 1

        if attemptsRemaining > 0 {
            feedback = hint(for: move, attemptsRemaining: attemptsRemaining)
        } else {
            revealedAnswer = move.san
            feedback = "Answer: \(move.san). \(explanation(for: move))"
            recordCurrentMove(wasCorrect: false)
            advanceToNextMove()
        }
    }

    func skipMove() {
        guard let move = currentMove, !isFinished else { return }
        revealedAnswer = move.san
        feedback = "Answer: \(move.san). \(explanation(for: move))"
        recordCurrentMove(wasCorrect: false)
        advanceToNextMove()
    }

    func reset() {
        currentMoveIndex = 0
        attemptsRemaining = 3
        submittedAnswers = []
        feedback = "Enter the notation for the highlighted move."
        records = []
        isFinished = false
        revealedAnswer = nil
        answerText = ""
        moveStartedAt = Date()
    }

    private func recordCurrentMove(wasCorrect: Bool) {
        guard let move = currentMove else { return }
        records.append(
            MoveAttemptRecord(
                move: move,
                attemptsUsed: submittedAnswers.count,
                wasCorrect: wasCorrect,
                elapsedSeconds: Date().timeIntervalSince(moveStartedAt),
                submittedAnswers: submittedAnswers
            )
        )
    }

    private func advanceToNextMove() {
        answerText = ""
        currentMoveIndex += 1
        attemptsRemaining = 3
        submittedAnswers = []
        moveStartedAt = Date()

        if currentMoveIndex >= game.moves.count {
            isFinished = true
            feedback = "Session complete."
        } else if revealedAnswer == nil {
            feedback = "Enter the notation for the highlighted move."
        } else {
            revealedAnswer = nil
        }
    }

    private func hint(for move: NotationMove, attemptsRemaining: Int) -> String {
        if attemptsRemaining == 2 {
            if move.tags.contains(.capture) { return "Not quite. Hint: this move is a capture." }
            if move.tags.contains(.checkmate) { return "Not quite. Hint: this move is checkmate." }
            if move.tags.contains(.check) { return "Not quite. Hint: this move gives check." }
            if move.tags.contains(.castling) { return "Not quite. Hint: this is castling." }
            if move.tags.contains(.promotion) { return "Not quite. Hint: this move promotes a pawn." }
            return "Not quite. Hint: focus on the moving piece and its legal destination."
        }

        return "Last try. Hint: \(pieceHint(for: move))"
    }

    private func explanation(for move: NotationMove) -> String {
        let tags = move.tags.map(\.displayName).joined(separator: ", ")
        return tags.isEmpty ? "Move from \(move.from) to \(move.to)." : tags
    }

    private func pieceHint(for move: NotationMove) -> String {
        guard let piece = FENParser.squares(from: move.fenBefore).first(where: { $0.coordinate == move.from })?.piece else {
            return "identify which piece is moving."
        }

        switch piece.kind {
        case .pawn:
            return "a pawn is moving."
        case .knight:
            return "a knight is moving."
        case .bishop:
            return "a bishop is moving."
        case .rook:
            return "a rook is moving."
        case .queen:
            return "the queen is moving."
        case .king:
            return "the king is moving."
        }
    }
}
