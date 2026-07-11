import Foundation

enum FENParser {
    static let startPosition = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    static let cacheCapacity = 256

    private static let cache = FENBoardCache(capacity: cacheCapacity)

    static func squares(from fen: String) -> [BoardSquare] {
        let normalizedFen = fen == "startpos" ? startPosition : fen

        if let cached = cache.value(for: normalizedFen) {
            return cached
        }

        let parsed = parseSquares(from: normalizedFen)
        cache.insert(parsed, for: normalizedFen)
        return parsed
    }

    static var cacheMetrics: FENCacheMetrics {
        cache.metrics
    }

    static func resetCacheForTesting() {
        cache.removeAll()
    }

    private static func parseSquares(from normalizedFen: String) -> [BoardSquare] {
        let placement = normalizedFen.split(separator: " ").first.map(String.init) ?? normalizedFen
        let ranks = placement.split(separator: "/").map(String.init)

        var piecesByCoordinate: [String: ChessPiece] = [:]

        for (fenRankIndex, rankString) in ranks.enumerated() {
            let rank = 7 - fenRankIndex
            var file = 0

            for character in rankString {
                if let emptyCount = character.wholeNumberValue {
                    file += emptyCount
                } else if let piece = ChessPiece(fenCharacter: character) {
                    guard (0...7).contains(file), (0...7).contains(rank) else {
                        file += 1
                        continue
                    }

                    let coordinate = coordinate(file: file, rank: rank)
                    piecesByCoordinate[coordinate] = piece
                    file += 1
                }
            }
        }

        var squares: [BoardSquare] = []
        squares.reserveCapacity(64)

        for rank in (0...7).reversed() {
            for file in 0...7 {
                let coordinate = coordinate(file: file, rank: rank)
                squares.append(BoardSquare(file: file, rank: rank, piece: piecesByCoordinate[coordinate]))
            }
        }

        return squares
    }

    private static func coordinate(file: Int, rank: Int) -> String {
        let fileScalar = UnicodeScalar(97 + file)!
        return "\(Character(fileScalar))\(rank + 1)"
    }
}

struct FENCacheMetrics: Equatable {
    let count: Int
    let hitCount: Int
    let missCount: Int
    let evictionCount: Int
}

private final class FENBoardCache: @unchecked Sendable {
    private let capacity: Int
    private let lock = NSLock()
    private var values: [String: [BoardSquare]] = [:]
    private var recency: [String] = []
    private var hitCount = 0
    private var missCount = 0
    private var evictionCount = 0

    init(capacity: Int) {
        precondition(capacity > 0)
        self.capacity = capacity
    }

    func value(for key: String) -> [BoardSquare]? {
        lock.lock()
        defer { lock.unlock() }

        guard let value = values[key] else {
            missCount += 1
            return nil
        }

        hitCount += 1
        markMostRecent(key)
        return value
    }

    func insert(_ value: [BoardSquare], for key: String) {
        lock.lock()
        defer { lock.unlock() }

        if values[key] != nil {
            values[key] = value
            markMostRecent(key)
            return
        }

        if values.count >= capacity, let leastRecent = recency.first {
            values.removeValue(forKey: leastRecent)
            recency.removeFirst()
            evictionCount += 1
        }

        values[key] = value
        recency.append(key)
    }

    var metrics: FENCacheMetrics {
        lock.lock()
        defer { lock.unlock() }

        return FENCacheMetrics(
            count: values.count,
            hitCount: hitCount,
            missCount: missCount,
            evictionCount: evictionCount
        )
    }

    func removeAll() {
        lock.lock()
        defer { lock.unlock() }

        values.removeAll(keepingCapacity: true)
        recency.removeAll(keepingCapacity: true)
        hitCount = 0
        missCount = 0
        evictionCount = 0
    }

    private func markMostRecent(_ key: String) {
        if let index = recency.firstIndex(of: key) {
            recency.remove(at: index)
        }
        recency.append(key)
    }
}
