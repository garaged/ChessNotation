import Foundation

/// A stable, mode-independent identifier for a challenge within a training session.
nonisolated struct TrainingChallengeID: Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    var description: String { rawValue }
}

enum TrainingChallengeKind: String, Codable, CaseIterable, Sendable {
    case notationMove
    case squareRecognition
    case pieceMovement
    case sanBuilder
    case positionRecall
}

enum TrainingDifficulty: String, Codable, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced
}

enum TrainingFinishReason: String, Codable, Sendable {
    case completed
    case timedOut
    case userExited
    case unavailableContent
}

struct TrainingChallengeSource: Hashable, Codable, Sendable {
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

struct TrainingChallenge: Hashable, Codable, Sendable {
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

struct TrainingSessionConfiguration: Hashable, Codable, Sendable {
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

struct TrainingSessionMetadata: Hashable, Codable, Sendable {
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
