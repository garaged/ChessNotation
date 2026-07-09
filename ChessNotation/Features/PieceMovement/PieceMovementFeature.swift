import Foundation
import Observation
import SwiftUI

protocol PieceMovementHistoryStoring {
    func loadResults() throws -> [PieceMovementSessionResult]
    func saveResult(_ result: PieceMovementSessionResult) throws
}

struct PieceMovementHistoryStore: PieceMovementHistoryStoring {
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
                .appendingPathComponent("piece-movement-history.json")
        }
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func loadResults() throws -> [PieceMovementSessionResult] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([PieceMovementSessionResult].self, from: data)
    }

    func saveResult(_ result: PieceMovementSessionResult) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        var results = (try? loadResults()) ?? []
        results.append(result)
        let data = try encoder.encode(results)
        try data.write(to: fileURL, options: [.atomic])
    }
}

struct PieceMovementPresentation: Hashable, Sendable {
    let task: String
    let progress: String
    let feedback: String?
    let selectedCount: Int

    var accessibilitySummary: String {
        [task, progress, "Selected \(selectedCount) squares", feedback]
            .compactMap { $0 }
            .joined(separator: ". ")
    }

    static func make(prompt: PieceMovementPrompt, selected: Set<ChessSquare>, completed: Int, limit: Int, feedback: String?) -> PieceMovementPresentation {
        PieceMovementPresentation(
            task: "Select every geometric movement square for the \(prompt.side.rawValue) \(prompt.piece.rawValue) on \(prompt.source.description). This mode ignores check, pins, castling, en passant, and promotion.",
            progress: "Prompt \(min(completed + 1, limit)) of \(limit)",
            feedback: feedback,
            selectedCount: selected.count
        )
    }
}

struct PieceMovementBoardCellPresentation: Identifiable, Hashable, Sendable {
    enum Role: Hashable, Sendable {
        case source
        case selected
        case friendly
        case enemy
        case light
        case dark
    }

    let id: String
    let square: ChessSquare
    let label: String
    let role: Role
    let accessibilityLabel: String

    static func cells(prompt: PieceMovementPrompt, selected: Set<ChessSquare>) -> [PieceMovementBoardCellPresentation] {
        (0..<64).compactMap { index in
            guard let square = SquareBoardMapping.square(forDisplayIndex: index, orientation: prompt.orientation) else { return nil }
            return PieceMovementBoardCellPresentation(
                id: square.description,
                square: square,
                label: label(for: square, prompt: prompt, selected: selected),
                role: role(for: square, prompt: prompt, selected: selected),
                accessibilityLabel: accessibilityLabel(for: square, prompt: prompt, selected: selected)
            )
        }
    }

    private static func label(for square: ChessSquare, prompt: PieceMovementPrompt, selected: Set<ChessSquare>) -> String {
        if square == prompt.source { return prompt.piece.rawValue.prefix(1).uppercased() }
        if selected.contains(square) { return "✓" }
        if prompt.occupancy.friendly.contains(square) { return "F" }
        if prompt.occupancy.enemy.contains(square) { return "E" }
        return square.description
    }

    private static func role(for square: ChessSquare, prompt: PieceMovementPrompt, selected: Set<ChessSquare>) -> Role {
        if selected.contains(square) { return .selected }
        if square == prompt.source { return .source }
        if prompt.occupancy.friendly.contains(square) { return .friendly }
        if prompt.occupancy.enemy.contains(square) { return .enemy }
        return square.color == .light ? .light : .dark
    }

    private static func accessibilityLabel(for square: ChessSquare, prompt: PieceMovementPrompt, selected: Set<ChessSquare>) -> String {
        var parts = ["Square \(square.description)", prompt.orientation == .black ? "Black orientation" : "White orientation"]
        if square == prompt.source { parts.append("source \(prompt.side.rawValue) \(prompt.piece.rawValue)") }
        if prompt.occupancy.friendly.contains(square) { parts.append("friendly blocker") }
        if prompt.occupancy.enemy.contains(square) { parts.append("enemy piece") }
        if selected.contains(square) { parts.append("selected") }
        return parts.joined(separator: ", ")
    }
}

@Observable
final class PieceMovementViewModel {
    private let configuration: PieceMovementConfiguration
    private let randomizerFactory: () -> ChallengeRandomizing
    private let clock: MonotonicTimeProviding
    private let historyStore: PieceMovementHistoryStoring
    private var session: PieceMovementSession
    private(set) var presentation: PieceMovementPresentation
    private(set) var prompt: PieceMovementPrompt
    private(set) var selected: Set<ChessSquare>
    private(set) var boardCells: [PieceMovementBoardCellPresentation]
    private(set) var inputLocked: Bool
    private(set) var score: Int
    private(set) var canAdvanceToNextPrompt: Bool
    private(set) var saveError: String?
    private(set) var isFinished = false
    private(set) var result: PieceMovementSessionResult?

    init?(
        configuration: PieceMovementConfiguration,
        randomizer: ChallengeRandomizing = SystemChallengeRandomizer(),
        clock: MonotonicTimeProviding = SystemMonotonicClock(),
        historyStore: PieceMovementHistoryStoring = PieceMovementHistoryStore()
    ) {
        self.configuration = configuration
        self.randomizerFactory = { randomizer }
        self.clock = clock
        self.historyStore = historyStore
        guard let initialState = Self.makeInitialState(configuration: configuration, randomizer: randomizer, clock: clock) else { return nil }
        self.session = initialState.session
        self.presentation = initialState.presentation
        self.prompt = initialState.prompt
        self.selected = initialState.selected
        self.boardCells = initialState.boardCells
        self.inputLocked = initialState.inputLocked
        self.score = initialState.score
        self.canAdvanceToNextPrompt = false
    }

    init?(
        configuration: PieceMovementConfiguration,
        randomizerFactory: @escaping () -> ChallengeRandomizing,
        clock: MonotonicTimeProviding = SystemMonotonicClock(),
        historyStore: PieceMovementHistoryStoring = PieceMovementHistoryStore()
    ) {
        self.configuration = configuration
        self.randomizerFactory = randomizerFactory
        self.clock = clock
        self.historyStore = historyStore
        guard let initialState = Self.makeInitialState(configuration: configuration, randomizer: randomizerFactory(), clock: clock) else { return nil }
        self.session = initialState.session
        self.presentation = initialState.presentation
        self.prompt = initialState.prompt
        self.selected = initialState.selected
        self.boardCells = initialState.boardCells
        self.inputLocked = initialState.inputLocked
        self.score = initialState.score
        self.canAdvanceToNextPrompt = false
    }

    func toggle(_ square: ChessSquare) {
        session.toggle(square)
        refresh(feedback: presentation.feedback)
    }

    func submit() {
        guard let evaluation = session.submit(at: Date().timeIntervalSinceReferenceDate) else { return }
        refresh(feedback: PieceMovementFeedback.message(for: evaluation.submission))
    }

    func advanceOrFinish() {
        if canAdvanceToNextPrompt, session.advance() {
            refresh(feedback: nil)
        } else {
            finish(reason: .completed)
        }
    }

    func playAgain() {
        guard let restartState = Self.makeInitialState(
            configuration: configuration,
            randomizer: randomizerFactory(),
            clock: clock
        ) else { return }
        session = restartState.session
        presentation = restartState.presentation
        prompt = restartState.prompt
        selected = restartState.selected
        boardCells = restartState.boardCells
        inputLocked = restartState.inputLocked
        score = restartState.score
        canAdvanceToNextPrompt = false
        saveError = nil
        isFinished = false
        result = nil
    }

    func finish(reason: TrainingFinishReason = .userExited) {
        guard !isFinished else { return }
        let result = session.result(reason: reason)
        self.result = result
        isFinished = true
        do {
            try historyStore.saveResult(result)
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
    }

    private func refresh(feedback: String?) {
        let currentPrompt = session.currentPrompt
        let currentSelected = session.selected
        prompt = currentPrompt
        selected = currentSelected
        boardCells = PieceMovementBoardCellPresentation.cells(prompt: currentPrompt, selected: currentSelected)
        inputLocked = session.inputLocked
        score = session.score
        canAdvanceToNextPrompt = session.inputLocked && session.result().promptCount < configuration.promptLimit
        presentation = PieceMovementPresentation.make(
            prompt: currentPrompt,
            selected: currentSelected,
            completed: session.result().promptCount,
            limit: configuration.promptLimit,
            feedback: feedback
        )
    }

    private static func makeInitialState(
        configuration: PieceMovementConfiguration,
        randomizer: ChallengeRandomizing,
        clock: MonotonicTimeProviding
    ) -> InitialState? {
        let generator = PieceMovementPromptGenerator(configuration: configuration, randomizer: randomizer)
        guard let session = PieceMovementSession(configuration: configuration, generator: generator, clock: clock) else { return nil }
        let prompt = session.currentPrompt
        let selected = session.selected
        return InitialState(
            session: session,
            presentation: PieceMovementPresentation.make(
                prompt: prompt,
                selected: selected,
                completed: session.result().promptCount,
                limit: configuration.promptLimit,
                feedback: nil
            ),
            prompt: prompt,
            selected: selected,
            boardCells: PieceMovementBoardCellPresentation.cells(prompt: prompt, selected: selected),
            inputLocked: session.inputLocked,
            score: session.score
        )
    }

    private struct InitialState {
        let session: PieceMovementSession
        let presentation: PieceMovementPresentation
        let prompt: PieceMovementPrompt
        let selected: Set<ChessSquare>
        let boardCells: [PieceMovementBoardCellPresentation]
        let inputLocked: Bool
        let score: Int
    }
}

struct PieceMovementGameView: View {
    @State var viewModel: PieceMovementViewModel

    var body: some View {
        ScrollView {
            if viewModel.isFinished, let result = viewModel.result {
                completionSummary(result)
                    .padding()
            } else {
                activeGame
                    .padding()
            }
        }
        .navigationTitle("Piece Movement")
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.isFinished ? "Piece Movement complete" : viewModel.presentation.accessibilitySummary)
    }

    private var activeGame: some View {
        VStack(spacing: 16) {
            Text(viewModel.presentation.task)
                .font(.headline)
                .accessibilityIdentifier("pieceMovement.task")

            board
                .id(boardIdentity)

            Text(viewModel.presentation.progress)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("pieceMovement.progress")

            Text("Score \(viewModel.score)")
                .font(.subheadline.monospacedDigit())
                .accessibilityIdentifier("pieceMovement.score")

            if let feedback = viewModel.presentation.feedback {
                Text(feedback)
                    .font(.headline)
                    .accessibilityIdentifier("pieceMovement.feedback")
                Button(viewModel.canAdvanceToNextPrompt ? "Next" : "Finish") { viewModel.advanceOrFinish() }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier(viewModel.canAdvanceToNextPrompt ? "pieceMovement.next" : "pieceMovement.finish")
            } else {
                Button("Submit") { viewModel.submit() }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("pieceMovement.submit")
            }
        }
    }

    private func completionSummary(_ result: PieceMovementSessionResult) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            Text("Piece Movement Complete")
                .font(.title2.weight(.bold))
                .accessibilityIdentifier("pieceMovement.resultsTitle")

            VStack(spacing: 10) {
                summaryRow("Score", "\(viewModel.score)")
                summaryRow("Prompts", "\(result.promptCount)")
                summaryRow("Exact", "\(result.exactCount)")
                summaryRow("Partial", "\(result.partialCount)")
                summaryRow("Best streak", "\(result.bestStreak)")
            }
            .padding()
            .background(.secondary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .accessibilityIdentifier("pieceMovement.resultsSummary")

            Button("Play Again") { viewModel.playAgain() }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("pieceMovement.playAgain")

            if let saveError = viewModel.saveError {
                Text("History could not be saved: \(saveError)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("pieceMovement.saveError")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline.monospacedDigit())
        }
    }

    private var boardIdentity: String {
        [
            viewModel.prompt.source.description,
            viewModel.prompt.piece.rawValue,
            viewModel.prompt.side.rawValue,
            viewModel.selected.map(\.description).sorted().joined(separator: ",")
        ].joined(separator: "|")
    }

    private var board: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 0) {
            ForEach(viewModel.boardCells) { cell in
                Button {
                    viewModel.toggle(cell.square)
                } label: {
                    Text(cell.label)
                        .frame(maxWidth: .infinity, minHeight: 42)
                        .contentShape(Rectangle())
                }
                .background(backgroundOpacity(for: cell.role))
                .buttonStyle(.plain)
                .disabled(viewModel.inputLocked)
                .accessibilityLabel(cell.accessibilityLabel)
                .accessibilityIdentifier("pieceMovement.square.\(cell.square.description)")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func backgroundOpacity(for role: PieceMovementBoardCellPresentation.Role) -> Color {
        switch role {
        case .selected:
            return Color.accentColor.opacity(0.45)
        case .source:
            return Color.orange.opacity(0.45)
        case .friendly:
            return Color.gray.opacity(0.45)
        case .enemy:
            return Color.red.opacity(0.25)
        case .light:
            return Color.secondary.opacity(0.15)
        case .dark:
            return Color.secondary.opacity(0.35)
        }
    }
}
