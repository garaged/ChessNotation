import Foundation

struct LegacyTimedNotationRecord: Hashable, Codable, Sendable {
    let durationSeconds: Int
    let timeUsedSeconds: Int
    let completedMoves: Int
    let accuracy: Double
    let finishReason: TrainingFinishReason
    let movesPerMinute: Double
}

enum TimedNotationCompatibility {
    static func mapLegacy(_ legacy: LegacyTimedNotationRecord) -> TimedNotationResult {
        TimedNotationResult(
            variant: .sprint,
            configuration: TimedNotationConfiguration(
                variant: .sprint,
                initialDuration: TimeInterval(legacy.durationSeconds),
                promptCount: max(1, legacy.completedMoves)
            ),
            score: 0,
            completedPrompts: legacy.completedMoves,
            correctPrompts: Int((Double(legacy.completedMoves) * legacy.accuracy).rounded()),
            maximumStreak: 0,
            elapsed: TimeInterval(legacy.timeUsedSeconds),
            remaining: TimeInterval(max(0, legacy.durationSeconds - legacy.timeUsedSeconds)),
            difficultyStage: 1,
            finishReason: legacy.finishReason,
            sourceCategories: []
        )
    }
}

struct TimedFeedbackPreferences: Hashable, Sendable {
    let reduceMotion: Bool
    let hapticsEnabled: Bool
}

struct TimedFeedbackPresentation: Hashable, Sendable {
    let text: String
    let symbolName: String
    let shouldAnimate: Bool
    let shouldTriggerHaptic: Bool
}

enum TimedFeedbackPolicy {
    static func lowTime(preferences: TimedFeedbackPreferences) -> TimedFeedbackPresentation {
        TimedFeedbackPresentation(
            text: "Low time",
            symbolName: "clock.badge.exclamationmark",
            shouldAnimate: !preferences.reduceMotion,
            shouldTriggerHaptic: preferences.hapticsEnabled
        )
    }

    static func correctness(
        correct: Bool,
        preferences: TimedFeedbackPreferences
    ) -> TimedFeedbackPresentation {
        TimedFeedbackPresentation(
            text: correct ? "Correct" : "Incorrect",
            symbolName: correct ? "checkmark.circle" : "xmark.circle",
            shouldAnimate: !preferences.reduceMotion,
            shouldTriggerHaptic: preferences.hapticsEnabled
        )
    }
}
