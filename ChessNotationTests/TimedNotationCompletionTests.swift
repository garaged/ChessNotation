import Foundation
import Testing
@testable import ChessNotation

struct TimedNotationCompletionTests {
    @Test
    func scoreTotalsAccumulateEveryComponent() {
        var totals = TimedScoreTotals()
        totals.add(TimedScoreBreakdown(base: 100, speed: 20, complexity: 10, streak: 5, hintRevealPenalty: 0, finalTotal: 135))
        totals.add(TimedScoreBreakdown(base: 100, speed: 15, complexity: 5, streak: 10, hintRevealPenalty: 60, finalTotal: 70))

        #expect(totals.base == 200)
        #expect(totals.speed == 35)
        #expect(totals.complexity == 15)
        #expect(totals.streak == 15)
        #expect(totals.hintRevealPenalty == 60)
        #expect(totals.finalTotal == 205)
    }

    @Test
    func completedResultRoundTripsScoreLatencyAndMetrics() throws {
        let result = TimedNotationResult(
            variant: .combo,
            configuration: TimedNotationConfiguration(variant: .combo, initialDuration: 60),
            score: 250,
            completedPrompts: 2,
            correctPrompts: 1,
            maximumStreak: 1,
            elapsed: 30,
            remaining: 30,
            difficultyStage: 1,
            finishReason: .completed,
            sourceCategories: [.capture]
        )
        let completed = TimedNotationCompletedResult(
            result: result,
            scoreTotals: TimedScoreTotals(base: 200, speed: 30, complexity: 20, streak: 10, hintRevealPenalty: 10, finalTotal: 250),
            promptLatencies: [1, 3],
            legacyMetrics: nil
        )

        #expect(completed.averageLatency == 2)
        #expect(completed.accuracy == 0.5)
        #expect(completed.movesPerMinute == 4)

        let data = try JSONEncoder().encode(completed)
        #expect(try JSONDecoder().decode(TimedNotationCompletedResult.self, from: data) == completed)
    }

    @Test
    func legacyMappingPreservesMovesPerMinuteAndOriginalMetrics() {
        let legacy = LegacyTimedNotationRecord(
            durationSeconds: 60,
            timeUsedSeconds: 30,
            completedMoves: 12,
            accuracy: 0.75,
            finishReason: .completed,
            movesPerMinute: 24
        )

        let completed = TimedNotationCompatibility.completedLegacy(legacy)

        #expect(completed.result.variant == .sprint)
        #expect(completed.movesPerMinute == 24)
        #expect(completed.legacyMetrics?.completedMoves == 12)
        #expect(completed.legacyMetrics?.accuracy == 0.75)
    }

    @Test
    func personalBestComparisonIsVariantSpecific() {
        let sprint = TimedPersonalBest(variant: .sprint, score: 500, elapsed: 60, completedPrompts: 10, accuracy: 0.8)
        let betterSprint = TimedPersonalBest(variant: .sprint, score: 600, elapsed: 60, completedPrompts: 9, accuracy: 0.7)
        let race = TimedPersonalBest(variant: .accuracyRace, score: 100, elapsed: 40, completedPrompts: 10, accuracy: 0.9)
        let fasterRace = TimedPersonalBest(variant: .accuracyRace, score: 90, elapsed: 35, completedPrompts: 10, accuracy: 0.9)

        #expect(TimedPersonalBestPolicy.isBetter(betterSprint, than: sprint))
        #expect(TimedPersonalBestPolicy.isBetter(fasterRace, than: race))
        #expect(!TimedPersonalBestPolicy.isBetter(race, than: sprint))
    }

    @Test
    func personalBestCandidateUsesCompletedResultMetrics() {
        let result = TimedNotationResult(
            variant: .survival,
            configuration: TimedNotationConfiguration(variant: .survival, initialDuration: 30),
            score: 800,
            completedPrompts: 20,
            correctPrompts: 15,
            maximumStreak: 6,
            elapsed: 45,
            remaining: 0,
            difficultyStage: 5,
            finishReason: .timedOut,
            sourceCategories: [.check]
        )
        let completed = TimedNotationCompletedResult(result: result, scoreTotals: TimedScoreTotals(finalTotal: 800), promptLatencies: [], legacyMetrics: nil)
        let candidate = TimedPersonalBestPolicy.candidate(from: completed)

        #expect(candidate.variant == .survival)
        #expect(candidate.score == 800)
        #expect(candidate.completedPrompts == 20)
        #expect(candidate.accuracy == 0.75)
    }
}
