import Foundation

nonisolated enum TimedNotationVariant: String, Codable, CaseIterable, Sendable {
    case sprint
    case accuracyRace
    case survival
    case combo
}

nonisolated enum TimedLifecyclePolicy: String, Codable, Sendable {
    case continueAgainstDeadline
    case pauseWhileInactive
}

nonisolated struct TimedNotationConfiguration: Hashable, Codable, Sendable {
    let variant: TimedNotationVariant
    let initialDuration: TimeInterval
    let promptCount: Int
    let lifecyclePolicy: TimedLifecyclePolicy
    let survivalBonus: TimeInterval
    let survivalPenalty: TimeInterval
    let survivalMaximum: TimeInterval
    let comboStep: Double
    let comboMaximum: Double

    init(
        variant: TimedNotationVariant,
        initialDuration: TimeInterval,
        promptCount: Int = 10,
        lifecyclePolicy: TimedLifecyclePolicy = .continueAgainstDeadline,
        survivalBonus: TimeInterval = 2,
        survivalPenalty: TimeInterval = 2,
        survivalMaximum: TimeInterval = 30,
        comboStep: Double = 0.25,
        comboMaximum: Double = 3
    ) {
        self.variant = variant
        self.initialDuration = max(0, initialDuration)
        self.promptCount = max(1, promptCount)
        self.lifecyclePolicy = lifecyclePolicy
        self.survivalBonus = max(0, survivalBonus)
        self.survivalPenalty = max(0, survivalPenalty)
        self.survivalMaximum = max(0, survivalMaximum)
        self.comboStep = max(0, comboStep)
        self.comboMaximum = max(1, comboMaximum)
    }
}

nonisolated protocol MonotonicTimeProviding: AnyObject {
    var now: TimeInterval { get }
}

nonisolated final class SystemMonotonicClock: MonotonicTimeProviding {
    var now: TimeInterval { ProcessInfo.processInfo.systemUptime }
}

nonisolated final class TestMonotonicClock: MonotonicTimeProviding {
    var now: TimeInterval

    init(now: TimeInterval = 0) {
        self.now = now
    }

    func advance(by interval: TimeInterval) {
        now += interval
    }
}

nonisolated struct TimedScoreInput: Hashable, Sendable {
    let correct: Bool
    let latency: TimeInterval
    let complexity: Int
    let streak: Int
    let usedHintOrReveal: Bool
    let multiplier: Double
}

nonisolated struct TimedScoreBreakdown: Hashable, Codable, Sendable {
    let base: Int
    let speed: Int
    let complexity: Int
    let streak: Int
    let hintRevealPenalty: Int
    let finalTotal: Int
}

enum TimedNotationScorer {
    static let minimumPlausibleLatency: TimeInterval = 0.25
    static let maximumSpeedScore = 40
    static let correctBaseScore = 100

    static func score(_ input: TimedScoreInput) -> TimedScoreBreakdown {
        let base = input.correct ? correctBaseScore : 0
        let boundedLatency = max(minimumPlausibleLatency, input.latency)
        let speed = input.correct ? min(maximumSpeedScore, max(0, Int((10 / boundedLatency).rounded()))) : 0
        let complexity = input.correct ? max(0, min(30, input.complexity * 5)) : 0
        let streak = input.correct ? max(0, min(50, input.streak * 5)) : 0
        let penalty = input.usedHintOrReveal ? 60 : 0
        let subtotal = max(0, base + speed + complexity + streak - penalty)
        let total = Int((Double(subtotal) * max(1, input.multiplier)).rounded())

        return TimedScoreBreakdown(
            base: base,
            speed: speed,
            complexity: complexity,
            streak: streak,
            hintRevealPenalty: penalty,
            finalTotal: total
        )
    }
}

nonisolated struct TimedNotationResult: Hashable, Codable, Sendable {
    let variant: TimedNotationVariant
    let configuration: TimedNotationConfiguration
    let score: Int
    let completedPrompts: Int
    let correctPrompts: Int
    let maximumStreak: Int
    let elapsed: TimeInterval
    let remaining: TimeInterval
    let difficultyStage: Int
    let finishReason: TrainingFinishReason
    let sourceCategories: Set<NotationMoveCategory>
}

nonisolated struct TimedRefreshMetrics: Equatable, Sendable {
    let refreshCount: Int
    let timeoutTransitionCount: Int
}

final class TimedNotationSession {
    private let configuration: TimedNotationConfiguration
    private let clock: MonotonicTimeProviding
    private let startedAt: TimeInterval
    private var deadline: TimeInterval
    private var inactiveStartedAt: TimeInterval?
    private var hasFinished = false
    private var refreshCount = 0
    private var timeoutTransitionCount = 0

    private(set) var score = 0
    private(set) var completedPrompts = 0
    private(set) var correctPrompts = 0
    private(set) var currentStreak = 0
    private(set) var maximumStreak = 0
    private(set) var comboMultiplier = 1.0
    private(set) var difficultyStage = 1
    private(set) var historySaveCount = 0
    private(set) var sourceCategories: Set<NotationMoveCategory> = []
    private(set) var finishReason: TrainingFinishReason?

    init(configuration: TimedNotationConfiguration, clock: MonotonicTimeProviding) {
        self.configuration = configuration
        self.clock = clock
        startedAt = clock.now
        deadline = clock.now + configuration.initialDuration
    }

    var remainingTime: TimeInterval {
        max(0, deadline - clock.now)
    }

    var isFinished: Bool { hasFinished }

    var refreshMetrics: TimedRefreshMetrics {
        TimedRefreshMetrics(
            refreshCount: refreshCount,
            timeoutTransitionCount: timeoutTransitionCount
        )
    }

    @discardableResult
    func refresh() -> Bool {
        refreshCount += 1
        guard !hasFinished else { return true }
        if clock.now >= deadline {
            timeoutTransitionCount += 1
            finish(reason: .timedOut)
        }
        return hasFinished
    }

    @discardableResult
    func submit(
        correct: Bool,
        submittedAt: TimeInterval,
        latency: TimeInterval,
        complexity: Int,
        usedHintOrReveal: Bool,
        categories: Set<NotationMoveCategory> = []
    ) -> Bool {
        guard !hasFinished, submittedAt < deadline else {
            if !hasFinished, submittedAt >= deadline { finish(reason: .timedOut) }
            return false
        }

        completedPrompts += 1
        sourceCategories.formUnion(categories)

        if correct {
            correctPrompts += 1
            currentStreak += 1
            maximumStreak = max(maximumStreak, currentStreak)
        } else {
            currentStreak = 0
        }

        switch configuration.variant {
        case .survival:
            if correct {
                deadline = min(startedAt + configuration.survivalMaximum, deadline + configuration.survivalBonus)
            } else {
                deadline = max(clock.now, deadline - configuration.survivalPenalty)
            }
            difficultyStage = 1 + (completedPrompts / 5)
        case .combo:
            if correct {
                comboMultiplier = min(configuration.comboMaximum, comboMultiplier + configuration.comboStep)
            } else {
                comboMultiplier = 1
            }
        case .sprint, .accuracyRace:
            break
        }

        let breakdown = TimedNotationScorer.score(
            TimedScoreInput(
                correct: correct,
                latency: latency,
                complexity: complexity,
                streak: currentStreak,
                usedHintOrReveal: usedHintOrReveal,
                multiplier: configuration.variant == .combo ? comboMultiplier : 1
            )
        )
        score += breakdown.finalTotal

        if configuration.variant == .accuracyRace, completedPrompts >= configuration.promptCount {
            finish(reason: .completed)
        }

        return true
    }

    func becameInactive() {
        guard configuration.lifecyclePolicy == .pauseWhileInactive, inactiveStartedAt == nil, !hasFinished else { return }
        inactiveStartedAt = clock.now
    }

    func becameActive() {
        guard configuration.lifecyclePolicy == .pauseWhileInactive, let inactiveStartedAt, !hasFinished else { return }
        deadline += max(0, clock.now - inactiveStartedAt)
        self.inactiveStartedAt = nil
    }

    func finish(reason: TrainingFinishReason) {
        guard !hasFinished else { return }
        hasFinished = true
        finishReason = reason
        historySaveCount += 1
    }

    var result: TimedNotationResult? {
        guard let finishReason else { return nil }
        return TimedNotationResult(
            variant: configuration.variant,
            configuration: configuration,
            score: score,
            completedPrompts: completedPrompts,
            correctPrompts: correctPrompts,
            maximumStreak: maximumStreak,
            elapsed: max(0, min(clock.now, deadline) - startedAt),
            remaining: remainingTime,
            difficultyStage: difficultyStage,
            finishReason: finishReason,
            sourceCategories: sourceCategories
        )
    }
}
