import Foundation
import Observation

@Observable
final class GameViewModel {
    let game: NotationGame
    let mode: GameSessionMode

    private(set) var currentMoveIndex = 0
    private(set) var attemptsRemaining = 3
    private(set) var submittedAnswers: [String] = []
    private(set) var feedback: String = "Enter the notation for the highlighted move."
    private(set) var records: [MoveAttemptRecord] = []
    private(set) var isFinished = false
    private(set) var revealedAnswer: String?
    private(set) var remainingSeconds: Int?
    private(set) var finishReason: TimedSessionFinishReason = .completed

    var answerText = ""

    private var moveStartedAt = Date()

    init(game: NotationGame, mode: GameSessionMode = .untimed) {
        self.game = game
        self.mode = mode
        self.remainingSeconds = mode.durationSeconds
    }

    var currentMove: NotationMove? {
        guard currentMoveIndex < game.moves.count else { return nil }
        return game.moves[currentMoveIndex]
    }

    var isTimed: Bool { mode.isTimed }

    var timerText: String? {
        guard let remainingSeconds else { return nil }
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var isLowTime: Bool {
        guard let remainingSeconds else { return false }
        return remainingSeconds <= 10
    }

    var selectedDurationText: String? {
        guard let durationSeconds = mode.durationSeconds else { return nil }
        return Self.formattedDuration(seconds: durationSeconds)
    }

    var progressText: String {
        "Move \(min(currentMoveIndex + 1, game.moves.count)) of \(game.moves.count)"
    }

    var attemptsText: String {
        "Attempts remaining: \(attemptsRemaining)"
    }

    var progressAttemptsText: String {
        let attemptNumber = 4 - attemptsRemaining
        return "Move \(min(currentMoveIndex + 1, game.moves.count)) of \(game.moves.count) (attempt \(attemptNumber)/3)"
    }

    var summary: TrainingSessionSummary {
        TrainingSessionSummary(
            game: game,
            records: records,
            mode: mode,
            remainingSeconds: remainingSeconds,
            finishReason: finishReason
        )
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

    func appendToAnswer(_ value: String) {
        guard !isFinished else { return }
        answerText.append(value)
    }

    func removeLastAnswerCharacter() {
        guard !answerText.isEmpty else { return }
        answerText.removeLast()
    }

    func clearAnswer() {
        answerText.removeAll(keepingCapacity: true)
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

    func tickTimer() {
        guard !isFinished, var remainingSeconds else { return }
        remainingSeconds = max(remainingSeconds - 1, 0)
        self.remainingSeconds = remainingSeconds

        if remainingSeconds == 0 {
            finish(reason: .timedOut)
        }
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
        remainingSeconds = mode.durationSeconds
        finishReason = .completed
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
            finish(reason: .completed)
        } else if revealedAnswer == nil {
            feedback = "Enter the notation for the highlighted move."
        } else {
            revealedAnswer = nil
        }
    }

    private func finish(reason: TimedSessionFinishReason) {
        guard !isFinished else { return }
        isFinished = true
        finishReason = reason
        feedback = reason == .timedOut ? "Time expired." : "Session complete."
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

    private static func formattedDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        return minutes == 1 ? "1 minute" : "\(minutes) minutes"
    }
}
