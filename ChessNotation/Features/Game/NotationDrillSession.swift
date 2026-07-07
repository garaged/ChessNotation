import Foundation
import Observation

@Observable
final class NotationDrillSession {
    let configuration: NotationTrainingConfiguration

    private(set) var currentPrompt: NotationTrainingPrompt?
    private(set) var attemptsRemaining: Int
    private(set) var feedback = "Enter the notation for the displayed position."
    private(set) var resolvedPromptCount = 0
    private(set) var correctPromptCount = 0
    private(set) var firstTryCount = 0
    private(set) var totalAttempts = 0
    private(set) var hintsOrReveals = 0
    private(set) var isFinished = false
    private(set) var finishReason: TrainingFinishReason = .completed
    private(set) var attempts: [NotationTrainingAttempt] = []
    private(set) var sourceGameIDs: Set<String> = []

    var answerText = ""

    private let generator: NotationTrainingPromptGenerator
    private let validator: (String, String) -> Bool

    init(
        configuration: NotationTrainingConfiguration,
        generator: NotationTrainingPromptGenerator,
        validator: @escaping (String, String) -> Bool
    ) {
        self.configuration = configuration
        self.generator = generator
        self.validator = validator
        attemptsRemaining = configuration.answerPolicy.rawValue
        currentPrompt = generator.next()

        if currentPrompt == nil {
            isFinished = true
            finishReason = .unavailableContent
            feedback = "No challenges match the selected filters. Reset or relax the filters to continue."
        }
    }

    var progressText: String {
        "Challenge \(min(resolvedPromptCount + 1, configuration.promptCount)) of \(configuration.promptCount)"
    }

    var accessibilityStatus: String {
        guard let currentPrompt else { return feedback }
        return "\(progressText). Board orientation: White at bottom. \(attemptsRemaining) attempts remaining. \(feedback) Position from \(currentPrompt.gameTitle)."
    }

    func submitAnswer() {
        guard let prompt = currentPrompt, !isFinished else { return }
        let answer = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else {
            feedback = "Type your answer first."
            return
        }

        totalAttempts += 1
        let attemptNumber = configuration.answerPolicy.rawValue - attemptsRemaining + 1
        let correct = validator(answer, prompt.expectedSAN)

        if correct {
            attempts.append(
                NotationTrainingAttempt(
                    challengeID: prompt.challengeID,
                    submitted: answer,
                    wasCorrect: true,
                    attemptNumber: attemptNumber,
                    feedbackCategory: nil
                )
            )
            correctPromptCount += 1
            if attemptNumber == 1 { firstTryCount += 1 }
            feedback = "Correct."
            resolveCurrentPrompt()
            return
        }

        let semantic = SemanticSANFeedback.feedback(expected: prompt.expectedSAN, entered: answer)
        attempts.append(
            NotationTrainingAttempt(
                challengeID: prompt.challengeID,
                submitted: answer,
                wasCorrect: false,
                attemptNumber: attemptNumber,
                feedbackCategory: semantic.category
            )
        )
        attemptsRemaining -= 1

        if attemptsRemaining == 0 {
            hintsOrReveals += 1
            feedback = "Answer: \(prompt.expectedSAN)."
            resolveCurrentPrompt()
        } else {
            feedback = semantic.message
            answerText = ""
        }
    }

    func skip() {
        guard let prompt = currentPrompt, !isFinished else { return }
        hintsOrReveals += 1
        feedback = "Answer: \(prompt.expectedSAN)."
        resolveCurrentPrompt()
    }

    func endSession() {
        guard !isFinished else { return }
        isFinished = true
        finishReason = .userExited
        currentPrompt = nil
    }

    var result: NotationTrainingResult {
        var categories: [SANFeedbackCategory: Int] = [:]
        for attempt in attempts {
            if let category = attempt.feedbackCategory {
                categories[category, default: 0] += 1
            }
        }

        return NotationTrainingResult(
            configuration: configuration,
            finishReason: finishReason,
            promptCount: resolvedPromptCount,
            correctCount: correctPromptCount,
            firstTryCount: firstTryCount,
            totalAttempts: totalAttempts,
            hintsOrReveals: hintsOrReveals,
            mistakeCategories: categories,
            sourceGameIDs: sourceGameIDs
        )
    }

    private func resolveCurrentPrompt() {
        if let currentPrompt {
            sourceGameIDs.insert(currentPrompt.gameID)
        }
        resolvedPromptCount += 1
        answerText = ""
        attemptsRemaining = configuration.answerPolicy.rawValue

        if resolvedPromptCount >= configuration.promptCount {
            isFinished = true
            finishReason = .completed
            currentPrompt = nil
            feedback = "Session complete."
            return
        }

        currentPrompt = generator.next()
        if currentPrompt == nil {
            isFinished = true
            finishReason = .unavailableContent
            feedback = "No more eligible challenges are available."
        } else if configuration.progressionPolicy == .immediate {
            feedback = "Enter the notation for the displayed position."
        }
    }
}
