import Foundation
import Testing
@testable import ChessNotation

struct TrainingChallengeFoundationTests {
    @Test
    func identicalSeedProducesIdenticalSequence() {
        let fixtures = makeChallenges(count: 6)
        let first = TrainingChallengeGenerator(
            challenges: fixtures,
            randomizer: SeededChallengeRandomizer(seed: 42)
        )
        let second = TrainingChallengeGenerator(
            challenges: fixtures,
            randomizer: SeededChallengeRandomizer(seed: 42)
        )

        let firstIDs = nextIDs(from: first, count: 12)
        let secondIDs = nextIDs(from: second, count: 12)

        #expect(firstIDs == secondIDs)
    }

    @Test
    func generatorAvoidsImmediateDuplicatesWhenAlternativesExist() {
        let generator = TrainingChallengeGenerator(
            challenges: makeChallenges(count: 4),
            randomizer: ScriptedChallengeRandomizer(values: [0])
        )

        let ids = nextIDs(from: generator, count: 20)

        for pair in zip(ids, ids.dropFirst()) {
            #expect(pair.0 != pair.1)
        }
    }

    @Test
    func shuffledBagVisitsEveryEligibleChallengeBeforeRepeating() {
        let fixtures = makeChallenges(count: 8)
        let generator = TrainingChallengeGenerator(
            challenges: fixtures,
            randomizer: SeededChallengeRandomizer(seed: 7)
        )

        let firstCycle = nextIDs(from: generator, count: fixtures.count)

        #expect(Set(firstCycle) == Set(fixtures.map(\.id)))
        #expect(firstCycle.count == Set(firstCycle).count)
    }

    @Test
    func oneEligibleChallengeCanRepeatWithoutFailure() {
        let fixture = makeChallenges(count: 1)
        let generator = TrainingChallengeGenerator(challenges: fixture)

        let ids = nextIDs(from: generator, count: 4)

        #expect(ids == Array(repeating: fixture[0].id, count: 4))
    }

    @Test
    func emptyGeneratorReturnsTypedUnavailableReason() {
        let generator = TrainingChallengeGenerator(challenges: [])

        #expect(generator.next() == .unavailable(.noEligibleChallenges))
    }

    @Test
    func rejectedCandidatesStopAtAttemptLimit() {
        var evaluationCount = 0
        let generator = TrainingChallengeGenerator(
            challenges: makeChallenges(count: 3),
            randomizer: SeededChallengeRandomizer(seed: 3),
            maximumAttempts: 5,
            accepts: { _ in
                evaluationCount += 1
                return false
            }
        )

        #expect(generator.next() == .unavailable(.attemptLimitReached))
        #expect(evaluationCount == 5)
    }

    @Test
    func cancellationPreventsFurtherGeneration() {
        let generator = TrainingChallengeGenerator(challenges: makeChallenges(count: 2))

        generator.cancel()

        #expect(generator.next() == .unavailable(.cancelled))
    }

    @Test
    func generatorRetainsAtMostOneBoundedCycle() {
        let fixtures = makeChallenges(count: 10)
        let generator = TrainingChallengeGenerator(
            challenges: fixtures,
            randomizer: SeededChallengeRandomizer(seed: 9)
        )

        for _ in 0..<1_000 {
            _ = generator.next()
            #expect(generator.retainedChallengeCount <= fixtures.count)
        }
    }

    @Test
    func immutableIndexLooksUpSupportedDimensions() {
        let challenges = [
            makeChallenge(
                id: "one",
                difficulty: .beginner,
                gameID: "game-a",
                opening: "Opening A",
                tags: ["capture", "check"]
            ),
            makeChallenge(
                id: "two",
                difficulty: .advanced,
                gameID: "game-b",
                opening: "Opening B",
                tags: ["promotion"]
            ),
            makeChallenge(
                id: "three",
                difficulty: .beginner,
                gameID: "game-a",
                opening: "Opening A",
                tags: ["capture"]
            )
        ]
        let index = TrainingChallengeIndex(challenges: challenges)

        #expect(index.challenges(gameID: "game-a").map(\.id) == [TrainingChallengeID("one"), TrainingChallengeID("three")])
        #expect(index.challenges(difficulty: .beginner).count == 2)
        #expect(index.challenges(opening: "Opening B").map(\.id) == [TrainingChallengeID("two")])
        #expect(index.challenges(moveTag: "capture").count == 2)
        #expect(index.challenges(moveTag: "unknown").isEmpty)
    }

    @Test
    func sessionMetadataRoundTripsAllRequiredFields() throws {
        let configuration = TrainingSessionConfiguration(
            mode: "randomPosition",
            difficulty: .intermediate,
            filters: ["opening": "Sicilian", "tag": "capture"],
            seedPolicy: "seed:42"
        )
        let metadata = TrainingSessionMetadata(
            configuration: configuration,
            startedAt: Date(timeIntervalSince1970: 100),
            finishedAt: Date(timeIntervalSince1970: 160),
            finishReason: .completed
        )

        let data = try JSONEncoder().encode(metadata)
        let decoded = try JSONDecoder().decode(TrainingSessionMetadata.self, from: data)

        #expect(decoded == metadata)
        #expect(decoded.schemaVersion == TrainingSessionMetadata.currentSchemaVersion)
        #expect(decoded.configuration.schemaVersion == TrainingSessionConfiguration.currentSchemaVersion)
    }

    @Test
    func challengeContainsRenderAndValidationReferenceWithoutGlobalLookup() {
        let challenge = makeChallenge(
            id: "game-a:12",
            difficulty: .advanced,
            gameID: "game-a",
            opening: "Test Opening",
            tags: ["check"]
        )

        #expect(challenge.kind == .notationMove)
        #expect(challenge.source.moveIndex == 12)
        #expect(challenge.promptReference == "fixture-fen-12")
        #expect(challenge.source.moveTags == ["check"])
    }

    private func nextIDs(from generator: TrainingChallengeGenerator, count: Int) -> [TrainingChallengeID] {
        (0..<count).compactMap { _ in
            guard case let .challenge(challenge) = generator.next() else { return nil }
            return challenge.id
        }
    }

    private func makeChallenges(count: Int) -> [TrainingChallenge] {
        (0..<count).map { index in
            makeChallenge(
                id: "challenge-\(index)",
                difficulty: index.isMultiple(of: 2) ? .beginner : .intermediate,
                gameID: "game-\(index % 2)",
                opening: "Opening \(index % 3)",
                tags: [index.isMultiple(of: 2) ? "capture" : "pawnMove"]
            )
        }
    }

    private func makeChallenge(
        id: String,
        difficulty: TrainingDifficulty,
        gameID: String,
        opening: String,
        tags: Set<String>
    ) -> TrainingChallenge {
        let moveIndex = Int(id.split(separator: ":").last ?? "0") ?? 0
        return TrainingChallenge(
            id: TrainingChallengeID(id),
            kind: .notationMove,
            difficulty: difficulty,
            source: TrainingChallengeSource(
                gameID: gameID,
                moveIndex: moveIndex,
                opening: opening,
                moveTags: tags
            ),
            promptReference: "fixture-fen-\(moveIndex)"
        )
    }
}
