import Foundation

struct SquareBoardMapping {
    static func displayIndex(for square: ChessSquare, orientation: BoardOrientationPolicy) -> Int {
        switch orientation {
        case .white, .alternating:
            return (7 - square.rank) * 8 + square.file
        case .black:
            return square.rank * 8 + (7 - square.file)
        }
    }

    static func square(forDisplayIndex index: Int, orientation: BoardOrientationPolicy) -> ChessSquare? {
        guard (0..<64).contains(index) else { return nil }
        let row = index / 8
        let column = index % 8
        switch orientation {
        case .white, .alternating:
            return ChessSquare(file: column, rank: 7 - row)
        case .black:
            return ChessSquare(file: 7 - column, rank: row)
        }
    }
}

enum SquareRecognitionSubmission: Hashable {
    case square(ChessSquare)
    case coordinate(String)
    case color(ChessSquareColor)
    case route([ChessSquare])
}

struct SquareRecognitionEvaluation: Hashable {
    let isCorrect: Bool
    let acceptedAt: TimeInterval
    let latency: TimeInterval
}

final class SquareRecognitionSession {
    private let clock: MonotonicTimeProviding
    private(set) var configuration: SquareRecognitionDrillConfiguration
    private(set) var currentPrompt: SquareRecognitionPrompt
    private(set) var inputLocked = false
    private(set) var score = 0
    private(set) var totalPrompts = 0
    private(set) var correctPrompts = 0
    private(set) var routeCount = 0
    private(set) var correctRoutes = 0
    private var promptStartedAt: TimeInterval
    private var latencies: [TimeInterval] = []

    init(
        configuration: SquareRecognitionDrillConfiguration,
        prompt: SquareRecognitionPrompt,
        clock: MonotonicTimeProviding
    ) {
        self.configuration = Self.sanitized(configuration)
        self.currentPrompt = prompt
        self.clock = clock
        self.promptStartedAt = clock.now
    }

    static func sanitized(_ configuration: SquareRecognitionDrillConfiguration) -> SquareRecognitionDrillConfiguration {
        if SquareRecognitionPromptFactory.squares(in: configuration.zone).isEmpty {
            return SquareRecognitionDrillConfiguration(
                drill: configuration.drill,
                orientation: configuration.orientation,
                zone: .all,
                difficulty: configuration.difficulty,
                variant: configuration.variant
            )
        }
        return configuration
    }

    func submit(_ answer: SquareRecognitionSubmission, at timestamp: TimeInterval) -> SquareRecognitionEvaluation? {
        guard !inputLocked else { return nil }
        inputLocked = true

        let correct = evaluate(answer)
        let latency = max(0, timestamp - promptStartedAt)
        totalPrompts += 1
        latencies.append(latency)
        if correct {
            correctPrompts += 1
            score += 100
        }
        if configuration.drill == .route {
            routeCount += 1
            if correct { correctRoutes += 1 }
        }

        return SquareRecognitionEvaluation(isCorrect: correct, acceptedAt: timestamp, latency: latency)
    }

    func advance(to prompt: SquareRecognitionPrompt) {
        currentPrompt = prompt
        promptStartedAt = clock.now
        inputLocked = false
    }

    var result: SquareRecognitionDrillResult {
        let average = latencies.isEmpty ? 0 : latencies.reduce(0, +) / Double(latencies.count)
        return SquareRecognitionDrillResult(
            configuration: configuration,
            score: score,
            totalPrompts: totalPrompts,
            correctPrompts: correctPrompts,
            averageLatency: average,
            routeCount: routeCount,
            correctRoutes: correctRoutes
        )
    }

    private func evaluate(_ answer: SquareRecognitionSubmission) -> Bool {
        switch (configuration.drill, answer) {
        case (.findSquare, .square(let square)):
            return square == currentPrompt.target
        case (.nameSquare, .coordinate(let coordinate)):
            return ChessSquare(coordinate.lowercased()) == currentPrompt.target
        case (.squareColor, .color(let color)):
            return color == currentPrompt.target.color
        case (.relativeSquare, .square(let square)):
            return square == currentPrompt.target
        case (.route, .route(let route)):
            return route == currentPrompt.route
        default:
            return false
        }
    }
}
