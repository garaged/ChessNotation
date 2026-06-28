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

    var historyGameType: String {
        isTimed ? "timedNotation" : "notation"
    }
}

struct TrainingSessionSummary: Equatable {
    let game: NotationGame
    let records: [MoveAttemptRecord]
    let mode: GameSessionMode
    let remainingSeconds: Int?
    let finishReason: TimedSessionFinishReason
    let finishedAt: Date

    init(
        game: NotationGame,
        records: [MoveAttemptRecord],
        mode: GameSessionMode = .untimed,
        remainingSeconds: Int? = nil,
        finishReason: TimedSessionFinishReason = .completed,
        finishedAt: Date = Date()
    ) {
        self.game = game
        self.records = records
        self.mode = mode
        self.remainingSeconds = remainingSeconds
        self.finishReason = finishReason
        self.finishedAt = finishedAt
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

    var completionPercentage: Double {
        guard !game.moves.isEmpty else { return 0 }
        return Double(completedMoves) / Double(game.moves.count)
    }

    var movesPerMinute: Double? {
        guard let timeUsedSeconds, timeUsedSeconds > 0 else { return nil }
        return Double(completedMoves) / (Double(timeUsedSeconds) / 60.0)
    }
}

enum HistoryRange: String, CaseIterable, Identifiable, Codable {
    case today
    case lastWeek
    case lastMonth
    case lastYear

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .today: return "Today"
        case .lastWeek: return "Week"
        case .lastMonth: return "Month"
        case .lastYear: return "Year"
        }
    }

    func contains(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> Bool {
        if self == .today {
            return calendar.isDate(date, inSameDayAs: now)
        }
        guard let startDate else { return true }
        return date >= calendar.date(byAdding: startDate, to: now) ?? now
    }

    func axisLabels(for dates: [Date]) -> [String] {
        let axisDates = axisDates(for: dates)
        return axisDates.map(axisLabel)
    }

    private var startDate: DateComponents? {
        switch self {
        case .today: return DateComponents(day: 0)
        case .lastWeek: return DateComponents(day: -7)
        case .lastMonth: return DateComponents(month: -1)
        case .lastYear: return DateComponents(year: -1)
        }
    }

    private func axisDates(for dates: [Date]) -> [Date] {
        guard !dates.isEmpty else { return [] }
        guard dates.count > 2 else { return dates }
        return [
            dates[dates.startIndex],
            dates[dates.index(dates.startIndex, offsetBy: dates.count / 2)],
            dates[dates.index(before: dates.endIndex)]
        ]
    }

    private func axisLabel(for date: Date) -> String {
        switch self {
        case .today:
            return date.formatted(date: .omitted, time: .shortened)
        case .lastWeek:
            return date.formatted(.dateTime.weekday(.abbreviated))
        case .lastMonth:
            return date.formatted(.dateTime.month(.abbreviated).day())
        case .lastYear:
            return date.formatted(.dateTime.month(.abbreviated))
        }
    }
}

protocol NotationTrainingHistoryStoring {
    func loadResults() throws -> [NotationTrainingHistoryRecord]
    func saveResult(_ result: NotationTrainingHistoryRecord) throws
}

struct NotationTrainingHistoryStore: NotationTrainingHistoryStoring {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.fileURL = supportDirectory
                .appendingPathComponent("ChessNotation", isDirectory: true)
                .appendingPathComponent("notation-training-history.json")
        }

        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadResults() throws -> [NotationTrainingHistoryRecord] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([NotationTrainingHistoryRecord].self, from: data)
            .sorted { $0.finishedAt > $1.finishedAt }
    }

    func saveResult(_ result: NotationTrainingHistoryRecord) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        var results = (try? loadResults()) ?? []
        guard !results.contains(where: { $0.sessionKey == result.sessionKey }) else { return }
        results.append(result)
        results.sort { $0.finishedAt > $1.finishedAt }
        let data = try encoder.encode(results)
        try data.write(to: fileURL, options: [.atomic])
    }
}

struct NotationTrainingHistoryRecord: Codable, Equatable, Identifiable {
    let schemaVersion: Int
    let id: UUID
    let sessionKey: String
    let gameType: String
    let gameID: String
    let gameTitle: String
    let finishedAt: Date
    let completedMoves: Int
    let totalMoves: Int
    let correctMoves: Int
    let incorrectMoves: Int
    let accuracy: Double
    let firstTryCorrectCount: Int
    let averageMoveTime: TimeInterval
    let attemptsDistribution: [Int: Int]
    let skippedOrRevealedCount: Int
    let mistakesByTag: [String: Int]
    let selectedDurationSeconds: Int?
    let timeUsedSeconds: Int?
    let finishReason: TimedSessionFinishReason
    let movesPerMinute: Double?
    let completionPercentage: Double

    init(id: UUID = UUID(), summary: TrainingSessionSummary) {
        let attemptsDistribution = Dictionary(grouping: summary.records, by: \.attemptsUsed)
            .mapValues(\.count)
        let skippedOrRevealedCount = summary.records.filter { !$0.wasCorrect && $0.submittedAnswers.isEmpty }.count
        let mistakesByTag = Dictionary(uniqueKeysWithValues: summary.mistakesByTag.map { ($0.0.rawValue, $0.1) })
        let finishedAt = summary.finishedAt

        self.schemaVersion = 1
        self.id = id
        self.sessionKey = [
            summary.mode.historyGameType,
            summary.game.id,
            String(finishedAt.timeIntervalSince1970),
            String(summary.completedMoves),
            String(summary.correctMoves),
            summary.finishReason.rawValue
        ].joined(separator: "|")
        self.gameType = summary.mode.historyGameType
        self.gameID = summary.game.id
        self.gameTitle = summary.game.title
        self.finishedAt = finishedAt
        self.completedMoves = summary.completedMoves
        self.totalMoves = summary.game.moves.count
        self.correctMoves = summary.correctMoves
        self.incorrectMoves = summary.incorrectMoves
        self.accuracy = summary.accuracy
        self.firstTryCorrectCount = summary.firstTryCorrect
        self.averageMoveTime = summary.averageMoveTime
        self.attemptsDistribution = attemptsDistribution
        self.skippedOrRevealedCount = skippedOrRevealedCount
        self.mistakesByTag = mistakesByTag
        self.selectedDurationSeconds = summary.selectedDurationSeconds
        self.timeUsedSeconds = summary.timeUsedSeconds
        self.finishReason = summary.finishReason
        self.movesPerMinute = summary.movesPerMinute
        self.completionPercentage = summary.completionPercentage
    }

    var firstTryRate: Double {
        guard completedMoves > 0 else { return 0 }
        return Double(firstTryCorrectCount) / Double(completedMoves)
    }
}
