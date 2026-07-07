import Foundation
import Testing
@testable import ChessNotation

struct NotationTrainingVarietyTests {
    @Test
    func fullGameGeneratorPreservesSourceOrder() {
        let prompts = makePrompts()
        let generator = NotationTrainingPromptGenerator(
            prompts: prompts,
            style: .fullGame,
            randomizer: SeededChallengeRandomizer(seed: 1)
        )

        #expect(generator.next()?.challengeID == prompts[0].challengeID)
        #expect(generator.next()?.challengeID == prompts[1].challengeID)
        #expect(generator.next()?.challengeID == prompts[2].challengeID)
    }

    @Test
    func randomPositionUsesDeterministicNonSequentialGeneration() {
        let prompts = makePrompts()
        let first = NotationTrainingPromptGenerator(
            prompts: prompts,
            style: .randomPosition,
            randomizer: SeededChallengeRandomizer(seed: 42)
        )
        let second = NotationTrainingPromptGenerator(
            prompts: prompts,
            style: .randomPosition,
            randomizer: SeededChallengeRandomizer(seed: 42)
        )

        let firstIDs = (0..<6).compactMap { _ in first.next()?.challengeID }
        let secondIDs = (0..<6).compactMap { _ in second.next()?.challengeID }

        #expect(firstIDs == secondIDs)
        #expect(firstIDs.count == 6)
        #expect(zip(firstIDs, firstIDs.dropFirst()).allSatisfy { $0 != $1 })
    }

    @Test
    func focusedCaptureDrillContainsOnlyCaptures() {
        let planner = NotationTrainingPlanner(prompts: makePrompts())
        let configuration = NotationTrainingConfiguration(
            style: .focusedDrill,
            filter: NotationTrainingFilter(categories: [.capture])
        )

        let eligible = planner.eligiblePrompts(configuration: configuration)

        #expect(!eligible.isEmpty)
        #expect(eligible.allSatisfy { $0.categories.contains(.capture) })
    }

    @Test
    func openingDrillRespectsOpeningAndPlyLimit() {
        let planner = NotationTrainingPlanner(prompts: makePrompts())
        let configuration = NotationTrainingConfiguration(
            style: .openingDrill,
            filter: NotationTrainingFilter(opening: "Sicilian", maximumPly: 2)
        )

        let eligible = planner.eligiblePrompts(configuration: configuration)

        #expect(eligible.map(\.challengeID) == [TrainingChallengeID("a-1"), TrainingChallengeID("a-2")])
        #expect(eligible.allSatisfy { $0.opening == "Sicilian" && $0.moveIndex + 1 <= 2 })
    }

    @Test
    func mistakeReviewPrioritizesHistoryAndFallsBackWithoutHistory() {
        let prompts = makePrompts()
        let planner = NotationTrainingPlanner(prompts: prompts)
        let configuration = NotationTrainingConfiguration(style: .mistakeReview)

        let prioritized = planner.eligiblePrompts(
            configuration: configuration,
            mistakes: NotationMistakeProfile(categories: [.promotion])
        )
        let fallback = planner.eligiblePrompts(configuration: configuration)

        #expect(prioritized.count == 1)
        #expect(prioritized[0].categories.contains(.promotion))
        #expect(fallback == prompts)
    }

    @Test
    func oneAttemptPolicyResolvesAfterFirstWrongAnswer() {
        let configuration = NotationTrainingConfiguration(
            style: .randomPosition,
            answerPolicy: .oneAttempt,
            promptCount: 1
        )
        let session = makeSession(configuration: configuration)

        session.answerText = "e5"
        session.submitAnswer()

        #expect(session.isFinished)
        #expect(session.resolvedPromptCount == 1)
        #expect(session.correctPromptCount == 0)
        #expect(session.hintsOrReveals == 1)
    }

    @Test
    func threeAttemptPolicyKeepsChallengeActiveUntilExhausted() {
        let configuration = NotationTrainingConfiguration(
            style: .randomPosition,
            answerPolicy: .threeAttempts,
            promptCount: 1
        )
        let session = makeSession(configuration: configuration)

        session.answerText = "e5"
        session.submitAnswer()
        #expect(!session.isFinished)
        #expect(session.attemptsRemaining == 2)

        session.answerText = "d4"
        session.submitAnswer()
        #expect(!session.isFinished)
        #expect(session.attemptsRemaining == 1)

        session.answerText = "c4"
        session.submitAnswer()
        #expect(session.isFinished)
        #expect(session.resolvedPromptCount == 1)
    }

    @Test
    func missingCaptureFeedbackDoesNotRevealExpectedSAN() {
        let feedback = SemanticSANFeedback.feedback(expected: "Nxe5+", entered: "Ne5")

        #expect(feedback.category == .missingCapture)
        #expect(!feedback.message.contains("Nxe5+"))
        #expect(!feedback.message.contains("e5"))
    }

    @Test
    func unclassifiedAnswerUsesGenericNonSpoilingFeedback() {
        let feedback = SemanticSANFeedback.feedback(expected: "e4", entered: "banana")

        #expect(feedback.category == .generic)
        #expect(!feedback.message.contains("e4"))
    }

    @Test
    func zeroCandidatesReturnRecoverableResetFilter() {
        let planner = NotationTrainingPlanner(prompts: makePrompts())
        let configuration = NotationTrainingConfiguration(
            style: .openingDrill,
            filter: NotationTrainingFilter(opening: "Missing Opening")
        )

        switch planner.availability(configuration: configuration) {
        case .ready:
            Issue.record("Expected unavailable state")
        case let .unavailable(resetFilter):
            #expect(resetFilter == NotationTrainingFilter())
        }
    }

    @Test
    func drillResultRoundTripsAllConfigurationAndCounts() throws {
        let configuration = NotationTrainingConfiguration(
            style: .focusedDrill,
            answerPolicy: .threeAttempts,
            progressionPolicy: .feedbackPause,
            promptCount: 3,
            filter: NotationTrainingFilter(opening: "Sicilian", categories: [.capture])
        )
        let result = NotationTrainingResult(
            configuration: configuration,
            finishReason: .completed,
            promptCount: 3,
            correctCount: 2,
            firstTryCount: 1,
            totalAttempts: 5,
            hintsOrReveals: 1,
            mistakeCategories: [.missingCapture: 2],
            sourceGameIDs: ["game-a", "game-b"]
        )

        let data = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(NotationTrainingResult.self, from: data)

        #expect(decoded == result)
        #expect(decoded.schemaVersion == NotationTrainingResult.currentSchemaVersion)
    }

    @Test
    func accessibilityStatusExplainsStateWithoutSolution() {
        let configuration = NotationTrainingConfiguration(style: .randomPosition, promptCount: 1)
        let session = makeSession(configuration: configuration)

        let status = session.accessibilityStatus

        #expect(status.contains("Board orientation: White at bottom"))
        #expect(status.contains("attempts remaining"))
        #expect(status.contains("Opera Game"))
        #expect(!status.contains("Nxe5+"))
    }

    @Test
    func longRandomDrillKeepsBoundedGeneratorState() {
        let prompts = (0..<200).map { index in
            makePrompt(
                id: "long-\(index)",
                gameID: "game-\(index % 5)",
                opening: "Opening \(index % 4)",
                moveIndex: index,
                expectedSAN: "e4",
                categories: [.pawnMove]
            )
        }
        let generator = NotationTrainingPromptGenerator(
            prompts: prompts,
            style: .randomPosition,
            randomizer: SeededChallengeRandomizer(seed: 9)
        )

        for _ in 0..<1_000 {
            #expect(generator.next() != nil)
            #expect(generator.retainedPromptCount <= prompts.count)
        }
    }

    private func makeSession(configuration: NotationTrainingConfiguration) -> NotationDrillSession {
        let generator = NotationTrainingPromptGenerator(
            prompts: [makePrompts()[0]],
            style: configuration.style,
            randomizer: SeededChallengeRandomizer(seed: 1)
        )
        return NotationDrillSession(
            configuration: configuration,
            generator: generator,
            validator: { entered, expected in entered == expected }
        )
    }

    private func makePrompts() -> [NotationTrainingPrompt] {
        [
            makePrompt(id: "a-1", gameID: "game-a", opening: "Sicilian", moveIndex: 0, expectedSAN: "Nxe5+", categories: [.capture, .check]),
            makePrompt(id: "a-2", gameID: "game-a", opening: "Sicilian", moveIndex: 1, expectedSAN: "O-O", categories: [.castling]),
            makePrompt(id: "a-3", gameID: "game-a", opening: "Sicilian", moveIndex: 2, expectedSAN: "e8=Q", categories: [.promotion, .pawnMove]),
            makePrompt(id: "b-1", gameID: "game-b", opening: "French", moveIndex: 0, expectedSAN: "e4", categories: [.pawnMove])
        ]
    }

    private func makePrompt(
        id: String,
        gameID: String,
        opening: String,
        moveIndex: Int,
        expectedSAN: String,
        categories: Set<NotationMoveCategory>
    ) -> NotationTrainingPrompt {
        NotationTrainingPrompt(
            challengeID: TrainingChallengeID(id),
            gameID: gameID,
            gameTitle: gameID == "game-a" ? "Opera Game" : "Fixture Game",
            opening: opening,
            moveIndex: moveIndex,
            moveNumber: (moveIndex / 2) + 1,
            fenBefore: "fixture-fen-\(moveIndex)",
            expectedSAN: expectedSAN,
            categories: categories,
            difficulty: .intermediate
        )
    }
}
