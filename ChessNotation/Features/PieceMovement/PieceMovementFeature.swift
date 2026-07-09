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

@Observable
final class PieceMovementViewModel {
    private let configuration: PieceMovementConfiguration
    private let historyStore: PieceMovementHistoryStoring
    private var session: PieceMovementSession
    private(set) var presentation: PieceMovementPresentation
    private(set) var prompt: PieceMovementPrompt
    private(set) var selected: Set<ChessSquare>
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
        let initialPresentation = PieceMovementPresentation.make(
            prompt: session.currentPrompt,
            selected: session.selected,
            completed: session.result().promptCount,
            limit: configuration.promptLimit,
            feedback: nil
        )
        self.configuration = configuration
        self.historyStore = historyStore
        self.session = session
        self.presentation = initialPresentation
        self.prompt = session.currentPrompt
        self.selected = session.selected
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
        prompt = session.currentPrompt
        selected = session.selected
        inputLocked = session.inputLocked
        score = session.score
        presentation = PieceMovementPresentation.make(
            prompt: session.currentPrompt,
            selected: session.selected,
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
                    .id(viewModel.prompt.source.description + viewModel.prompt.piece.rawValue + viewModel.prompt.side.rawValue)

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

    private var board: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 0) {
            ForEach(0..<64, id: \.self) { index in
                let square = SquareBoardMapping.square(forDisplayIndex: index, orientation: viewModel.prompt.orientation)!
                Button(label(for: square)) { viewModel.toggle(square) }
                    .frame(maxWidth: .infinity, minHeight: 42)
                    .background(backgroundOpacity(for: square))
                    .buttonStyle(.plain)
                    .disabled(viewModel.inputLocked)
                    .accessibilityLabel(accessibilityLabel(for: square))
                    .accessibilityIdentifier("pieceMovement.square.\(square.description)")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func label(for square: ChessSquare) -> String {
        if square == viewModel.prompt.source { return viewModel.prompt.piece.rawValue.prefix(1).uppercased() }
        if viewModel.selected.contains(square) { return "✓" }
        if viewModel.prompt.occupancy.friendly.contains(square) { return "F" }
        if viewModel.prompt.occupancy.enemy.contains(square) { return "E" }
        return square.description
    }

    private func backgroundOpacity(for square: ChessSquare) -> Color {
        if viewModel.selected.contains(square) { return Color.accentColor.opacity(0.45) }
        if square == viewModel.prompt.source { return Color.orange.opacity(0.45) }
        if viewModel.prompt.occupancy.friendly.contains(square) { return Color.gray.opacity(0.45) }
        if viewModel.prompt.occupancy.enemy.contains(square) { return Color.red.opacity(0.25) }
        return square.color == .light ? Color.secondary.opacity(0.15) : Color.secondary.opacity(0.35)
    }

    private func accessibilityLabel(for square: ChessSquare) -> String {
        var parts = ["Square \(square.description)", viewModel.prompt.orientation == .black ? "Black orientation" : "White orientation"]
        if square == viewModel.prompt.source { parts.append("source \(viewModel.prompt.side.rawValue) \(viewModel.prompt.piece.rawValue)") }
        if viewModel.prompt.occupancy.friendly.contains(square) { parts.append("friendly blocker") }
        if viewModel.prompt.occupancy.enemy.contains(square) { parts.append("enemy piece") }
        if viewModel.selected.contains(square) { parts.append("selected") }
        return parts.joined(separator: ", ")
    }
}
