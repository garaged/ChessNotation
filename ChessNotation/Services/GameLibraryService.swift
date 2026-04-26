import Foundation

protocol GameLibraryProviding: Sendable {
    func loadGames() throws -> [NotationGame]
}

enum GameLibraryError: LocalizedError {
    case missingResource(String)

    var errorDescription: String? {
        switch self {
        case .missingResource(let name):
            return "Missing bundled game resource: \(name).json"
        }
    }
}

struct BundledGameLibraryService: GameLibraryProviding {
    private static let lock = NSLock()
    private static var cache: [CacheKey: [NotationGame]] = [:]

    private let resourceNames: [String]
    private let bundle: Bundle

    init(resourceNames: [String] = ["opera_game", "ChessNotationStarterGames", "ChessNotationMasterGames"], bundle: Bundle = .main) {
        self.resourceNames = resourceNames
        self.bundle = bundle
    }

    func loadGames() throws -> [NotationGame] {
        let cacheKey = CacheKey(resourceNames: resourceNames, bundlePath: bundle.bundlePath)
        let decoder = JSONDecoder()

        Self.lock.lock()
        if let cachedGames = Self.cache[cacheKey] {
            Self.lock.unlock()
            return cachedGames
        }
        Self.lock.unlock()

        let games = try resourceNames.flatMap { resourceName in
            let evaluatedResourceName = "\(resourceName).evaluated"
            guard let url = bundle.url(forResource: evaluatedResourceName, withExtension: "json")
                ?? bundle.url(forResource: resourceName, withExtension: "json") else {
                throw GameLibraryError.missingResource(resourceName)
            }
            let data = try Data(contentsOf: url, options: [.mappedIfSafe])
            return try Self.decodeGames(from: data, decoder: decoder)
        }

        Self.lock.lock()
        Self.cache[cacheKey] = games
        Self.lock.unlock()

        return games
    }

    private struct CacheKey: Hashable {
        let resourceNames: [String]
        let bundlePath: String
    }

    static func decodeGames(from data: Data, decoder: JSONDecoder = JSONDecoder()) throws -> [NotationGame] {
        if let game = try? decoder.decode(NotationGame.self, from: data) {
            return [game]
        }

        return try decoder.decode([NotationGame].self, from: data)
    }
}
