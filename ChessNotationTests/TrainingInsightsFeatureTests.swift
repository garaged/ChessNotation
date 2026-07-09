import Foundation
import Testing
@testable import ChessNotation

private final class MemoryTrainingLibraryPreferencesStore: TrainingLibraryPreferencesStoring {
    var preferences = TrainingLibraryPreferences(recentLimit: 3)
    var saved: [TrainingLibraryPreferences] = []

    func loadPreferences() throws -> TrainingLibraryPreferences { preferences }

    func savePreferences(_ preferences: TrainingLibraryPreferences) throws {
        self.preferences = preferences
        saved.append(preferences)
    }
}

struct TrainingInsightsFeatureTests {
    @Test
    func presentationSelectsWeakCategoryAndFiltersMatchingGames() {
        let samples = [
            TrainingMetricSample(category: "captures", correct: 4, total: 10, averageLatency: 2),
            TrainingMetricSample(category: "checks", correct: 9, total: 10, averageLatency: 1)
        ]
        let games = [
            TrainingGameSummary(gameID: "game-a", title: "A", categories: ["captures"]),
            TrainingGameSummary(gameID: "game-b", title: "B", categories: ["checks"]),
            TrainingGameSummary(gameID: "game-c", title: "C", categories: ["captures", "checks"])
        ]

        let presentation = TrainingInsightsPresenter.presentation(
            samples: samples,
            games: games,
            preferences: TrainingLibraryPreferences(recentLimit: 3),
            minimumSampleCount: 5,
            excludingRecent: true
        )

        #expect(presentation.category == "captures")
        #expect(presentation.recommendedGameIDs == ["game-a", "game-c"])
        #expect(!presentation.usesGeneralFallback)
        #expect(presentation.detail.contains("40%"))
        #expect(presentation.accessibilitySummary.contains("Recommended"))
    }

    @Test
    func presentationFallsBackToMixedPracticeWhenHistoryIsSparse() {
        let samples = [TrainingMetricSample(category: "captures", correct: 1, total: 2, averageLatency: 2)]
        let games = [
            TrainingGameSummary(gameID: "game-a", title: "A", categories: ["captures"]),
            TrainingGameSummary(gameID: "game-b", title: "B", categories: ["checks"])
        ]

        let presentation = TrainingInsightsPresenter.presentation(
            samples: samples,
            games: games,
            preferences: TrainingLibraryPreferences(recentLimit: 3),
            minimumSampleCount: 5,
            excludingRecent: true
        )

        #expect(presentation.usesGeneralFallback)
        #expect(presentation.category == nil)
        #expect(presentation.recommendedGameIDs == ["game-a", "game-b"])
        #expect(presentation.title.contains("mixed"))
    }

    @Test
    func presentationExcludesRecentGamesButFallsBackWhenAllAreRecent() {
        let samples = [TrainingMetricSample(category: "captures", correct: 1, total: 10, averageLatency: 2)]
        let games = [
            TrainingGameSummary(gameID: "game-a", title: "A", categories: ["captures"]),
            TrainingGameSummary(gameID: "game-b", title: "B", categories: ["captures"])
        ]
        var preferences = TrainingLibraryPreferences(recentLimit: 3)
        preferences.recordRecent("game-a")

        let filtered = TrainingInsightsPresenter.presentation(
            samples: samples,
            games: games,
            preferences: preferences,
            minimumSampleCount: 5,
            excludingRecent: true
        )
        preferences.recordRecent("game-b")
        let fallback = TrainingInsightsPresenter.presentation(
            samples: samples,
            games: games,
            preferences: preferences,
            minimumSampleCount: 5,
            excludingRecent: true
        )

        #expect(filtered.recommendedGameIDs == ["game-b"])
        #expect(fallback.recommendedGameIDs == ["game-a", "game-b"])
    }

    @Test
    func preferencesStoreRoundTripsFavoritesAndRecentGames() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("training-preferences.json")
        let store = TrainingLibraryPreferencesStore(fileURL: url, recentLimit: 3)
        var preferences = TrainingLibraryPreferences(recentLimit: 3)
        preferences.setFavorite("game-a", isFavorite: true)
        preferences.recordRecent("game-b")

        try store.savePreferences(preferences)

        #expect(try store.loadPreferences() == preferences)
    }

    @Test
    func viewModelPersistsFavoritesAndRecentGamesThenRefreshesPresentation() {
        let store = MemoryTrainingLibraryPreferencesStore()
        let samples = [TrainingMetricSample(category: "captures", correct: 2, total: 10, averageLatency: 2)]
        let games = [
            TrainingGameSummary(gameID: "game-a", title: "A", categories: ["captures"]),
            TrainingGameSummary(gameID: "game-b", title: "B", categories: ["captures"])
        ]
        let viewModel = TrainingInsightsViewModel(
            samples: samples,
            games: games,
            store: store,
            minimumSampleCount: 5,
            recentLimit: 3,
            excludingRecent: true
        )

        viewModel.setFavorite("game-a", isFavorite: true, samples: samples, games: games)
        viewModel.recordRecent("game-a", samples: samples, games: games)

        #expect(viewModel.preferences.favoriteGameIDs == ["game-a"])
        #expect(viewModel.preferences.recentGameIDs == ["game-a"])
        #expect(viewModel.presentation.favoriteGameIDs == ["game-a"])
        #expect(viewModel.presentation.recommendedGameIDs == ["game-b"])
        #expect(store.saved.count == 2)
    }
}
