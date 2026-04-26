import Foundation

struct MoveAttemptRecord: Identifiable, Equatable {
    let id = UUID()
    let move: NotationMove
    let attemptsUsed: Int
    let wasCorrect: Bool
    let elapsedSeconds: TimeInterval
    let submittedAnswers: [String]
}

struct TrainingSessionSummary: Equatable {
    let game: NotationGame
    let records: [MoveAttemptRecord]

    var completedMoves: Int { records.count }
    var correctMoves: Int { records.filter(\.wasCorrect).count }

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
