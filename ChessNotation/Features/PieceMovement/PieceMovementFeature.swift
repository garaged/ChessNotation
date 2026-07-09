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
    private let historyStore: PieceMovementHistoryStoring
    private var session: PieceMovementSession
    private(set) var presentation: PieceMovementPresentation
    private(set) var prompt: PieceMovementPrompt
    private(set) var selected: Set<ChessSquare>
    private(set) var boardCells: [PieceMovementBoardCellPresentation]
    private(set) var inputLocked: Bool
    private(set) var score: Int
    private(set) var saveError: String?
    private(set) var isFinished = false
    private(set) var result: PieceMovementSessionResult?

    init?(
        configuration: PieceMovementConfiguration,
        randomizer: ChallengeRandomizing = SystemChallengeRandomizer(),
        clock: MonotonicTimeProviding = SystemMonotonicClock(),
        historyStore: PieceMovementHistoryStoring = PieceMovementHistoryStore()
    ) {
        let generator = PieceMovementPromptGenerator(configuration: configuration, randomizer: randomizer)
        guard let session = PieceMovementSession(configuration: configuration, generator: generator, clock: clock) else { return nil }
        let initialPrompt = session.currentPrompt
        let initialSelected = session.selected
        let initialPresentation = PieceMovementPresentation.make(
            prompt: initialPrompt,
            selected: initialSelected,
            completed: session.result().promptCount,
            limit: configuration.promptLimit,
            feedback: nil
        )
        self.configuration = configuration
        self.historyStore = historyStore
        self.session = session
        self.presentation = initialPresentation
        self.prompt = initialPrompt
        self.selected = initialSelected
        self.boardCells = PieceMovementBoardCellPresentation.cells(prompt: initialPrompt, selected: initialSelected)
        self.inputLocked = session.inputLocked
        self.score = session.score
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
        if session.advance() {
            refresh(feedback: nil)
        } else {
            finish(reason: .completed)
        }
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
        presentation = PieceMovementPresentation.make(
            prompt: currentPrompt,
            selected: currentSelected,
            completed: session.result().promptCount,
            limit: configuration.promptLimit,
            feedback: feedback
        )
    }
}

struct PieceMovementGameView: View {
    @State var viewModel: PieceMovementViewModel

    var body: some View {
        ScrollView {
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
                    Button("Next") { viewModel.advanceOrFinish() }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("pieceMovement.next")
                } else {
                    Button("Submit") { viewModel.submit() }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("pieceMovement.submit")
                }
            }
            .padding()
        }
        .navigationTitle("Piece Movement")
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.presentation.accessibilitySummary)
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
