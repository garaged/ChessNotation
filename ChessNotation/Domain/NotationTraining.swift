import Foundation

enum NotationTrainingStyle: String, Codable, CaseIterable, Sendable {
    case fullGame
    case randomPosition
    case focusedDrill
    case openingDrill
    case mistakeReview
}

enum NotationAnswerPolicy: Int, Codable, CaseIterable, Sendable {
    case oneAttempt = 1
    case threeAttempts = 3
}

enum NotationProgressionPolicy: String, Codable, CaseIterable, Sendable {
    case immediate
    case feedbackPause
}

enum NotationMoveCategory: String, Codable, CaseIterable, Hashable, Sendable {
    case capture
    case check
    case checkmate
    case castling
    case promotion
    case pawnMove
    case pieceMove
    case disambiguation
}

struct NotationTrainingPrompt: Hashable, Codable, Sendable {
    let challengeID: TrainingChallengeID
    let gameID: String
    let gameTitle: String
    let opening: String
    let moveIndex: Int
    let moveNumber: Int
    let fenBefore: String
    let expectedSAN: String
    let categories: Set<NotationMoveCategory>
    let difficulty: TrainingDifficulty

    init(
        challengeID: TrainingChallengeID,
        gameID: String,
        gameTitle: String,
        opening: String,
        moveIndex: Int,
        moveNumber: Int,
        fenBefore: String,
        expectedSAN: String,
        categories: Set<NotationMoveCategory>,
        difficulty: TrainingDifficulty
    ) {
        self.challengeID = challengeID
        self.gameID = gameID
        self.gameTitle = gameTitle
        self.opening = opening
        self.moveIndex = moveIndex
        self.moveNumber = moveNumber
        self.fenBefore = fenBefore
        self.expectedSAN = expectedSAN
        self.categories = categories
        self.difficulty = difficulty
    }
}

struct NotationTrainingFilter: Hashable, Codable, Sendable {
    var opening: String?
    var difficulty: TrainingDifficulty?
    var categories: Set<NotationMoveCategory>
    var maximumPly: Int?

    init(
        opening: String? = nil,
        difficulty: TrainingDifficulty? = nil,
        categories: Set<NotationMoveCategory> = [],
        maximumPly: Int? = nil
    ) {
        self.opening = opening
        self.difficulty = difficulty
        self.categories = categories
        self.maximumPly = maximumPly
    }

    func accepts(_ prompt: NotationTrainingPrompt) -> Bool {
        if let opening, prompt.opening != opening { return false }
        if let difficulty, prompt.difficulty != difficulty { return false }
        if !categories.isEmpty, categories.isDisjoint(with: prompt.categories) { return false }
        if let maximumPly, prompt.moveIndex + 1 > maximumPly { return false }
        return true
    }
}

struct NotationTrainingConfiguration: Hashable, Codable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let style: NotationTrainingStyle
    let answerPolicy: NotationAnswerPolicy
    let progressionPolicy: NotationProgressionPolicy
    let promptCount: Int
    let filter: NotationTrainingFilter

    init(
        schemaVersion: Int = currentSchemaVersion,
        style: NotationTrainingStyle,
        answerPolicy: NotationAnswerPolicy = .threeAttempts,
        progressionPolicy: NotationProgressionPolicy = .immediate,
        promptCount: Int = 10,
        filter: NotationTrainingFilter = NotationTrainingFilter()
    ) {
        self.schemaVersion = schemaVersion
        self.style = style
        self.answerPolicy = answerPolicy
        self.progressionPolicy = progressionPolicy
        self.promptCount = max(1, promptCount)
        self.filter = filter
    }
}

struct NotationMistakeProfile: Hashable, Codable, Sendable {
    let challengeIDs: Set<TrainingChallengeID>
    let categories: Set<NotationMoveCategory>

    init(
        challengeIDs: Set<TrainingChallengeID> = [],
        categories: Set<NotationMoveCategory> = []
    ) {
        self.challengeIDs = challengeIDs
        self.categories = categories
    }
}

enum NotationTrainingAvailability: Equatable, Sendable {
    case ready([NotationTrainingPrompt])
    case unavailable(resetFilter: NotationTrainingFilter)
}

struct NotationTrainingPlanner {
    static let defaultOpeningPlyLimit = 16

    let prompts: [NotationTrainingPrompt]

    func eligiblePrompts(
        configuration: NotationTrainingConfiguration,
        mistakes: NotationMistakeProfile = NotationMistakeProfile()
    ) -> [NotationTrainingPrompt] {
        var candidates = prompts.filter(configuration.filter.accepts)

        switch configuration.style {
        case .fullGame, .randomPosition:
            break
        case .focusedDrill:
            candidates = candidates.filter { !configuration.filter.categories.isEmpty && !configuration.filter.categories.isDisjoint(with: $0.categories) }
        case .openingDrill:
            let limit = configuration.filter.maximumPly ?? Self.defaultOpeningPlyLimit
            candidates = candidates.filter { $0.moveIndex + 1 <= limit }
        case .mistakeReview:
            let prioritized = candidates.filter {
                mistakes.challengeIDs.contains($0.challengeID) || !mistakes.categories.isDisjoint(with: $0.categories)
            }
            if !prioritized.isEmpty {
                candidates = prioritized
            }
        }

        return candidates
    }

    func availability(
        configuration: NotationTrainingConfiguration,
        mistakes: NotationMistakeProfile = NotationMistakeProfile()
    ) -> NotationTrainingAvailability {
        let eligible = eligiblePrompts(configuration: configuration, mistakes: mistakes)
        guard !eligible.isEmpty else {
            return .unavailable(resetFilter: NotationTrainingFilter())
        }
        return .ready(eligible)
    }

    func makeGenerator(
        configuration: NotationTrainingConfiguration,
        mistakes: NotationMistakeProfile = NotationMistakeProfile(),
        randomizer: ChallengeRandomizing = SystemChallengeRandomizer()
    ) -> NotationTrainingPromptGenerator? {
        let eligible = eligiblePrompts(configuration: configuration, mistakes: mistakes)
        guard !eligible.isEmpty else { return nil }
        return NotationTrainingPromptGenerator(
            prompts: eligible,
            style: configuration.style,
            randomizer: randomizer
        )
    }
}

final class NotationTrainingPromptGenerator {
    private let promptsByID: [TrainingChallengeID: NotationTrainingPrompt]
    private let style: NotationTrainingStyle
    private let orderedPrompts: [NotationTrainingPrompt]
    private let generator: TrainingChallengeGenerator?
    private var orderedIndex = 0

    init(
        prompts: [NotationTrainingPrompt],
        style: NotationTrainingStyle,
        randomizer: ChallengeRandomizing
    ) {
        self.style = style
        orderedPrompts = prompts
        promptsByID = Dictionary(uniqueKeysWithValues: prompts.map { ($0.challengeID, $0) })

        if style == .fullGame {
            generator = nil
        } else {
            let challenges = prompts.map {
                TrainingChallenge(
                    id: $0.challengeID,
                    kind: .notationMove,
                    difficulty: $0.difficulty,
                    source: TrainingChallengeSource(
                        gameID: $0.gameID,
                        moveIndex: $0.moveIndex,
                        opening: $0.opening,
                        moveTags: Set($0.categories.map(\.rawValue))
                    ),
                    promptReference: $0.fenBefore
                )
            }
            generator = TrainingChallengeGenerator(challenges: challenges, randomizer: randomizer)
        }
    }

    var retainedPromptCount: Int {
        generator?.retainedChallengeCount ?? 0
    }

    func next() -> NotationTrainingPrompt? {
        if style == .fullGame {
            guard orderedIndex < orderedPrompts.count else { return nil }
            defer { orderedIndex += 1 }
            return orderedPrompts[orderedIndex]
        }

        guard let generator, case let .challenge(challenge) = generator.next() else { return nil }
        return promptsByID[challenge.id]
    }
}

enum SANFeedbackCategory: String, Codable, Sendable {
    case missingCapture
    case missingCheck
    case missingCheckmate
    case wrongCastlingForm
    case missingPromotion
    case missingDisambiguation
    case wrongDestination
    case wrongPiece
    case generic
}

struct SANFeedback: Hashable, Codable, Sendable {
    let category: SANFeedbackCategory
    let message: String
}

enum SemanticSANFeedback {
    static func feedback(expected: String, entered: String) -> SANFeedback {
        let expected = normalize(expected)
        let entered = normalize(entered)

        if expected.contains("x"), !entered.contains("x") {
            return SANFeedback(category: .missingCapture, message: "This move is a capture; include the capture marker.")
        }
        if expected.hasSuffix("#"), !entered.hasSuffix("#") {
            return SANFeedback(category: .missingCheckmate, message: "This move delivers checkmate; include the checkmate suffix.")
        }
        if expected.hasSuffix("+"), !entered.hasSuffix("+") {
            return SANFeedback(category: .missingCheck, message: "This move gives check; include the check suffix.")
        }
        if isCastling(expected), !isCastling(entered) {
            return SANFeedback(category: .wrongCastlingForm, message: "Use standard castling notation.")
        }
        if expected.contains("="), !entered.contains("=") {
            return SANFeedback(category: .missingPromotion, message: "Include the promoted piece.")
        }

        let expectedDestination = destination(in: expected)
        let enteredDestination = destination(in: entered)
        if let expectedDestination, let enteredDestination, expectedDestination != enteredDestination {
            return SANFeedback(category: .wrongDestination, message: "Check the destination square.")
        }

        let expectedPiece = expected.first.map(String.init)
        let enteredPiece = entered.first.map(String.init)
        if let expectedPiece, let enteredPiece, isPieceLetter(expectedPiece), isPieceLetter(enteredPiece), expectedPiece != enteredPiece {
            return SANFeedback(category: .wrongPiece, message: "Check which piece is moving.")
        }

        if requiresDisambiguation(expected), !requiresDisambiguation(entered) {
            return SANFeedback(category: .missingDisambiguation, message: "More origin detail is required to identify the moving piece.")
        }

        return SANFeedback(category: .generic, message: "Not quite. Review the move and try again.")
    }

    private static func normalize(_ san: String) -> String {
        san.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "0-0-0", with: "O-O-O")
            .replacingOccurrences(of: "0-0", with: "O-O")
    }

    private static func isCastling(_ san: String) -> Bool {
        san == "O-O" || san == "O-O-O"
    }

    private static func destination(in san: String) -> String? {
        let pattern = #"[a-h][1-8]"#
        guard let range = san.range(of: pattern, options: .regularExpression) else { return nil }
        return String(san[range])
    }

    private static func isPieceLetter(_ value: String) -> Bool {
        ["K", "Q", "R", "B", "N"].contains(value)
    }

    private static func requiresDisambiguation(_ san: String) -> Bool {
        guard let first = san.first, "KQRBN".contains(first) else { return false }
        let prefix = san.prefix { $0 != "x" && !($0 >= "a" && $0 <= "h" && san.dropFirst().contains($0)) }
        return prefix.count > 1 && !san.hasPrefix("O-")
    }
}

struct NotationTrainingAttempt: Hashable, Codable, Sendable {
    let challengeID: TrainingChallengeID
    let submitted: String
    let wasCorrect: Bool
    let attemptNumber: Int
    let feedbackCategory: SANFeedbackCategory?
}

struct NotationTrainingResult: Hashable, Codable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let configuration: NotationTrainingConfiguration
    let finishReason: TrainingFinishReason
    let promptCount: Int
    let correctCount: Int
    let firstTryCount: Int
    let totalAttempts: Int
    let hintsOrReveals: Int
    let mistakeCategories: [SANFeedbackCategory: Int]
    let sourceGameIDs: Set<String>

    init(
        schemaVersion: Int = currentSchemaVersion,
        configuration: NotationTrainingConfiguration,
        finishReason: TrainingFinishReason,
        promptCount: Int,
        correctCount: Int,
        firstTryCount: Int,
        totalAttempts: Int,
        hintsOrReveals: Int,
        mistakeCategories: [SANFeedbackCategory: Int],
        sourceGameIDs: Set<String>
    ) {
        self.schemaVersion = schemaVersion
        self.configuration = configuration
        self.finishReason = finishReason
        self.promptCount = promptCount
        self.correctCount = correctCount
        self.firstTryCount = firstTryCount
        self.totalAttempts = totalAttempts
        self.hintsOrReveals = hintsOrReveals
        self.mistakeCategories = mistakeCategories
        self.sourceGameIDs = sourceGameIDs
    }
}
