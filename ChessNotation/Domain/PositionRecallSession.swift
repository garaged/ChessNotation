import Foundation

nonisolated enum PositionRecallPhase: String, Codable {
    case studying
    case answering
    case finished
}

final class PositionRecallSession {
    private let clock: MonotonicTimeProviding
    private let deadline: TimeInterval
    private(set) var phase: PositionRecallPhase = .studying
    private(set) var transitionCount = 0

    init(prompt: PositionRecallPrompt, clock: MonotonicTimeProviding) {
        self.clock = clock
        self.deadline = clock.now + max(0, prompt.studyDuration)
    }

    func refresh() {
        guard phase == .studying, clock.now >= deadline else { return }
        phase = .answering
        transitionCount += 1
    }

    func finish() {
        guard phase != .finished else { return }
        phase = .finished
    }
}

nonisolated struct PositionRecallAnswer: Hashable, Codable {
    let selected: Set<ChessSquare>
    let expected: Set<ChessSquare>
    let missing: Set<ChessSquare>
    let extra: Set<ChessSquare>

    init(selected: Set<ChessSquare>, expected: Set<ChessSquare>) {
        self.selected = selected
        self.expected = expected
        self.missing = expected.subtracting(selected)
        self.extra = selected.subtracting(expected)
    }

    var isCorrect: Bool { missing.isEmpty && extra.isEmpty }
}

enum PositionRecallAccessibility {
    static func label(for phase: PositionRecallPhase) -> String {
        switch phase {
        case .studying: return "Study the position"
        case .answering: return "Position hidden. Answer the recall question"
        case .finished: return "Recall challenge finished"
        }
    }

    static func exposesPieces(in phase: PositionRecallPhase) -> Bool {
        phase == .studying
    }
}
