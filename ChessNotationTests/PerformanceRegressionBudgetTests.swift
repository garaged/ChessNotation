import Testing
@testable import ChessNotation

struct PerformanceRegressionBudgetTests {
    @Test
    func toleranceIsAppliedDeterministically() {
        let budget = PerformanceRegressionBudget(
            name: "Fixture",
            maximumOperationCount: 100,
            toleranceFraction: 0.10,
            remediation: "Inspect the fixture."
        )

        #expect(budget.toleratedMaximum == 110)
        #expect(budget.evaluate(actualOperationCount: 110).passed)
        #expect(!budget.evaluate(actualOperationCount: 111).passed)
    }

    @Test
    func failureMessageIsActionableAndContainsNoTimingClaim() {
        let budget = PerformanceRegressionBudget(
            name: "History aggregation passes",
            maximumOperationCount: 1,
            toleranceFraction: 0,
            remediation: "Cache the derived summary until history changes."
        )

        let result = budget.evaluate(actualOperationCount: 3)

        #expect(!result.passed)
        #expect(result.message.contains("used 3 operations"))
        #expect(result.message.contains("tolerated maximum of 1"))
        #expect(result.message.contains("Cache the derived summary"))
        #expect(!result.message.localizedCaseInsensitiveContains("milliseconds"))
        #expect(!result.message.localizedCaseInsensitiveContains("frame rate"))
    }

    @Test
    func repeatedFENRequestsStayWithinMissBudget() {
        FENParser.resetCacheForTesting()

        for _ in 0..<1_000 {
            _ = FENParser.squares(from: "startpos")
        }

        let result = ChessNotationPerformanceBudgets.repeatedFENLookupMisses.evaluate(
            actualOperationCount: FENParser.cacheMetrics.missCount
        )

        #expect(result.passed, Comment(rawValue: result.message))
        #expect(FENParser.cacheMetrics.hitCount == 999)
    }

    @Test
    func repeatedTimerRefreshesStayWithinTransitionBudget() {
        let clock = TestMonotonicClock(now: 0)
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(variant: .sprint, initialDuration: 1),
            clock: clock
        )
        clock.advance(by: 1)

        for _ in 0..<1_000 {
            _ = session.refresh()
        }

        let result = ChessNotationPerformanceBudgets.timerTimeoutTransitions.evaluate(
            actualOperationCount: session.refreshMetrics.timeoutTransitionCount
        )

        #expect(result.passed, Comment(rawValue: result.message))
        #expect(session.historySaveCount == 1)
    }

    @Test
    func rejectedGenerationStaysWithinConfiguredAttemptBudget() {
        let maximumAttempts = 7
        var calls = 0
        let generator = TrainingChallengeGenerator(
            challenges: Self.makeChallenges(count: 20),
            randomizer: SeededChallengeRandomizer(seed: 11),
            maximumAttempts: maximumAttempts,
            accepts: { _ in
                calls += 1
                return false
            }
        )

        #expect(generator.next() == .unavailable(.attemptLimitReached))

        let result = ChessNotationPerformanceBudgets.challengeGenerationAttempts(
            maximumAttempts: maximumAttempts
        ).evaluate(actualOperationCount: calls)

        #expect(result.passed, Comment(rawValue: result.message))
    }

    @Test
    func retainedCycleStaysWithinSourceBudgetAcrossLongRun() throws {
        let challenges = Self.makeChallenges(count: 23)
        let generator = TrainingChallengeGenerator(
            challenges: challenges,
            randomizer: SeededChallengeRandomizer(seed: 25)
        )
        let budget = ChessNotationPerformanceBudgets.retainedChallengeCycle(sourceCount: challenges.count)

        for _ in 0..<1_000 {
            guard case .challenge = generator.next() else {
                Issue.record("Expected a challenge from the long-run fixture")
                return
            }
            let result = budget.evaluate(actualOperationCount: generator.retainedChallengeCount)
            #expect(result.passed, Comment(rawValue: result.message))
        }
    }

    private static func makeChallenges(count: Int) -> [TrainingChallenge] {
        (0..<count).map { index in
            TrainingChallenge(
                id: TrainingChallengeID("budget-\(index)"),
                kind: .notationMove,
                difficulty: TrainingDifficulty.allCases[index % TrainingDifficulty.allCases.count],
                promptReference: "budget-prompt-\(index)"
            )
        }
    }
}
