import Foundation

struct TimedScoreTotals: Hashable, Codable, Sendable {
    var base = 0
    var speed = 0
    var complexity = 0
    var streak = 0
    var hintRevealPenalty = 0
    var finalTotal = 0

    mutating func add(_ breakdown: TimedScoreBreakdown) {
        base += breakdown.base
        speed += breakdown.speed
        complexity += breakdown.complexity
        streak += breakdown.streak
        hintRevealPenalty += breakdown.hintRevealPenalty
        finalTotal += breakdown.finalTotal
    }
}

struct TimedLegacyMetrics: Hashable, Codable, Sendable {
    let durationSeconds: Int
    let timeUsedSeconds: Int
    let completedMoves: Int
    let accuracy: Double
    let movesPerMinute: Double
}

struct TimedNotationCompletedResult: Hashable, Codable, Sendable {
    let result: TimedNotationResult
    let scoreTotals: TimedScoreTotals
    let promptLatencies: [TimeInterval]
    let legacyMetrics: TimedLegacyMetrics?

    var averageLatency: TimeInterval {
        guard !promptLatencies.isEmpty else { return 0 }
        return promptLatencies.reduce(0, +) / Double(promptLatencies.count)
    }

    var accuracy: Double {
        guard result.completedPrompts > 0 else { return 0 }
        return Double(result.correctPrompts) / Double(result.completedPrompts)
    }

    var movesPerMinute: Double {
        if let legacyMetrics { return legacyMetrics.movesPerMinute }
        guard result.elapsed > 0 else { return 0 }
        return Double(result.completedPrompts) / result.elapsed * 60
    }
}

struct TimedPersonalBest: Hashable, Codable, Sendable {
    let variant: TimedNotationVariant
    let score: Int
    let elapsed: TimeInterval
    let completedPrompts: Int
    let accuracy: Double
}

enum TimedPersonalBestPolicy {
    static func candidate(from completed: TimedNotationCompletedResult) -> TimedPersonalBest {
        TimedPersonalBest(
            variant: completed.result.variant,
            score: completed.result.score,
            elapsed: completed.result.elapsed,
            completedPrompts: completed.result.completedPrompts,
            accuracy: completed.accuracy
        )
    }

    static func isBetter(_ candidate: TimedPersonalBest, than existing: TimedPersonalBest?) -> Bool {
        guard let existing else { return true }
        guard candidate.variant == existing.variant else { return false }

        switch candidate.variant {
        case .accuracyRace:
            if candidate.accuracy != existing.accuracy { return candidate.accuracy > existing.accuracy }
            if candidate.completedPrompts != existing.completedPrompts {
                return candidate.completedPrompts > existing.completedPrompts
            }
            return candidate.elapsed < existing.elapsed
        case .sprint, .survival, .combo:
            if candidate.score != existing.score { return candidate.score > existing.score }
            if candidate.accuracy != existing.accuracy { return candidate.accuracy > existing.accuracy }
            return candidate.completedPrompts > existing.completedPrompts
        }
    }
}

extension TimedNotationCompatibility {
    static func completedLegacy(_ legacy: LegacyTimedNotationRecord) -> TimedNotationCompletedResult {
        let mapped = mapLegacy(legacy)
        return TimedNotationCompletedResult(
            result: mapped,
            scoreTotals: TimedScoreTotals(finalTotal: mapped.score),
            promptLatencies: [],
            legacyMetrics: TimedLegacyMetrics(
                durationSeconds: legacy.durationSeconds,
                timeUsedSeconds: legacy.timeUsedSeconds,
                completedMoves: legacy.completedMoves,
                accuracy: legacy.accuracy,
                movesPerMinute: legacy.movesPerMinute
            )
        )
    }
}
