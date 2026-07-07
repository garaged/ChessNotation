import Foundation
import Testing
@testable import ChessNotation

struct TrainingInsightsTests {
    @Test
    func weakestCategoryUsesAccuracyLatencyAndStableTieBreak() throws {
        let samples = [
            TrainingMetricSample(category: "captures", correct: 8, total: 10, averageLatency: 1.0),
            TrainingMetricSample(category: "checks", correct: 5, total: 10, averageLatency: 1.2),
            TrainingMetricSample(category: "castling", correct: 5, total: 10, averageLatency: 1.6)
        ]

        let insight = try #require(TrainingInsightCalculator.weakestCategory(from: samples, minimumSampleCount: 5))

        #expect(insight.category == "castling")
        #expect(insight.sampleCount == 10)
        #expect(insight.accuracy == 0.5)
    }

    @Test
    func insufficientSamplesDoNotCreateWeaknessClaim() {
        let samples = [TrainingMetricSample(category: "promotion", correct: 0, total: 1, averageLatency: 5)]

        #expect(TrainingInsightCalculator.weakestCategory(from: samples, minimumSampleCount: 3) == nil)
    }

    @Test
    func recommendationUsesWeakEligibleCategory() {
        let samples = [
            TrainingMetricSample(category: "captures", correct: 4, total: 10, averageLatency: 2),
            TrainingMetricSample(category: "checks", correct: 8, total: 10, averageLatency: 1)
        ]

        let recommendation = TrainingInsightCalculator.recommendation(
            from: samples,
            eligibleCategories: ["captures", "checks"],
            minimumSampleCount: 5
        )

        #expect(recommendation.category == "captures")
        #expect(!recommendation.usesGeneralFallback)
        #expect(recommendation.reason.contains("40%"))
        #expect(recommendation.reason.contains("10 attempts"))
    }

    @Test
    func recommendationFallsBackWhenHistoryOrContentIsInsufficient() {
        let samples = [TrainingMetricSample(category: "captures", correct: 1, total: 2, averageLatency: 2)]
        let sparse = TrainingInsightCalculator.recommendation(from: samples, eligibleCategories: ["captures"], minimumSampleCount: 5)
        let unavailable = TrainingInsightCalculator.recommendation(
            from: [TrainingMetricSample(category: "captures", correct: 2, total: 10, averageLatency: 2)],
            eligibleCategories: ["checks"],
            minimumSampleCount: 5
        )

        #expect(sparse.usesGeneralFallback)
        #expect(unavailable.usesGeneralFallback)
        #expect(sparse.category == nil)
        #expect(unavailable.category == nil)
    }

    @Test
    func favoritesPersistAndCanBeRemoved() throws {
        var preferences = TrainingLibraryPreferences(recentLimit: 3)
        preferences.setFavorite("game-1", isFavorite: true)
        preferences.setFavorite("game-2", isFavorite: true)
        preferences.setFavorite("game-1", isFavorite: false)

        let data = try JSONEncoder().encode(preferences)
        let decoded = try JSONDecoder().decode(TrainingLibraryPreferences.self, from: data)

        #expect(decoded.favoriteGameIDs == ["game-2"])
    }

    @Test
    func recentHistoryIsUniqueOrderedAndBounded() {
        var preferences = TrainingLibraryPreferences(recentLimit: 3)
        preferences.recordRecent("game-1")
        preferences.recordRecent("game-2")
        preferences.recordRecent("game-3")
        preferences.recordRecent("game-1")
        preferences.recordRecent("game-4")

        #expect(preferences.recentGameIDs == ["game-4", "game-1", "game-3"])
    }

    @Test
    func recentExclusionFallsBackWhenItWouldRemoveEverything() {
        var preferences = TrainingLibraryPreferences(recentLimit: 3)
        preferences.recordRecent("game-1")
        preferences.recordRecent("game-2")

        #expect(preferences.eligibleGameIDs(from: ["game-1", "game-2", "game-3"], excludingRecent: true) == ["game-3"])
        #expect(preferences.eligibleGameIDs(from: ["game-1", "game-2"], excludingRecent: true) == ["game-1", "game-2"])
    }

    @Test
    func slowestCategoryRequiresMinimumSamples() throws {
        let samples = [
            TrainingMetricSample(category: "orientation-white", correct: 8, total: 10, averageLatency: 1.1),
            TrainingMetricSample(category: "orientation-black", correct: 8, total: 10, averageLatency: 1.8),
            TrainingMetricSample(category: "noise", correct: 0, total: 1, averageLatency: 99)
        ]

        let insight = try #require(TrainingInsightCalculator.slowestCategory(from: samples, minimumSampleCount: 5))

        #expect(insight.category == "orientation-black")
    }
}
