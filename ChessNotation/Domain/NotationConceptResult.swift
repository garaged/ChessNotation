import Foundation

nonisolated struct NotationConceptResult: Hashable, Codable {
    nonisolated enum Kind: String, Codable {
        case sanBuilder
        case positionRecall
    }

    let kind: Kind
    let difficulty: TrainingDifficulty
    let promptCount: Int
    let correctCount: Int
    let firstTryCount: Int
    let mistakeCategories: [String: Int]
    let averageLatency: TimeInterval
    let studyDuration: TimeInterval?
    let orientation: BoardOrientationPolicy
    let finishReason: TrainingFinishReason
}
