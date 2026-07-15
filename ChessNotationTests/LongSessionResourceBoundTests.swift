import Testing
@testable import ChessNotation

struct LongSessionResourceBoundTests {
    @Test
    func tenThousandGeneratedChallengesRetainAtMostOneSourceCycle() throws {
        let challenges = makeChallenges(count: 37)
        let generator = TrainingChallengeGenerator(
            challenges: challenges,
            randomizer: SeededChallengeRandomizer(seed: 42),
            maximumAttempts: challenges.count
        )

        var maximumRetainedCount = generator.retainedChallengeCount
        var generatedIDs: Set<TrainingChallengeID> = []

        for _ in 0..<10_000 {
            let result = generator.next()
            guard case .challenge(let challenge) = result else {
                Issue.record("Expected a challenge throughout the long-session fixture, got \(result)")
                return
            }
            generatedIDs.insert(challenge.id)
            maximumRetainedCount = max(maximumRetainedCount, generator.retainedChallengeCount)
        }

        #expect(generatedIDs == Set(challenges.map(\.id)))
        #expect(maximumRetainedCount <= challenges.count - 1)
        #expect(generator.retainedChallengeCount < challenges.count)
    }

    @Test
    func cancellationPreventsFurtherGenerationWithoutAdvancingRetainedState() {
        let challenges = makeChallenges(count: 12)
        let generator = TrainingChallengeGenerator(
            challenges: challenges,
            randomizer: SeededChallengeRandomizer(seed: 7)
        )

        _ = generator.next()
        let retainedBeforeCancellation = generator.retainedChallengeCount
        generator.cancel()

        for _ in 0..<1_000 {
            #expect(generator.next() == .unavailable(.cancelled))
        }

        #expect(generator.retainedChallengeCount == retainedBeforeCancellation)
    }

    @Test
    func rejectedCandidatesRemainBoundedByAttemptBudget() {
        let challenges = makeChallenges(count: 19)
        let maximumAttempts = 5
        var predicateCalls = 0
        let generator = TrainingChallengeGenerator(
            challenges: challenges,
            randomizer: SeededChallengeRandomizer(seed: 99),
            maximumAttempts: maximumAttempts,
            accepts: { _ in
                predicateCalls += 1
                return false
            }
        )

        for iteration in 1...1_000 {
            #expect(generator.next() == .unavailable(.attemptLimitReached))
            #expect(predicateCalls == iteration * maximumAttempts)
            #expect(generator.retainedChallengeCount < challenges.count)
        }
    }

    private static func makeChallenges(count: Int) -> [TrainingChallenge] {
        (0..<count).map { index in
            TrainingChallenge(
                id: TrainingChallengeID("long-session-\(index)"),
                kind: .notationMove,
                difficulty: TrainingDifficulty.allCases[index % TrainingDifficulty.allCases.count],
                source: TrainingChallengeSource(
                    gameID: "fixture-game-\(index % 4)",
                    moveIndex: index,
                    opening: "Fixture Opening",
                    moveTags: [index.isMultiple(of: 2) ? "capture" : "quiet"]
                ),
                promptReference: "fixture-prompt-\(index)"
            )
        }
    }
}
