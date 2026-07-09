import Foundation

/// A stable, mode-independent identifier for a challenge within a training session.
nonisolated struct TrainingChallengeID: Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    var description: String { rawValue }
}

nonisolated enum TrainingChallengeKind: String, Codable, CaseIterable, Sendable {
    case notationMove
    case squareRecognition
    case pieceMovement
    case sanBuilder
    case positionRecall
}

nonisolated enum TrainingDifficulty: String, Codable, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced
}

nonisolated enum TrainingFinishReason: String, Codable, Sendable {
    case completed
    case timedOut
    case userExited
    case unavailableContent
}

nonisolated struct TrainingChallengeSource: Hashable, Codable, Sendable {
    let gameID: String?
    let moveIndex: Int?
    let opening: String?
    let moveTags: Set<String>

    init(
        gameID: String? = nil,
        moveIndex: Int? = nil,
        opening: String? = nil,
        moveTags: Set<String> = []
    ) {
        self.gameID = gameID
        self.moveIndex = moveIndex
        self.opening = opening
        self.moveTags = moveTags
    }
}

nonisolated struct TrainingChallenge: Hashable, Codable, Sendable {
    let id: TrainingChallengeID
    let kind: TrainingChallengeKind
    let difficulty: TrainingDifficulty
    let source: TrainingChallengeSource
    let promptReference: String

    init(
        id: TrainingChallengeID,
        kind: TrainingChallengeKind,
        difficulty: TrainingDifficulty,
        source: TrainingChallengeSource = TrainingChallengeSource(),
        promptReference: String
    ) {
        self.id = id
        self.kind = kind
        self.difficulty = difficulty
        self.source = source
        self.promptReference = promptReference
    }
}

nonisolated struct TrainingSessionConfiguration: Hashable, Codable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let mode: String
    let difficulty: TrainingDifficulty
    let filters: [String: String]
    let seedPolicy: String

    init(
        schemaVersion: Int = currentSchemaVersion,
        mode: String,
        difficulty: TrainingDifficulty,
        filters: [String: String] = [:],
        seedPolicy: String = "system"
    ) {
        self.schemaVersion = schemaVersion
        self.mode = mode
        self.difficulty = difficulty
        self.filters = filters
        self.seedPolicy = seedPolicy
    }
}

nonisolated struct TrainingSessionMetadata: Hashable, Codable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let configuration: TrainingSessionConfiguration
    let startedAt: Date
    let finishedAt: Date
    let finishReason: TrainingFinishReason

    init(
        schemaVersion: Int = currentSchemaVersion,
        configuration: TrainingSessionConfiguration,
        startedAt: Date,
        finishedAt: Date,
        finishReason: TrainingFinishReason
    ) {
        self.schemaVersion = schemaVersion
        self.configuration = configuration
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.finishReason = finishReason
    }
}

nonisolated protocol ChallengeRandomizing: AnyObject {
    func nextInt(upperBound: Int) -> Int
}

nonisolated final class SystemChallengeRandomizer: ChallengeRandomizing {
    func nextInt(upperBound: Int) -> Int {
        guard upperBound > 0 else { return 0 }
        return Int.random(in: 0..<upperBound)
    }
}

/// A small deterministic generator for reproducible tests and session replay.
nonisolated final class SeededChallengeRandomizer: ChallengeRandomizing {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    func nextInt(upperBound: Int) -> Int {
        guard upperBound > 0 else { return 0 }
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Int(state % UInt64(upperBound))
    }
}

nonisolated final class ScriptedChallengeRandomizer: ChallengeRandomizing {
    private let values: [Int]
    private var index = 0

    init(values: [Int]) {
        self.values = values
    }

    func nextInt(upperBound: Int) -> Int {
        guard upperBound > 0, !values.isEmpty else { return 0 }
        defer { index += 1 }
        return abs(values[index % values.count]) % upperBound
    }
}

nonisolated enum ChallengeGenerationUnavailableReason: String, Equatable, Sendable {
    case noEligibleChallenges
    case attemptLimitReached
    case cancelled
}

nonisolated enum ChallengeGenerationResult: Equatable, Sendable {
    case challenge(TrainingChallenge)
    case unavailable(ChallengeGenerationUnavailableReason)
}

/// Produces one shuffled cycle at a time and only retains the current cycle.
nonisolated final class ShuffledChallengeBag {
    private let source: [TrainingChallenge]
    private let randomizer: ChallengeRandomizing
    private var remaining: [TrainingChallenge] = []
    private var previousID: TrainingChallengeID?

    init(challenges: [TrainingChallenge], randomizer: ChallengeRandomizing) {
        source = challenges
        self.randomizer = randomizer
    }

    var retainedChallengeCount: Int { remaining.count }

    func next() -> TrainingChallenge? {
        guard !source.isEmpty else { return nil }
        if remaining.isEmpty {
            remaining = shuffled(source)
            avoidImmediateDuplicateAtCycleBoundary()
        }

        let challenge = remaining.removeFirst()
        previousID = challenge.id
        return challenge
    }

    private func shuffled(_ values: [TrainingChallenge]) -> [TrainingChallenge] {
        guard values.count > 1 else { return values }
        var copy = values
        for index in stride(from: copy.count - 1, through: 1, by: -1) {
            let swapIndex = randomizer.nextInt(upperBound: index + 1)
            if index != swapIndex {
                copy.swapAt(index, swapIndex)
            }
        }
        return copy
    }

    private func avoidImmediateDuplicateAtCycleBoundary() {
        guard
            source.count > 1,
            let previousID,
            remaining.first?.id == previousID,
            let replacementIndex = remaining.firstIndex(where: { $0.id != previousID })
        else {
            return
        }
        remaining.swapAt(0, replacementIndex)
    }
}

nonisolated final class TrainingChallengeGenerator {
    private let bag: ShuffledChallengeBag
    private let maximumAttempts: Int
    private let accepts: (TrainingChallenge) -> Bool
    private var isCancelled = false

    init(
        challenges: [TrainingChallenge],
        randomizer: ChallengeRandomizing = SystemChallengeRandomizer(),
        maximumAttempts: Int = 32,
        accepts: @escaping (TrainingChallenge) -> Bool = { _ in true }
    ) {
        bag = ShuffledChallengeBag(challenges: challenges, randomizer: randomizer)
        self.maximumAttempts = max(1, maximumAttempts)
        self.accepts = accepts
    }

    var retainedChallengeCount: Int { bag.retainedChallengeCount }

    func cancel() {
        isCancelled = true
    }

    func next() -> ChallengeGenerationResult {
        guard !isCancelled else { return .unavailable(.cancelled) }

        for _ in 0..<maximumAttempts {
            guard let candidate = bag.next() else {
                return .unavailable(.noEligibleChallenges)
            }
            if accepts(candidate) {
                return .challenge(candidate)
            }
        }

        return .unavailable(.attemptLimitReached)
    }
}

/// Immutable lookup structure built once and shared by prompt generators.
nonisolated struct TrainingChallengeIndex: Sendable {
    let all: [TrainingChallenge]

    private let byGameID: [String: [TrainingChallenge]]
    private let byDifficulty: [TrainingDifficulty: [TrainingChallenge]]
    private let byOpening: [String: [TrainingChallenge]]
    private let byMoveTag: [String: [TrainingChallenge]]

    init(challenges: [TrainingChallenge]) {
        all = challenges
        byGameID = Dictionary(grouping: challenges.compactMap { challenge in
            challenge.source.gameID.map { ($0, challenge) }
        }, by: { $0.0 }).mapValues { $0.map(\.1) }
        byDifficulty = Dictionary(grouping: challenges, by: \.difficulty)
        byOpening = Dictionary(grouping: challenges.compactMap { challenge in
            challenge.source.opening.map { ($0, challenge) }
        }, by: { $0.0 }).mapValues { $0.map(\.1) }

        var tags: [String: [TrainingChallenge]] = [:]
        for challenge in challenges {
            for tag in challenge.source.moveTags {
                tags[tag, default: []].append(challenge)
            }
        }
        byMoveTag = tags
    }

    func challenges(gameID: String) -> [TrainingChallenge] {
        byGameID[gameID] ?? []
    }

    func challenges(difficulty: TrainingDifficulty) -> [TrainingChallenge] {
        byDifficulty[difficulty] ?? []
    }

    func challenges(opening: String) -> [TrainingChallenge] {
        byOpening[opening] ?? []
    }

    func challenges(moveTag: String) -> [TrainingChallenge] {
        byMoveTag[moveTag] ?? []
    }
}
