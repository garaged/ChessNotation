import Foundation

struct TrainingMetricSample: Hashable, Codable {
    let category: String
    let correct: Int
    let total: Int
    let averageLatency: TimeInterval

    var accuracy: Double {
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total)
    }
}

struct TrainingInsight: Hashable, Codable {
    let category: String
    let sampleCount: Int
    let accuracy: Double
    let averageLatency: TimeInterval
}

struct TrainingRecommendation: Hashable, Codable {
    let category: String?
    let reason: String
    let usesGeneralFallback: Bool
}

enum TrainingInsightCalculator {
    static func weakestCategory(
        from samples: [TrainingMetricSample],
        minimumSampleCount: Int
    ) -> TrainingInsight? {
        samples
            .filter { $0.total >= minimumSampleCount }
            .sorted {
                if $0.accuracy != $1.accuracy { return $0.accuracy < $1.accuracy }
                if $0.averageLatency != $1.averageLatency { return $0.averageLatency > $1.averageLatency }
                return $0.category < $1.category
            }
            .first
            .map {
                TrainingInsight(
                    category: $0.category,
                    sampleCount: $0.total,
                    accuracy: $0.accuracy,
                    averageLatency: $0.averageLatency
                )
            }
    }

    static func slowestCategory(
        from samples: [TrainingMetricSample],
        minimumSampleCount: Int
    ) -> TrainingInsight? {
        samples
            .filter { $0.total >= minimumSampleCount }
            .sorted {
                if $0.averageLatency != $1.averageLatency { return $0.averageLatency > $1.averageLatency }
                if $0.accuracy != $1.accuracy { return $0.accuracy < $1.accuracy }
                return $0.category < $1.category
            }
            .first
            .map {
                TrainingInsight(
                    category: $0.category,
                    sampleCount: $0.total,
                    accuracy: $0.accuracy,
                    averageLatency: $0.averageLatency
                )
            }
    }

    static func recommendation(
        from samples: [TrainingMetricSample],
        eligibleCategories: Set<String>,
        minimumSampleCount: Int
    ) -> TrainingRecommendation {
        if let weakest = weakestCategory(from: samples, minimumSampleCount: minimumSampleCount),
           eligibleCategories.contains(weakest.category) {
            let percent = Int((weakest.accuracy * 100).rounded())
            return TrainingRecommendation(
                category: weakest.category,
                reason: "Practice \(weakest.category): \(percent)% accuracy across \(weakest.sampleCount) attempts.",
                usesGeneralFallback: false
            )
        }

        return TrainingRecommendation(
            category: nil,
            reason: "Practice a general mixed session to build more history.",
            usesGeneralFallback: true
        )
    }
}

struct TrainingLibraryPreferences: Hashable, Codable {
    var favoriteGameIDs: Set<String> = []
    var recentGameIDs: [String] = []
    let recentLimit: Int

    mutating func setFavorite(_ gameID: String, isFavorite: Bool) {
        if isFavorite {
            favoriteGameIDs.insert(gameID)
        } else {
            favoriteGameIDs.remove(gameID)
        }
    }

    mutating func recordRecent(_ gameID: String) {
        recentGameIDs.removeAll { $0 == gameID }
        recentGameIDs.insert(gameID, at: 0)
        if recentGameIDs.count > recentLimit {
            recentGameIDs.removeLast(recentGameIDs.count - recentLimit)
        }
    }

    func eligibleGameIDs(from allGameIDs: [String], excludingRecent: Bool) -> [String] {
        guard excludingRecent else { return allGameIDs }
        let filtered = allGameIDs.filter { !recentGameIDs.contains($0) }
        return filtered.isEmpty ? allGameIDs : filtered
    }
}
