import Foundation

struct GameLibraryFilters: Equatable {
    var searchText = ""
    var difficulty: DifficultyFilter = .all
    var opening: OpeningFilter = .all

    func apply(to games: [NotationGame]) -> [NotationGame] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return games.filter { game in
            difficulty.matches(game.difficulty)
                && opening.matches(game.opening)
                && matchesSearch(game: game, searchText: trimmedSearchText)
        }
    }

    func availableOpeningFilters(from games: [NotationGame]) -> [OpeningFilter] {
        let openings = Set(games.compactMap(\.opening).filter { !$0.isEmpty })
        return [.all] + openings.sorted().map { OpeningFilter(name: $0) }
    }

    private func matchesSearch(game: NotationGame, searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }

        let haystack = [
            game.title,
            game.white,
            game.black,
            game.opening ?? "",
            game.difficulty.rawValue
        ]
            .joined(separator: " ")

        return haystack.localizedCaseInsensitiveContains(searchText)
    }
}

enum DifficultyFilter: String, CaseIterable, Identifiable {
    case all
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    func matches(_ difficulty: Difficulty) -> Bool {
        switch self {
        case .all: return true
        case .beginner: return difficulty == .beginner
        case .intermediate: return difficulty == .intermediate
        case .advanced: return difficulty == .advanced
        }
    }
}

struct OpeningFilter: Hashable, Identifiable {
    static let all = Self(name: nil)

    let name: String?

    var id: String {
        name ?? "all"
    }

    var displayName: String {
        name ?? "All Openings"
    }
    func matches(_ opening: String?) -> Bool {
        guard let name else { return true }
        return opening == name
    }
}
