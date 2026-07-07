import Testing
@testable import ChessNotation

struct NotationTrainingDuplicateIDTests {
    @Test
    func duplicateChallengeIdentitiesDoNotCrashGeneratorSetup() {
        let first = NotationTrainingPrompt(
            challengeID: TrainingChallengeID("duplicate"),
            gameID: "game-a",
            gameTitle: "Game A",
            opening: "Opening A",
            moveIndex: 0,
            moveNumber: 1,
            fenBefore: "fen-a",
            expectedSAN: "e4",
            categories: [.pawnMove],
            difficulty: .beginner
        )
        let second = NotationTrainingPrompt(
            challengeID: TrainingChallengeID("duplicate"),
            gameID: "game-b",
            gameTitle: "Game B",
            opening: "Opening B",
            moveIndex: 0,
            moveNumber: 1,
            fenBefore: "fen-b",
            expectedSAN: "d4",
            categories: [.pawnMove],
            difficulty: .beginner
        )

        let planner = NotationTrainingPlanner(prompts: [first, second])
        let eligible = planner.eligiblePrompts(
            configuration: NotationTrainingConfiguration(style: .randomPosition)
        )

        #expect(eligible.count == 2)
    }
}
