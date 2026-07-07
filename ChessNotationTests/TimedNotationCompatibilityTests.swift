import Testing
@testable import ChessNotation

struct TimedNotationCompatibilityTests {
    @Test
    func legacyTimedRecordMapsToSprintRepresentation() {
        let legacy = LegacyTimedNotationRecord(
            durationSeconds: 180,
            timeUsedSeconds: 75,
            completedMoves: 12,
            accuracy: 0.75,
            finishReason: .completed,
            movesPerMinute: 9.6
        )

        let result = TimedNotationCompatibility.mapLegacy(legacy)

        #expect(result.variant == .sprint)
        #expect(result.configuration.initialDuration == 180)
        #expect(result.elapsed == 75)
        #expect(result.remaining == 105)
        #expect(result.completedPrompts == 12)
        #expect(result.correctPrompts == 9)
        #expect(result.finishReason == .completed)
    }

    @Test
    func reducedMotionAndDisabledHapticsKeepTextAndSymbolFeedback() {
        let preferences = TimedFeedbackPreferences(reduceMotion: true, hapticsEnabled: false)

        let lowTime = TimedFeedbackPolicy.lowTime(preferences: preferences)
        let incorrect = TimedFeedbackPolicy.correctness(correct: false, preferences: preferences)

        #expect(lowTime.text == "Low time")
        #expect(!lowTime.symbolName.isEmpty)
        #expect(!lowTime.shouldAnimate)
        #expect(!lowTime.shouldTriggerHaptic)
        #expect(incorrect.text == "Incorrect")
        #expect(!incorrect.symbolName.isEmpty)
        #expect(!incorrect.shouldAnimate)
        #expect(!incorrect.shouldTriggerHaptic)
    }
}
