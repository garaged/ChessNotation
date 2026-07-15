import Testing
@testable import ChessNotation

struct TimerRefreshEfficiencyTests {
    @Test
    func oneThousandRefreshesOnlyObserveClockState() {
        FENParser.resetCacheForTesting()
        BundledGameLibraryService.resetCacheForTesting()
        _ = FENParser.squares(from: "startpos")

        let initialFENMetrics = FENParser.cacheMetrics
        let initialLibraryMetrics = BundledGameLibraryService.cacheMetrics
        let clock = TestMonotonicClock(now: 100)
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(
                variant: .sprint,
                initialDuration: 2_000
            ),
            clock: clock
        )
        let initialRemaining = session.remainingTime

        for _ in 0..<1_000 {
            clock.advance(by: 0.001)
            #expect(!session.refresh())
        }

        #expect(session.refreshMetrics == TimedRefreshMetrics(
            refreshCount: 1_000,
            timeoutTransitionCount: 0
        ))
        #expect(session.score == 0)
        #expect(session.completedPrompts == 0)
        #expect(session.correctPrompts == 0)
        #expect(session.currentStreak == 0)
        #expect(session.maximumStreak == 0)
        #expect(session.comboMultiplier == 1)
        #expect(session.difficultyStage == 1)
        #expect(session.historySaveCount == 0)
        #expect(session.finishReason == nil)
        #expect(session.sourceCategories.isEmpty)
        #expect(session.remainingTime < initialRemaining)
        #expect(session.remainingTime > 1_998)
        #expect(FENParser.cacheMetrics == initialFENMetrics)
        #expect(BundledGameLibraryService.cacheMetrics == initialLibraryMetrics)
    }

    @Test
    func repeatedExpiredRefreshesFinishExactlyOnce() {
        let clock = TestMonotonicClock(now: 20)
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(
                variant: .sprint,
                initialDuration: 5
            ),
            clock: clock
        )

        clock.advance(by: 5)
        #expect(session.refresh())
        #expect(session.refresh())
        #expect(session.refresh())

        #expect(session.refreshMetrics == TimedRefreshMetrics(
            refreshCount: 3,
            timeoutTransitionCount: 1
        ))
        #expect(session.isFinished)
        #expect(session.finishReason == .timedOut)
        #expect(session.historySaveCount == 1)
        #expect(session.completedPrompts == 0)
        #expect(session.score == 0)
    }

    @Test
    func libraryCacheMetricsResetWithoutDecodingContent() {
        BundledGameLibraryService.resetCacheForTesting()

        #expect(BundledGameLibraryService.cacheMetrics == GameLibraryCacheMetrics(
            repositoryCount: 0,
            hitCount: 0,
            missCount: 0,
            resourceDecodeCount: 0
        ))
    }
}
