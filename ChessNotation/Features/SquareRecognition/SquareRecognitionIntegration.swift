import Foundation

struct SquareRecognitionLegacyCompatibility {
    static func migrate(_ legacy: SquareRecognitionResult) -> SquareRecognitionDrillResult {
        SquareRecognitionDrillResult(
            configuration: SquareRecognitionDrillConfiguration(
                drill: .findSquare,
                orientation: .white,
                zone: .all,
                difficulty: .beginner,
                variant: legacy.variant
            ),
            score: legacy.score,
            totalPrompts: legacy.totalPrompts,
            correctPrompts: legacy.correctCount,
            averageLatency: legacy.averageLatency,
            routeCount: 0,
            correctRoutes: 0
        )
    }
}

struct SquareRecognitionPresentation: Hashable, Sendable {
    let task: String
    let progress: String
    let orientation: String
    let feedback: String?

    static func make(
        configuration: SquareRecognitionDrillConfiguration,
        prompt: SquareRecognitionPrompt,
        completed: Int,
        total: Int?,
        feedback: String?
    ) -> SquareRecognitionPresentation {
        let task: String
        switch configuration.drill {
        case .findSquare:
            task = "Find square \(prompt.target.description)"
        case .nameSquare:
            task = "Name the highlighted square"
        case .squareColor:
            task = "Identify whether \(prompt.target.description) is light or dark"
        case .relativeSquare:
            task = "Select the requested relative square"
        case .route:
            task = "Select the route in order"
        }

        let progress: String
        if let total {
            progress = "Prompt \(min(completed + 1, total)) of \(total)"
        } else {
            progress = "\(completed) prompts completed"
        }

        let orientation = prompt.orientation == .black ? "Black orientation" : "White orientation"
        return SquareRecognitionPresentation(
            task: task,
            progress: progress,
            orientation: orientation,
            feedback: feedback
        )
    }

    var accessibilitySummary: String {
        [task, orientation, progress, feedback]
            .compactMap { $0 }
            .joined(separator: ". ")
    }
}

final class SquareBoardResourceTracker {
    let resourceID = UUID()
    private(set) var promptUpdateCount = 0

    func recordPromptUpdate() {
        promptUpdateCount += 1
    }
}

struct SquareRecognitionIntegratedSession {
    private(set) var session: SquareRecognitionSession
    let boardResources: SquareBoardResourceTracker

    init(session: SquareRecognitionSession, boardResources: SquareBoardResourceTracker = SquareBoardResourceTracker()) {
        self.session = session
        self.boardResources = boardResources
    }

    mutating func advance(to prompt: SquareRecognitionPrompt) {
        session.advance(to: prompt)
        boardResources.recordPromptUpdate()
    }
}
