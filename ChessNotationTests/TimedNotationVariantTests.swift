import Testing
@testable import ChessNotation

struct TimedNotationVariantTests {
    @Test
    func sprintFinishesOnceAtDeadlineAndRejectsLaterSubmission() {
        let clock = TestMonotonicClock(now: 100)
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(variant: .sprint, initialDuration: 10),
            clock: clock
        )

        clock.advance(by: 10)
        #expect(session.refresh())
        #expect(session.isFinished)
        #expect(session.historySaveCount == 1)

        let accepted = session.submit(
            correct: true,
            submittedAt: clock.now,
            latency: 1,
            complexity: 1,
            usedHintOrReveal: false
        )

        #expect(!accepted)
        #expect(session.completedPrompts == 0)
        #expect(session.historySaveCount == 1)
    }

    @Test
    func accuracyRaceCompletesAtConfiguredPromptCount() {
        let clock = TestMonotonicClock()
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(
                variant: .accuracyRace,
                initialDuration: 60,
                promptCount: 2
            ),
            clock: clock
        )

        #expect(session.submit(correct: true, submittedAt: 1, latency: 1, complexity: 1, usedHintOrReveal: false))
        clock.advance(by: 2)
        #expect(session.submit(correct: false, submittedAt: 2, latency: 2, complexity: 2, usedHintOrReveal: true))

        #expect(session.isFinished)
        #expect(session.finishReason == .completed)
        #expect(session.completedPrompts == 2)
        #expect(session.correctPrompts == 1)
        #expect(session.result?.elapsed == 2)
    }

    @Test
    func survivalBonusAndPenaltyRemainBounded() {
        let clock = TestMonotonicClock()
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(
                variant: .survival,
                initialDuration: 10,
                survivalBonus: 5,
                survivalPenalty: 20,
                survivalMaximum: 12
            ),
            clock: clock
        )

        #expect(session.submit(correct: true, submittedAt: 1, latency: 1, complexity: 1, usedHintOrReveal: false))
        #expect(session.remainingTime == 12)

        clock.advance(by: 2)
        #expect(session.submit(correct: false, submittedAt: 2, latency: 1, complexity: 1, usedHintOrReveal: false))
        #expect(session.remainingTime == 0)
    }

    @Test
    func comboMultiplierCapsAndResets() {
        let clock = TestMonotonicClock()
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(
                variant: .combo,
                initialDuration: 60,
                comboStep: 0.5,
                comboMaximum: 2
            ),
            clock: clock
        )

        for timestamp in [1.0, 2.0, 3.0, 4.0] {
            #expect(session.submit(correct: true, submittedAt: timestamp, latency: 1, complexity: 1, usedHintOrReveal: false))
        }
        #expect(session.comboMultiplier == 2)

        #expect(session.submit(correct: false, submittedAt: 5, latency: 1, complexity: 1, usedHintOrReveal: false))
        #expect(session.comboMultiplier == 1)
    }

    @Test
    func scorerIsDeterministicAndCapsImplausiblyFastLatency() {
        let input = TimedScoreInput(
            correct: true,
            latency: 0.001,
            complexity: 20,
            streak: 100,
            usedHintOrReveal: false,
            multiplier: 1
        )

        let first = TimedNotationScorer.score(input)
        let second = TimedNotationScorer.score(input)

        #expect(first == second)
        #expect(first.speed == TimedNotationScorer.maximumSpeedScore)
        #expect(first.base == TimedNotationScorer.correctBaseScore)
    }

    @Test
    func skippedRefreshesDoNotAffectAuthoritativeRemainingTime() {
        let clock = TestMonotonicClock(now: 10)
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(variant: .sprint, initialDuration: 30),
            clock: clock
        )

        clock.advance(by: 17.5)

        #expect(session.remainingTime == 12.5)
        #expect(!session.isFinished)
    }

    @Test
    func submissionBeforeDeadlineIsAcceptedEvenBeforeDelayedRefresh() {
        let clock = TestMonotonicClock(now: 0)
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(variant: .sprint, initialDuration: 10),
            clock: clock
        )

        clock.advance(by: 12)
        let accepted = session.submit(
            correct: true,
            submittedAt: 9.9,
            latency: 1,
            complexity: 1,
            usedHintOrReveal: false
        )

        #expect(accepted)
        #expect(session.completedPrompts == 1)
    }

    @Test
    func submissionAtDeadlineIsRejected() {
        let clock = TestMonotonicClock(now: 0)
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(variant: .sprint, initialDuration: 10),
            clock: clock
        )

        let accepted = session.submit(
            correct: true,
            submittedAt: 10,
            latency: 1,
            complexity: 1,
            usedHintOrReveal: false
        )

        #expect(!accepted)
        #expect(session.completedPrompts == 0)
        #expect(session.historySaveCount == 1)
    }

    @Test
    func finishIsIdempotentAcrossCompetingPaths() {
        let clock = TestMonotonicClock()
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(variant: .sprint, initialDuration: 1),
            clock: clock
        )

        session.finish(reason: .userExited)
        session.finish(reason: .timedOut)
        _ = session.submit(correct: true, submittedAt: 0.5, latency: 1, complexity: 1, usedHintOrReveal: false)

        #expect(session.historySaveCount == 1)
        #expect(session.finishReason == .userExited)
    }

    @Test
    func pauseLifecycleAdjustsDeadlineExactly() {
        let clock = TestMonotonicClock()
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(
                variant: .sprint,
                initialDuration: 20,
                lifecyclePolicy: .pauseWhileInactive
            ),
            clock: clock
        )

        clock.advance(by: 5)
        session.becameInactive()
        clock.advance(by: 10)
        session.becameActive()

        #expect(session.remainingTime == 15)
    }

    @Test
    func continueLifecycleDoesNotAdjustDeadline() {
        let clock = TestMonotonicClock()
        let session = TimedNotationSession(
            configuration: TimedNotationConfiguration(
                variant: .sprint,
                initialDuration: 20,
                lifecyclePolicy: .continueAgainstDeadline
            ),
            clock: clock
        )

        clock.advance(by: 5)
        session.becameInactive()
        clock.advance(by: 10)
        session.becameActive()

        #expect(session.remainingTime == 5)
    }
}
