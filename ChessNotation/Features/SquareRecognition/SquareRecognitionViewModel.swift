import Foundation
import Observation

@Observable
final class SquareRecognitionViewModel {
    static let defaultInitialTime: TimeInterval = 10
    static let defaultFeedbackDelay: TimeInterval = 0.2
    static let validCoordinates: [String] = (1...8).flatMap { rank in
        (UnicodeScalar("a").value...UnicodeScalar("h").value).map { fileValue in
            "\(Character(UnicodeScalar(fileValue)!))\(rank)"
        }
    }

    let initialTime: TimeInterval
    let variant: SquareRecognitionVariant
    let feedbackDelay: TimeInterval
    private let historyStore: SquareRecognitionHistoryStoring

    private(set) var remainingTime: TimeInterval
    private(set) var targetCoordinate: String
    private(set) var answers: [SquareRecognitionAnswer] = []
    private(set) var feedback: String?
    private(set) var isFinished = false
    private(set) var result: SquareRecognitionResult?
    private(set) var saveError: String?

    private var promptShownAt: Date
    private var isShowingFeedback = false

    init(
        initialTime: TimeInterval = SquareRecognitionViewModel.defaultInitialTime,
        variant: SquareRecognitionVariant = .bonus,
        feedbackDelay: TimeInterval = SquareRecognitionViewModel.defaultFeedbackDelay,
        historyStore: SquareRecognitionHistoryStoring = SquareRecognitionHistoryStore(),
        now: Date = Date()
    ) {
        self.initialTime = initialTime
        self.variant = variant
        self.feedbackDelay = feedbackDelay
        self.historyStore = historyStore
        self.remainingTime = initialTime
        self.targetCoordinate = Self.validCoordinates.randomElement() ?? "a1"
        self.promptShownAt = now
    }

    var timerText: String {
        remainingTime.formattedTenths
    }

    var accuracyText: String {
        guard !answers.isEmpty else { return "0%" }
        let accuracy = Double(correctCount) / Double(answers.count)
        return accuracy.formatted(.percent.precision(.fractionLength(0)))
    }

    var correctCount: Int { answers.filter(\.isCorrect).count }
    var incorrectCount: Int { answers.count - correctCount }
    var score: Int { correctCount }
    var canAcceptAnswer: Bool { !isFinished && !isShowingFeedback }

    func selectSquare(_ coordinate: String, at now: Date = Date()) {
        guard canAcceptAnswer else { return }

        let latency = max(0, now.timeIntervalSince(promptShownAt))
        let isCorrect = coordinate == targetCoordinate
        remainingTime -= latency
        if isCorrect {
            remainingTime += variant.bonusSeconds
        }

        answers.append(
            SquareRecognitionAnswer(
                target: targetCoordinate,
                selected: coordinate,
                isCorrect: isCorrect,
                latency: latency
            )
        )
        feedback = isCorrect ? "Correct" : "Incorrect"

        if remainingTime <= 0 {
            finish(at: now)
        } else {
            isShowingFeedback = true
        }
    }

    func showNextPrompt(at now: Date = Date()) {
        guard !isFinished, isShowingFeedback else { return }
        targetCoordinate = Self.validCoordinates.randomElement() ?? "a1"
        promptShownAt = now
        feedback = nil
        isShowingFeedback = false
    }

    func expireIfNeeded(at now: Date = Date()) {
        guard !isFinished else { return }
        let elapsed = max(0, now.timeIntervalSince(promptShownAt))
        if remainingTime - elapsed <= 0 {
            remainingTime = 0
            finish(at: now)
        }
    }

    func reset(at now: Date = Date()) {
        remainingTime = initialTime
        targetCoordinate = Self.validCoordinates.randomElement() ?? "a1"
        answers = []
        feedback = nil
        isFinished = false
        result = nil
        saveError = nil
        promptShownAt = now
        isShowingFeedback = false
    }

    private func finish(at now: Date) {
        guard !isFinished else { return }
        remainingTime = max(0, remainingTime)
        isFinished = true
        isShowingFeedback = false

        let result = SquareRecognitionResult(
            initialTime: initialTime,
            variant: variant,
            answers: answers,
            finishedAt: now
        )
        self.result = result

        do {
            try historyStore.saveResult(result)
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
    }
}
