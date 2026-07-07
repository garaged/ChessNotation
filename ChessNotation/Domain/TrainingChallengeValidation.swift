import Foundation

struct TrainingChallengeValidationIssue: Hashable, Sendable, CustomStringConvertible {
    enum Reason: String, Hashable, Sendable {
        case emptyIdentifier
        case emptyPromptReference
        case negativeMoveIndex
    }

    let safeChallengeReference: String
    let reason: Reason

    var description: String {
        "Challenge \(safeChallengeReference): \(reason.rawValue)"
    }
}

struct TrainingChallengeIndexBuildResult: Sendable {
    let index: TrainingChallengeIndex
    let issues: [TrainingChallengeValidationIssue]
}

extension TrainingChallengeIndex {
    static func build(validating challenges: [TrainingChallenge]) -> TrainingChallengeIndexBuildResult {
        var valid: [TrainingChallenge] = []
        var issues: [TrainingChallengeValidationIssue] = []

        for (offset, challenge) in challenges.enumerated() {
            let safeReference = challenge.id.rawValue.isEmpty ? "at-index-\(offset)" : challenge.id.rawValue

            if challenge.id.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(
                    TrainingChallengeValidationIssue(
                        safeChallengeReference: safeReference,
                        reason: .emptyIdentifier
                    )
                )
                continue
            }

            if challenge.promptReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(
                    TrainingChallengeValidationIssue(
                        safeChallengeReference: safeReference,
                        reason: .emptyPromptReference
                    )
                )
                continue
            }

            if let moveIndex = challenge.source.moveIndex, moveIndex < 0 {
                issues.append(
                    TrainingChallengeValidationIssue(
                        safeChallengeReference: safeReference,
                        reason: .negativeMoveIndex
                    )
                )
                continue
            }

            valid.append(challenge)
        }

        return TrainingChallengeIndexBuildResult(
            index: TrainingChallengeIndex(challenges: valid),
            issues: issues
        )
    }
}

/// Prevents results from an older generation task from being applied to a newer session.
@MainActor
final class TrainingGenerationSessionGuard {
    struct Token: Hashable, Sendable {
        fileprivate let id: UUID
    }

    private var currentToken: Token?

    func beginSession() -> Token {
        let token = Token(id: UUID())
        currentToken = token
        return token
    }

    func invalidate() {
        currentToken = nil
    }

    func accepts(_ token: Token) -> Bool {
        currentToken == token
    }
}
