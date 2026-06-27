import Foundation

struct MoveAttemptRecord: Identifiable, Equatable {
    let id = UUID()
    let move: NotationMove
    let attemptsUsed: Int
    let wasCorrect: Bool
    let elapsedSeconds: TimeInterval
    let submittedAnswers: [String]
}

enum TimedSessionFinishReason: String, Codable, Equatable {
    case completed
    case timedOut
    case exited

    var displayName: String {
        switch self {
        case .completed: return "Completed"
        case .timedOut: return "Timed out"
        case .exited: return "Exited"
        }
    }
}

enum GameSessionMode: Hashable {
    case untimed
    case timed(durationSeconds: Int)

    var durationSeconds: Int? {
        switch self {
        case .untimed: return nil
        case .timed(let durationSeconds): return durationSeconds
        }
    }

    var isTimed: Bool { durationSeconds != nil }
}

struct TrainingSessionSummary: Equatable {
    let game: NotationGame
    let records: [MoveAttemptRecord]
    let mode: GameSessionMode
    let remainingSeconds: Int?
    let finishReason: TimedSessionFinishReason

    init(
        game: NotationGame,
        records: [MoveAttemptRecord],
        mode: GameSessionMode = .untimed,
        remainingSeconds: Int? = nil,
        finishReason: TimedSessionFinishReason = .completed
    ) {
        self.game = game
        self.records = records
        self.mode = mode
        self.remainingSeconds = remainingSeconds
        self.finishReason = finishReason
    }

    var completedMoves: Int { records.count }
    var correctMoves: Int { records.filter(\.wasCorrect).count }
    var incorrectMoves: Int { completedMoves - correctMoves }

    var accuracy: Double {
        guard !records.isEmpty else { return 0 }
        return Double(correctMoves) / Double(records.count)
    }

    var averageMoveTime: TimeInterval {
        guard !records.isEmpty else { return 0 }
        return records.map(\.elapsedSeconds).reduce(0, +) / Double(records.count)
    }

    var firstTryCorrect: Int {
        records.filter { $0.wasCorrect && $0.attemptsUsed == 1 }.count
    }

    var selectedDurationSeconds: Int? { mode.durationSeconds }

    var timeUsedSeconds: Int? {
        guard let selectedDurationSeconds, let remainingSeconds else { return nil }
        return max(0, selectedDurationSeconds - remainingSeconds)
    }

    var mistakesByTag: [(MoveTypeTag, Int)] {
        let failed = records.filter { !$0.wasCorrect }
        var counts: [MoveTypeTag: Int] = [:]
        for record in failed {
            for tag in record.move.tags {
                counts[tag, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }
    }
}
