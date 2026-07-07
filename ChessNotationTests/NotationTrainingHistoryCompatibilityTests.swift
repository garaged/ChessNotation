import Foundation
import Testing
@testable import ChessNotation

struct NotationTrainingHistoryCompatibilityTests {
    @Test
    func legacyRecordLoadsWithDocumentedFullGameDefaults() throws {
        let legacyJSON = """
        {
          "promptCount": 12,
          "correctCount": 9,
          "firstTryCount": 7,
          "totalAttempts": 16,
          "hintsOrReveals": 2,
          "sourceGameIDs": ["opera-game-1858"]
        }
        """

        let result = try NotationTrainingHistoryCompatibility.decodeResult(
            from: try #require(legacyJSON.data(using: .utf8))
        )

        #expect(result.configuration.style == .fullGame)
        #expect(result.configuration.answerPolicy == .threeAttempts)
        #expect(result.configuration.progressionPolicy == .immediate)
        #expect(result.configuration.filter == NotationTrainingFilter())
        #expect(result.promptCount == 12)
        #expect(result.correctCount == 9)
        #expect(result.sourceGameIDs == ["opera-game-1858"])
        #expect(result.mistakeCategories.isEmpty)
    }

    @Test
    func currentRecordStillUsesCurrentSchema() throws {
        let current = NotationTrainingResult(
            configuration: NotationTrainingConfiguration(style: .randomPosition),
            finishReason: .completed,
            promptCount: 10,
            correctCount: 8,
            firstTryCount: 6,
            totalAttempts: 14,
            hintsOrReveals: 1,
            mistakeCategories: [.generic: 2],
            sourceGameIDs: ["game-a"]
        )
        let data = try JSONEncoder().encode(current)

        let decoded = try NotationTrainingHistoryCompatibility.decodeResult(from: data)

        #expect(decoded == current)
    }
}
