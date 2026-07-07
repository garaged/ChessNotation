import Foundation
import Testing
@testable import ChessNotation

struct TimedNotationResultTests {
    @Test
    func resultRoundTripsVariantConfigurationMetricsAndCategories() throws {
        let configuration = TimedNotationConfiguration(
            variant: .combo,
            initialDuration: 90,
            promptCount: 15,
            lifecyclePolicy: .pauseWhileInactive,
            comboStep: 0.5,
            comboMaximum: 2.5
        )
        let result = TimedNotationResult(
            variant: .combo,
            configuration: configuration,
            score: 1234,
            completedPrompts: 15,
            correctPrompts: 12,
            maximumStreak: 6,
            elapsed: 71.5,
            remaining: 18.5,
            difficultyStage: 3,
            finishReason: .completed,
            sourceCategories: [.capture, .check]
        )

        let data = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(TimedNotationResult.self, from: data)

        #expect(decoded == result)
    }

    @Test
    func frequentRefreshesDoNotChangePromptStateOrScore() {
        let clock = TestMonotonicClock()
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(variant: .sprint, initialDuration: 600),
            clock: clock
        )

        for _ in 0..<10_000 {
            _ = session.refresh()
        }

        #expect(session.completedPrompts == 0)
        #expect(session.correctPrompts == 0)
        #expect(session.score == 0)
        #expect(session.remainingTime == 600)
        #expect(!session.isFinished)
    }
}
