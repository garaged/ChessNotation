import Foundation

protocol GameLibraryProviding: Sendable {
    func loadGames() throws -> [NotationGame]
}

struct GameLibraryValidationIssue: Equatable, Sendable, CustomStringConvertible {
    enum Code: String, Sendable {
        case duplicateGameID
        case emptyRequiredString
        case emptyMoves
        case invalidMoveNumber
        case invalidSquare
        case inconsistentCoordinate
        case invalidFEN
    }

    let code: Code
    let gameID: String
    let moveIndex: Int?
    let field: String

    var description: String {
        var location = "game \(gameID.isEmpty ? "<empty>" : gameID)"
        if let moveIndex {
            location += ", move index \(moveIndex)"
        }
        return "\(code.rawValue) at \(location), field \(field)"
    }
}

enum GameLibraryError: LocalizedError {
    case missingResource(String)
    case invalidContent([GameLibraryValidationIssue])

    var errorDescription: String? {
        switch self {
        case .missingResource(let name):
            return "Missing bundled game resource: \(name).json"
        case .invalidContent(let issues):
            let summary = issues.prefix(5).map(\.description).joined(separator: "; ")
            let suffix = issues.count > 5 ? "; and \(issues.count - 5) more" : ""
            return "Invalid bundled game content: \(summary)\(suffix)"
        }
    }
}

struct BundledGameLibraryService: GameLibraryProviding {
    private static let lock = NSLock()
    private static var cache: [CacheKey: [NotationGame]] = [:]

    private let resourceNames: [String]
    private let bundle: Bundle

    init(resourceNames: [String] = ["opera_game", "ChessNotationStarterGames", "ChessNotationMasterGames", "ChessNotationModernGames"], bundle: Bundle = .main) {
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
            return try Self.decodeGames(from: data, decoder: decoder, validate: false)
        }

        try Self.validate(games)

        Self.lock.lock()
        Self.cache[cacheKey] = games
        Self.lock.unlock()

        return games
    }

    private struct CacheKey: Hashable {
        let resourceNames: [String]
        let bundlePath: String
    }

    static func decodeGames(
        from data: Data,
        decoder: JSONDecoder = JSONDecoder(),
        validate shouldValidate: Bool = true
    ) throws -> [NotationGame] {
        let games: [NotationGame]
        if let game = try? decoder.decode(NotationGame.self, from: data) {
            games = [game]
        } else {
            games = try decoder.decode([NotationGame].self, from: data)
        }

        if shouldValidate {
            try validate(games)
        }
        return games
    }

    static func validate(_ games: [NotationGame]) throws {
        var issues: [GameLibraryValidationIssue] = []
        var seenIDs: Set<String> = []

        for game in games {
            let gameID = game.id.trimmingCharacters(in: .whitespacesAndNewlines)
            if gameID.isEmpty {
                issues.append(issue(.emptyRequiredString, gameID: game.id, field: "id"))
            } else if !seenIDs.insert(gameID).inserted {
                issues.append(issue(.duplicateGameID, gameID: gameID, field: "id"))
            }

            for (field, value) in [
                ("title", game.title),
                ("white", game.white),
                ("black", game.black)
            ] where value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(issue(.emptyRequiredString, gameID: game.id, field: field))
            }

            if game.moves.isEmpty {
                issues.append(issue(.emptyMoves, gameID: game.id, field: "moves"))
            }

            for (index, move) in game.moves.enumerated() {
                if move.moveNumber < 1 {
                    issues.append(issue(.invalidMoveNumber, gameID: game.id, moveIndex: index, field: "moveNumber"))
                }

                for (field, value) in [
                    ("fenBefore", move.fenBefore),
                    ("from", move.from),
                    ("to", move.to),
                    ("san", move.san),
                    ("coordinate", move.coordinate)
                ] where value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    issues.append(issue(.emptyRequiredString, gameID: game.id, moveIndex: index, field: field))
                }

                if !isValidSquare(move.from) {
                    issues.append(issue(.invalidSquare, gameID: game.id, moveIndex: index, field: "from"))
                }
                if !isValidSquare(move.to) {
                    issues.append(issue(.invalidSquare, gameID: game.id, moveIndex: index, field: "to"))
                }
                if !move.coordinate.hasPrefix(move.from + move.to) {
                    issues.append(issue(.inconsistentCoordinate, gameID: game.id, moveIndex: index, field: "coordinate"))
                }
                if !isValidFEN(move.fenBefore) {
                    issues.append(issue(.invalidFEN, gameID: game.id, moveIndex: index, field: "fenBefore"))
                }
            }
        }

        if !issues.isEmpty {
            throw GameLibraryError.invalidContent(issues)
        }
    }

    private static func issue(
        _ code: GameLibraryValidationIssue.Code,
        gameID: String,
        moveIndex: Int? = nil,
        field: String
    ) -> GameLibraryValidationIssue {
        GameLibraryValidationIssue(code: code, gameID: gameID, moveIndex: moveIndex, field: field)
    }

    private static func isValidSquare(_ value: String) -> Bool {
        guard value.count == 2,
              let file = value.first,
              let rank = value.last else { return false }
        return ("a"..."h").contains(String(file)) && ("1"..."8").contains(String(rank))
    }

    private static func isValidFEN(_ value: String) -> Bool {
        if value == "startpos" { return true }
        let placement = value.split(separator: " ").first.map(String.init) ?? value
        let ranks = placement.split(separator: "/", omittingEmptySubsequences: false)
        guard ranks.count == 8 else { return false }

        let validPieces = Set("prnbqkPRNBQK")
        for rank in ranks {
            var width = 0
            for character in rank {
                if let emptyCount = character.wholeNumberValue, (1...8).contains(emptyCount) {
                    width += emptyCount
                } else if validPieces.contains(character) {
                    width += 1
                } else {
                    return false
                }
                if width > 8 { return false }
            }
            if width != 8 { return false }
        }
        return true
    }
}
