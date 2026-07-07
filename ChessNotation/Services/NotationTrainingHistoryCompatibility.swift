import Foundation

enum NotationTrainingHistoryCompatibility {
    private struct LegacyRecord: Decodable {
        let promptCount: Int?
        let correctCount: Int?
        let firstTryCount: Int?
        let totalAttempts: Int?
        let hintsOrReveals: Int?
        let sourceGameIDs: Set<String>?
    }

    static func decodeResult(from data: Data) throws -> NotationTrainingResult {
        if let current = try? JSONDecoder().decode(NotationTrainingResult.self, from: data) {
            return current
        }

        let legacy = try JSONDecoder().decode(LegacyRecord.self, from: data)
        return NotationTrainingResult(
            configuration: NotationTrainingConfiguration(
                style: .fullGame,
                answerPolicy: .threeAttempts,
                progressionPolicy: .immediate,
                promptCount: max(1, legacy.promptCount ?? 1)
            ),
            finishReason: .completed,
            promptCount: legacy.promptCount ?? 0,
            correctCount: legacy.correctCount ?? 0,
            firstTryCount: legacy.firstTryCount ?? 0,
            totalAttempts: legacy.totalAttempts ?? 0,
            hintsOrReveals: legacy.hintsOrReveals ?? 0,
            mistakeCategories: [:],
            sourceGameIDs: legacy.sourceGameIDs ?? []
        )
    }
}
