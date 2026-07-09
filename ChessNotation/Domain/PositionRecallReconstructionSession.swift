import Foundation

struct PositionRecallReconstructionConfiguration: Hashable, Codable, Sendable {
    let difficulty: TrainingDifficulty
    let orientation: BoardOrientationPolicy
    let promptLimit: Int
    let studyDuration: TimeInterval

    init(
        difficulty: TrainingDifficulty,
        orientation: BoardOrientationPolicy,
        promptLimit: Int = 10,
        studyDuration: TimeInterval
    ) {
        self.difficulty = difficulty
        self.orientation = orientation
        self.promptLimit = max(1, promptLimit)
        self.studyDuration = max(0, studyDuration)
    }
}

struct PositionRecallReconstructionSubmission: Hashable, Sendable {
    let evaluation: PositionRecallEvaluation
    let latency: TimeInterval
    let scoreAwarded: Int
    let streak: Int
}

final class PositionRecallReconstructionSession {
    private let configuration: PositionRecallReconstructionConfiguration
    private let generator: PositionRecallReconstructionPromptGenerator
    private let clock: MonotonicTimeProviding
    private var studyStartedAt: TimeInterval
    private var answerStartedAt: TimeInterval?
    private var latencies: [TimeInterval] = []
    private var exactCount = 0
    private var partialCount = 0
    private var missingCount = 0
    private var extraCount = 0
    private var wrongPieceCount = 0
    private var wrongSideCount = 0
    private var currentStreak = 0
    private var bestStreak = 0

    private(set) var phase: PositionRecallPhase = .studying
    private(set) var transitionCount = 0
    private(set) var currentPrompt: PositionRecallReconstructionPrompt
    private(set) var answer = PositionRecallReconstructionAnswer(pieces: [])
    private(set) var promptCount = 0
    private(set) var score = 0

    init?(
        configuration: PositionRecallReconstructionConfiguration,
        generator: PositionRecallReconstructionPromptGenerator,
        clock: MonotonicTimeProviding
    ) {
        guard let first = generator.next() else { return nil }
        self.configuration = configuration
        self.generator = generator
        self.clock = clock
        self.currentPrompt = first
        self.studyStartedAt = clock.now
    }

    func refresh() {
        guard phase == .studying else { return }
        guard clock.now - studyStartedAt >= configuration.studyDuration else { return }
        phase = .answering
        answerStartedAt = clock.now
        transitionCount += 1
    }

    func place(_ piece: PositionRecallPiece, at square: ChessSquare) {
        guard phase == .answering else { return }
        var pieces = answer.pieces.filter { $0.square != square }
        pieces.insert(PositionRecallPlacedPiece(square: square, piece: piece))
        answer = PositionRecallReconstructionAnswer(pieces: pieces)
    }

    func clear(_ square: ChessSquare) {
        guard phase == .answering else { return }
        answer = PositionRecallReconstructionAnswer(pieces: answer.pieces.filter { $0.square != square })
    }

    func submit(at timestamp: TimeInterval? = nil) -> PositionRecallReconstructionSubmission? {
        guard phase == .answering else { return nil }
        let submittedAt = timestamp ?? clock.now
        let latency = max(0, submittedAt - (answerStartedAt ?? studyStartedAt))
        let evaluation = PositionRecallEvaluation(answer: answer, expected: currentPrompt.expectedPieces)
        latencies.append(latency)
        promptCount += 1
        missingCount += evaluation.missing.count
        extraCount += evaluation.extra.count
        wrongPieceCount += evaluation.wrongPieceSquares.count
        wrongSideCount += evaluation.wrongSideSquares.count

        let award: Int
        if evaluation.isExact {
            exactCount += 1
            currentStreak += 1
            bestStreak = max(bestStreak, currentStreak)
            award = 100 + min(currentStreak - 1, 5) * 10
        } else {
            partialCount += 1
            currentStreak = 0
            let expectedCount = max(1, currentPrompt.expectedPieces.count)
            let matched = currentPrompt.expectedPieces.intersection(answer.pieces).count
            award = max(0, Int(Double(matched) / Double(expectedCount) * 50) - evaluation.extra.count * 5)
        }
        score += award
        phase = .finished
        return PositionRecallReconstructionSubmission(
            evaluation: evaluation,
            latency: latency,
            scoreAwarded: award,
            streak: currentStreak
        )
    }

    func advance() -> Bool {
        guard phase == .finished, promptCount < configuration.promptLimit, let next = generator.next() else { return false }
        currentPrompt = next
        answer = PositionRecallReconstructionAnswer(pieces: [])
        phase = .studying
        studyStartedAt = clock.now
        answerStartedAt = nil
        return true
    }

    func result(reason: TrainingFinishReason = .completed) -> PositionRecallSessionResult {
        let average = latencies.isEmpty ? 0 : latencies.reduce(0, +) / Double(latencies.count)
        return PositionRecallSessionResult(
            difficulty: configuration.difficulty,
            orientation: configuration.orientation,
            promptCount: promptCount,
            exactCount: exactCount,
            partialCount: partialCount,
            missingCount: missingCount,
            extraCount: extraCount,
            wrongPieceCount: wrongPieceCount,
            wrongSideCount: wrongSideCount,
            averageLatency: average,
            bestStreak: bestStreak,
            finishReason: reason
        )
    }

    func notationConceptResult(reason: TrainingFinishReason = .completed) -> NotationConceptResult {
        let result = result(reason: reason)
        return NotationConceptResult(
            kind: .positionRecall,
            difficulty: result.difficulty,
            promptCount: result.promptCount,
            correctCount: result.exactCount,
            firstTryCount: result.exactCount,
            mistakeCategories: [
                "missing": result.missingCount,
                "extra": result.extraCount,
                "wrongPiece": result.wrongPieceCount,
                "wrongSide": result.wrongSideCount
            ],
            averageLatency: result.averageLatency,
            studyDuration: configuration.studyDuration,
            orientation: result.orientation,
            finishReason: result.finishReason
        )
    }
}
