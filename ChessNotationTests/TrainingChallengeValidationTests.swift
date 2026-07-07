import Testing
@testable import ChessNotation

struct TrainingChallengeValidationTests {
    @Test
    func invalidCandidatesAreReportedWhileValidCandidatesRemainIndexed() {
        let valid = TrainingChallenge(
            id: TrainingChallengeID("valid"),
            kind: .notationMove,
            difficulty: .beginner,
            source: TrainingChallengeSource(gameID: "game-a", moveIndex: 0),
            promptReference: "startpos"
        )
        let emptyID = TrainingChallenge(
            id: TrainingChallengeID(""),
            kind: .notationMove,
            difficulty: .beginner,
            promptReference: "startpos"
        )
        let emptyPrompt = TrainingChallenge(
            id: TrainingChallengeID("empty-prompt"),
            kind: .notationMove,
            difficulty: .beginner,
            promptReference: "   "
        )
        let negativeIndex = TrainingChallenge(
            id: TrainingChallengeID("negative-index"),
            kind: .notationMove,
            difficulty: .beginner,
            source: TrainingChallengeSource(gameID: "game-b", moveIndex: -1),
            promptReference: "startpos"
        )

        let result = TrainingChallengeIndex.build(
            validating: [valid, emptyID, emptyPrompt, negativeIndex]
        )

        #expect(result.index.all == [valid])
        #expect(result.issues.map(\.reason) == [
            .emptyIdentifier,
            .emptyPromptReference,
            .negativeMoveIndex
        ])
    }

    @Test
    @MainActor
    func olderSessionTokenCannotMutateReplacementSession() {
        let guardrail = TrainingGenerationSessionGuard()
        let oldToken = guardrail.beginSession()
        let replacementToken = guardrail.beginSession()

        #expect(!guardrail.accepts(oldToken))
        #expect(guardrail.accepts(replacementToken))

        guardrail.invalidate()
        #expect(!guardrail.accepts(replacementToken))
    }

    @Test
    func validationDiagnosticsContainOnlySafeReferenceAndReason() {
        let challenge = TrainingChallenge(
            id: TrainingChallengeID("safe-id"),
            kind: .notationMove,
            difficulty: .advanced,
            source: TrainingChallengeSource(gameID: "game-a", moveIndex: -1),
            promptReference: "entered-answer-must-not-appear-in-diagnostic"
        )

        let result = TrainingChallengeIndex.build(validating: [challenge])
        let diagnostic = result.issues[0].description

        #expect(diagnostic.contains("safe-id"))
        #expect(diagnostic.contains("negativeMoveIndex"))
        #expect(!diagnostic.contains("entered-answer-must-not-appear-in-diagnostic"))
        #expect(!diagnostic.contains("/Users/"))
        #expect(!diagnostic.lowercased().contains("token"))
    }
}
