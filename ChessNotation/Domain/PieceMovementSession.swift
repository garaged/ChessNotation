import Foundation

struct PieceMovementConfiguration: Hashable, Codable, Sendable {
    let pieces: Set<TrainingPiece>
    let difficulty: TrainingDifficulty
    let orientation: BoardOrientationPolicy
    let promptLimit: Int
    let allowPawnDoubleStep: Bool

    init(
        pieces: Set<TrainingPiece>,
        difficulty: TrainingDifficulty,
        orientation: BoardOrientationPolicy,
        promptLimit: Int = 10,
        allowPawnDoubleStep: Bool = false
    ) {
        self.pieces = pieces.isEmpty ? Set(TrainingPiece.allCases) : pieces
        self.difficulty = difficulty
        self.orientation = orientation
        self.promptLimit = max(1, promptLimit)
        self.allowPawnDoubleStep = allowPawnDoubleStep
    }
}

final class PieceMovementPromptGenerator {
    private let configuration: PieceMovementConfiguration
    private let randomizer: ChallengeRandomizing
    private let maximumAttempts: Int
    private var promptIndex = 0
    private var previousSignature: String?

    init(
        configuration: PieceMovementConfiguration,
        randomizer: ChallengeRandomizing,
        maximumAttempts: Int = 64
    ) {
        self.configuration = configuration
        self.randomizer = randomizer
        self.maximumAttempts = max(1, maximumAttempts)
    }

    func next() -> PieceMovementPrompt? {
        let pieces = configuration.pieces.sorted { $0.rawValue < $1.rawValue }
        guard !pieces.isEmpty else { return nil }

        for _ in 0..<maximumAttempts {
            let piece = pieces[randomizer.nextInt(upperBound: pieces.count)]
            let side: TrainingSide = randomizer.nextInt(upperBound: 2) == 0 ? .white : .black
            let source = SquareRecognitionPromptFactory.allSquares[randomizer.nextInt(upperBound: 64)]
            let orientation = resolvedOrientation()
            let occupancy = makeOccupancy(source: source, difficulty: configuration.difficulty)

            guard let prompt = PieceMovementPromptFactory.makePrompt(
                piece: piece,
                side: side,
                source: source,
                occupancy: occupancy,
                orientation: orientation,
                difficulty: configuration.difficulty,
                allowPawnDoubleStep: configuration.allowPawnDoubleStep
            ) else { continue }

            let signature = Self.signature(for: prompt)
            if signature == previousSignature { continue }
            previousSignature = signature
            promptIndex += 1
            return prompt
        }
        return nil
    }

    private func resolvedOrientation() -> BoardOrientationPolicy {
        switch configuration.orientation {
        case .white, .black:
            return configuration.orientation
        case .alternating:
            return promptIndex.isMultiple(of: 2) ? .white : .black
        }
    }

    private func makeOccupancy(
        source: ChessSquare,
        difficulty: TrainingDifficulty
    ) -> PieceMovementOccupancy {
        guard difficulty != .beginner else { return PieceMovementOccupancy() }

        let candidates = SquareRecognitionPromptFactory.allSquares.filter { $0 != source }
        let blockerCount = difficulty == .intermediate ? 1 : 3
        let enemyCount = difficulty == .intermediate ? 1 : 2
        var available = candidates
        var friendly: Set<ChessSquare> = []
        var enemy: Set<ChessSquare> = []

        for _ in 0..<blockerCount where !available.isEmpty {
            let index = randomizer.nextInt(upperBound: available.count)
            friendly.insert(available.remove(at: index))
        }
        for _ in 0..<enemyCount where !available.isEmpty {
            let index = randomizer.nextInt(upperBound: available.count)
            enemy.insert(available.remove(at: index))
        }
        return PieceMovementOccupancy(friendly: friendly, enemy: enemy)
    }

    private static func signature(for prompt: PieceMovementPrompt) -> String {
        let friendly = prompt.occupancy.friendly.map(\.description).sorted().joined(separator: ",")
        let enemy = prompt.occupancy.enemy.map(\.description).sorted().joined(separator: ",")
        return "\(prompt.piece.rawValue)|\(prompt.side.rawValue)|\(prompt.source)|\(friendly)|\(enemy)"
    }
}

struct PieceMovementEvaluation: Hashable, Sendable {
    let submission: PieceMovementSubmission
    let latency: TimeInterval
    let scoreAwarded: Int
    let streak: Int
}

final class PieceMovementSession {
    private let configuration: PieceMovementConfiguration
    private let generator: PieceMovementPromptGenerator
    private let clock: MonotonicTimeProviding
    private var promptStartedAt: TimeInterval
    private var latencies: [TimeInterval] = []
    private var seenPieces: Set<TrainingPiece> = []
    private var currentStreak = 0
    private var bestStreak = 0
    private var exactCount = 0
    private var partialCount = 0
    private var missingCount = 0
    private var extraCount = 0
    private(set) var score = 0
    private(set) var promptCount = 0
    private(set) var selected: Set<ChessSquare> = []
    private(set) var currentPrompt: PieceMovementPrompt
    private(set) var inputLocked = false

    init?(
        configuration: PieceMovementConfiguration,
        generator: PieceMovementPromptGenerator,
        clock: MonotonicTimeProviding
    ) {
        guard let first = generator.next() else { return nil }
        self.configuration = configuration
        self.generator = generator
        self.clock = clock
        self.currentPrompt = first
        self.promptStartedAt = clock.now
        self.seenPieces.insert(first.piece)
    }

    func toggle(_ square: ChessSquare) {
        guard !inputLocked else { return }
        if selected.contains(square) { selected.remove(square) } else { selected.insert(square) }
    }

    func submit(at timestamp: TimeInterval) -> PieceMovementEvaluation? {
        guard !inputLocked else { return nil }
        inputLocked = true
        let submission = PieceMovementSubmission(selected: selected, expected: currentPrompt.expectedDestinations)
        let latency = max(0, timestamp - promptStartedAt)
        latencies.append(latency)
        promptCount += 1
        missingCount += submission.missing.count
        extraCount += submission.extra.count

        let award: Int
        if submission.isExact {
            exactCount += 1
            currentStreak += 1
            bestStreak = max(bestStreak, currentStreak)
            award = 100 + min(currentStreak - 1, 5) * 10
        } else {
            partialCount += 1
            currentStreak = 0
            let expectedCount = max(1, currentPrompt.expectedDestinations.count)
            let matched = currentPrompt.expectedDestinations.intersection(selected).count
            award = max(0, Int(Double(matched) / Double(expectedCount) * 50) - submission.extra.count * 5)
        }
        score += award
        return PieceMovementEvaluation(submission: submission, latency: latency, scoreAwarded: award, streak: currentStreak)
    }

    func advance() -> Bool {
        guard inputLocked, promptCount < configuration.promptLimit, let next = generator.next() else { return false }
        currentPrompt = next
        seenPieces.insert(next.piece)
        selected = []
        inputLocked = false
        promptStartedAt = clock.now
        return true
    }

    func result(reason: TrainingFinishReason = .completed) -> PieceMovementSessionResult {
        let average = latencies.isEmpty ? 0 : latencies.reduce(0, +) / Double(latencies.count)
        return PieceMovementSessionResult(
            pieceTypes: seenPieces,
            difficulty: configuration.difficulty,
            orientation: configuration.orientation,
            promptCount: promptCount,
            exactCount: exactCount,
            partialCount: partialCount,
            missingSelectionCount: missingCount,
            extraSelectionCount: extraCount,
            averageLatency: average,
            bestStreak: bestStreak,
            finishReason: reason
        )
    }
}
