import Testing
@testable import ChessNotation

@Suite(.serialized)
struct FENCacheTests {
    @Test
    func repeatedFENRequestsReuseCachedBoard() {
        FENParser.resetCacheForTesting()

        let first = FENParser.squares(from: "startpos")
        let afterFirstParse = FENParser.cacheMetrics
        let second = FENParser.squares(from: FENParser.startPosition)
        let afterSecondParse = FENParser.cacheMetrics

        #expect(first == second)
        #expect(afterFirstParse.count == 1)
        #expect(afterFirstParse.missCount == 1)
        #expect(afterFirstParse.hitCount == 0)
        #expect(afterSecondParse.count == 1)
        #expect(afterSecondParse.missCount == 1)
        #expect(afterSecondParse.hitCount == 1)
    }

    @Test
    func cacheEvictsLeastRecentlyUsedBoardsAtConfiguredBound() {
        FENParser.resetCacheForTesting()

        for index in 0...FENParser.cacheCapacity {
            _ = FENParser.squares(from: fen(withWhitePawnFile: index % 8, marker: index))
        }

        let metrics = FENParser.cacheMetrics

        #expect(metrics.count == FENParser.cacheCapacity)
        #expect(metrics.missCount == FENParser.cacheCapacity + 1)
        #expect(metrics.evictionCount == 1)
    }

    @Test
    func accessingCachedBoardRefreshesItsRecency() {
        FENParser.resetCacheForTesting()

        let retainedFEN = fen(withWhitePawnFile: 0, marker: 0)
        _ = FENParser.squares(from: retainedFEN)

        for index in 1..<FENParser.cacheCapacity {
            _ = FENParser.squares(from: fen(withWhitePawnFile: index % 8, marker: index))
        }

        _ = FENParser.squares(from: retainedFEN)
        _ = FENParser.squares(from: fen(withWhitePawnFile: 7, marker: FENParser.cacheCapacity))
        let beforeRetainedLookup = FENParser.cacheMetrics
        _ = FENParser.squares(from: retainedFEN)
        let afterRetainedLookup = FENParser.cacheMetrics

        #expect(beforeRetainedLookup.count == FENParser.cacheCapacity)
        #expect(beforeRetainedLookup.evictionCount == 1)
        #expect(afterRetainedLookup.hitCount == beforeRetainedLookup.hitCount + 1)
        #expect(afterRetainedLookup.missCount == beforeRetainedLookup.missCount)
    }

    private func fen(withWhitePawnFile file: Int, marker: Int) -> String {
        let emptyBefore = file
        let emptyAfter = 7 - file
        let rank = [
            emptyBefore == 0 ? nil : String(emptyBefore),
            "P",
            emptyAfter == 0 ? nil : String(emptyAfter)
        ]
        .compactMap { $0 }
        .joined()

        return "8/8/8/8/8/8/\(rank)/8 w - - \(marker) 1"
    }
}
