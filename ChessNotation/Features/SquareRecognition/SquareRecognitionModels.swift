import Foundation

enum SquareRecognitionVariant: String, Codable, CaseIterable, Identifiable {
    case bonus
    case strict

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bonus: return "Bonus"
        case .strict: return "Strict"
        }
    }

    var bonusSeconds: TimeInterval {
        switch self {
        case .bonus: return 0.5
        case .strict: return 0
        }
    }
}

struct SquareRecognitionAnswer: Codable, Equatable, Identifiable {
    let id: UUID
    let target: String
    let selected: String
    let isCorrect: Bool
    let latency: TimeInterval

    init(id: UUID = UUID(), target: String, selected: String, isCorrect: Bool, latency: TimeInterval) {
        self.id = id
        self.target = target
        self.selected = selected
        self.isCorrect = isCorrect
        self.latency = latency
    }
}

struct SquareRecognitionResult: Codable, Equatable, Identifiable {
    let id: UUID
    let initialTime: TimeInterval
    let variant: SquareRecognitionVariant
    let answers: [SquareRecognitionAnswer]
    let finishedAt: Date
    let gameType: String

    init(
        id: UUID = UUID(),
        initialTime: TimeInterval,
        variant: SquareRecognitionVariant,
        answers: [SquareRecognitionAnswer],
        finishedAt: Date = Date(),
        gameType: String = "squareRecognition"
    ) {
        self.id = id
        self.initialTime = initialTime
        self.variant = variant
        self.answers = answers
        self.finishedAt = finishedAt
        self.gameType = gameType
    }

    var totalPrompts: Int { answers.count }
    var correctCount: Int { answers.filter(\.isCorrect).count }
    var incorrectCount: Int { totalPrompts - correctCount }
    var score: Int { correctCount }

    var accuracy: Double {
        guard totalPrompts > 0 else { return 0 }
        return Double(correctCount) / Double(totalPrompts)
    }

    var averageLatency: TimeInterval {
        guard totalPrompts > 0 else { return 0 }
        return answers.map(\.latency).reduce(0, +) / Double(totalPrompts)
    }

    var fastestCorrectLatency: TimeInterval? {
        answers.filter(\.isCorrect).map(\.latency).min()
    }

    var slowestLatency: TimeInterval? {
        answers.map(\.latency).max()
    }
}

extension TimeInterval {
    var formattedTenths: String {
        String(format: "%.1fs", self)
    }
}
