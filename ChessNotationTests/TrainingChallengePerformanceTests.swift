import Foundation
import Testing
@testable import ChessNotation

struct TrainingChallengePerformanceTests {
    @Test
    func catalogBuildsValidatedIndexOnceAndReusesIt() {
        let fixtures = makeChallenges(count: 200)
        let catalog = TrainingChallengeCatalog(challenges: fixtures)

        for _ in 0..<1_000 {
            #expect(catalog.index.challenges(difficulty: .beginner).count == 100)
            #expect(catalog.index.challenges(gameID: "game-3").count == 20)
        }

        #expect(catalog.indexBuildCount == 1)
        #expect(catalog.validationIssues.isEmpty)
    }

    @Test
    func representativeGenerationAndLookupStayWithinRegressionBudget() {
        let fixtures = makeChallenges(count: 500)
        let clock = ContinuousClock()
        let startedAt = clock.now
        let catalog = TrainingChallengeCatalog(challenges: fixtures)
        let generator = TrainingChallengeGenerator(
            challenges: catalog.index.all,
            randomizer: SeededChallengeRandomizer(seed: 2026)
        )

        for _ in 0..<1_000 {
            guard case .challenge = generator.next() else {
                Issue.record("Expected generated challenge")
                return
            }
            _ = catalog.index.challenges(moveTag: "capture")
        }

        let elapsed = startedAt.duration(to: clock.now)

        #expect(elapsed < .seconds(2))
        #expect(generator.retainedChallengeCount <= fixtures.count)
        #expect(catalog.indexBuildCount == 1)
    }

    private func makeChallenges(count: Int) -> [TrainingChallenge] {
        (0..<count).map { index in
            TrainingChallenge(
                id: TrainingChallengeID("challenge-\(index)"),
                kind: .notationMove,
                difficulty: index.isMultiple(of: 2) ? .beginner : .advanced,
                source: TrainingChallengeSource(
                    gameID: "game-\(index % 10)",
                    moveIndex: index,
                    opening: "Opening \(index % 5)",
                    moveTags: [index.isMultiple(of: 3) ? "capture" : "pawnMove"]
                ),
                promptReference: "fen-\(index)"
            )
        }
    }
}
