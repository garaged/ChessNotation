import Foundation
import Observation

struct TrainingGameSummary: Hashable, Codable, Sendable {
    let gameID: String
    let title: String
    let categories: Set<String>
}

struct TrainingRecommendationPresentation: Hashable, Sendable {
    let title: String
    let detail: String
    let category: String?
    let recommendedGameIDs: [String]
    let usesGeneralFallback: Bool
    let favoriteGameIDs: Set<String>
    let recentGameIDs: [String]

    var accessibilitySummary: String {
        var parts = [title, detail]
        if !recommendedGameIDs.isEmpty {
            parts.append("Recommended games: \(recommendedGameIDs.joined(separator: ", "))")
        }
        if !favoriteGameIDs.isEmpty {
            parts.append("Favorites: \(favoriteGameIDs.sorted().joined(separator: ", "))")
        }
        if !recentGameIDs.isEmpty {
            parts.append("Recently used: \(recentGameIDs.joined(separator: ", "))")
        }
        return parts.joined(separator: ". ")
    }
}

protocol TrainingLibraryPreferencesStoring {
    func loadPreferences() throws -> TrainingLibraryPreferences
    func savePreferences(_ preferences: TrainingLibraryPreferences) throws
}

struct TrainingLibraryPreferencesStore: TrainingLibraryPreferencesStoring {
    private let fileURL: URL
    private let recentLimit: Int
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileURL: URL? = nil, recentLimit: Int = 10) {
        self.recentLimit = recentLimit
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.fileURL = supportDirectory
                .appendingPathComponent("ChessNotation", isDirectory: true)
                .appendingPathComponent("training-library-preferences.json")
        }
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func loadPreferences() throws -> TrainingLibraryPreferences {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return TrainingLibraryPreferences(recentLimit: recentLimit)
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(TrainingLibraryPreferences.self, from: data)
    }

    func savePreferences(_ preferences: TrainingLibraryPreferences) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let data = try encoder.encode(preferences)
        try data.write(to: fileURL, options: [.atomic])
    }
}

enum TrainingInsightsPresenter {
    static func presentation(
        samples: [TrainingMetricSample],
        games: [TrainingGameSummary],
        preferences: TrainingLibraryPreferences,
        minimumSampleCount: Int,
        excludingRecent: Bool
    ) -> TrainingRecommendationPresentation {
        let eligibleCategories = Set(games.flatMap { $0.categories })
        let recommendation = TrainingInsightCalculator.recommendation(
            from: samples,
            eligibleCategories: eligibleCategories,
            minimumSampleCount: minimumSampleCount
        )
        let gameIDs: [String]
        if let category = recommendation.category {
            gameIDs = games
                .filter { $0.categories.contains(category) }
                .map(\.gameID)
        } else {
            gameIDs = games.map(\.gameID)
        }
        let eligibleGameIDs = preferences.eligibleGameIDs(from: gameIDs, excludingRecent: excludingRecent)
        let title = recommendation.usesGeneralFallback ? "Recommended: mixed practice" : "Recommended: \(recommendation.category ?? "practice")"
        return TrainingRecommendationPresentation(
            title: title,
            detail: recommendation.reason,
            category: recommendation.category,
            recommendedGameIDs: eligibleGameIDs,
            usesGeneralFallback: recommendation.usesGeneralFallback,
            favoriteGameIDs: preferences.favoriteGameIDs,
            recentGameIDs: preferences.recentGameIDs
        )
    }
}

@Observable
final class TrainingInsightsViewModel {
    private let store: TrainingLibraryPreferencesStoring
    private let minimumSampleCount: Int
    private let excludingRecent: Bool
    private(set) var preferences: TrainingLibraryPreferences
    private(set) var saveError: String?
    private(set) var presentation: TrainingRecommendationPresentation

    init(
        samples: [TrainingMetricSample],
        games: [TrainingGameSummary],
        store: TrainingLibraryPreferencesStoring,
        minimumSampleCount: Int = 5,
        recentLimit: Int = 10,
        excludingRecent: Bool = true
    ) {
        self.store = store
        self.minimumSampleCount = minimumSampleCount
        self.excludingRecent = excludingRecent
        self.preferences = (try? store.loadPreferences()) ?? TrainingLibraryPreferences(recentLimit: recentLimit)
        self.presentation = TrainingInsightsPresenter.presentation(
            samples: samples,
            games: games,
            preferences: preferences,
            minimumSampleCount: minimumSampleCount,
            excludingRecent: excludingRecent
        )
    }

    func refresh(samples: [TrainingMetricSample], games: [TrainingGameSummary]) {
        presentation = TrainingInsightsPresenter.presentation(
            samples: samples,
            games: games,
            preferences: preferences,
            minimumSampleCount: minimumSampleCount,
            excludingRecent: excludingRecent
        )
    }

    func setFavorite(_ gameID: String, isFavorite: Bool, samples: [TrainingMetricSample], games: [TrainingGameSummary]) {
        preferences.setFavorite(gameID, isFavorite: isFavorite)
        persist()
        refresh(samples: samples, games: games)
    }

    func recordRecent(_ gameID: String, samples: [TrainingMetricSample], games: [TrainingGameSummary]) {
        preferences.recordRecent(gameID)
        persist()
        refresh(samples: samples, games: games)
    }

    private func persist() {
        do {
            try store.savePreferences(preferences)
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
    }
}
