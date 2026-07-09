import Observation
import SwiftUI

@Observable
final class PositionRecallReconstructionViewModel {
    private let configuration: PositionRecallReconstructionConfiguration
    private let historyStore: PositionRecallReconstructionHistoryStoring
    private var session: PositionRecallReconstructionSession
    private(set) var feedback: String?
    private(set) var saveError: String?
    private(set) var savedResult: PositionRecallSessionResult?

    init?(
        configuration: PositionRecallReconstructionConfiguration,
        snapshots: [PositionRecallSnapshot],
        randomizer: ChallengeRandomizing = SystemChallengeRandomizer(),
        clock: MonotonicTimeProviding = SystemMonotonicClock(),
        historyStore: PositionRecallReconstructionHistoryStoring = PositionRecallReconstructionHistoryStore()
    ) {
        let generator = PositionRecallReconstructionPromptGenerator(
            snapshots: snapshots,
            difficulty: configuration.difficulty,
            orientation: configuration.orientation,
            randomizer: randomizer
        )
        guard let session = PositionRecallReconstructionSession(
            configuration: configuration,
            generator: generator,
            clock: clock
        ) else { return nil }
        self.configuration = configuration
        self.historyStore = historyStore
        self.session = session
    }

    var phase: PositionRecallPhase { session.phase }
    var prompt: PositionRecallReconstructionPrompt { session.currentPrompt }
    var answer: PositionRecallReconstructionAnswer { session.answer }
    var score: Int { session.score }
    var progressText: String { "Prompt \(min(session.promptCount + 1, configuration.promptLimit)) of \(configuration.promptLimit)" }
    var accessibilitySummary: String {
        PositionRecallReconstructionFeedback.accessibilityDescription(
            prompt: prompt,
            answer: answer,
            progress: progressText
        )
    }

    func refresh() {
        session.refresh()
    }

    func place(_ piece: PositionRecallPiece, at square: ChessSquare) {
        session.place(piece, at: square)
    }

    func clear(_ square: ChessSquare) {
        session.clear(square)
    }

    func submit() {
        guard let submission = session.submit() else { return }
        feedback = PositionRecallReconstructionFeedback.message(for: submission.evaluation)
        let result = session.result()
        savedResult = result
        do {
            try historyStore.saveResult(result)
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
    }

    func advance() {
        if session.advance() {
            feedback = nil
            savedResult = nil
        }
    }

    func pieceLabel(at square: ChessSquare) -> String {
        if phase == .studying, let piece = prompt.snapshot.piece(at: square) {
            return shortLabel(for: piece)
        }
        if let reconstructed = answer.pieces.first(where: { $0.square == square })?.piece {
            return shortLabel(for: reconstructed)
        }
        return prompt.maskedSquares.contains(square) ? "?" : square.description
    }

    func accessibilityLabel(for square: ChessSquare) -> String {
        var parts = ["Square \(square.description)", prompt.orientation == .black ? "Black orientation" : "White orientation"]
        if phase == .studying, let piece = prompt.snapshot.piece(at: square) {
            parts.append("visible \(piece.side.rawValue) \(piece.piece.rawValue)")
        } else if prompt.maskedSquares.contains(square) {
            parts.append("masked square")
        }
        if let reconstructed = answer.pieces.first(where: { $0.square == square })?.piece {
            parts.append("reconstructed \(reconstructed.side.rawValue) \(reconstructed.piece.rawValue)")
        }
        return parts.joined(separator: ", ")
    }

    private func shortLabel(for piece: PositionRecallPiece) -> String {
        let prefix = piece.side == .white ? "W" : "B"
        return prefix + piece.piece.rawValue.prefix(1).uppercased()
    }
}

struct PositionRecallReconstructionView: View {
    @State var viewModel: PositionRecallReconstructionViewModel
    @State private var selectedPiece: TrainingPiece = .king
    @State private var selectedSide: TrainingSide = .white

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .accessibilityIdentifier("positionRecall.task")

                Text(viewModel.progressText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("positionRecall.progress")

                board

                controls

                if let feedback = viewModel.feedback {
                    Text(feedback)
                        .font(.headline)
                        .accessibilityIdentifier("positionRecall.feedback")
                    Button("Next") { viewModel.advance() }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("positionRecall.next")
                }

                if let saveError = viewModel.saveError {
                    Text("History save failed: \(saveError)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Position Recall")
        .onAppear { viewModel.refresh() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.accessibilitySummary)
    }

    private var title: String {
        switch viewModel.phase {
        case .studying:
            return "Study the position"
        case .answering:
            return "Reconstruct the hidden pieces"
        case .finished:
            return "Recall result"
        }
    }

    private var board: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 0) {
            ForEach(0..<64, id: \.self) { index in
                let square = SquareBoardMapping.square(forDisplayIndex: index, orientation: viewModel.prompt.orientation)!
                Button(viewModel.pieceLabel(at: square)) {
                    if viewModel.phase == .answering {
                        viewModel.place(PositionRecallPiece(piece: selectedPiece, side: selectedSide), at: square)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(background(for: square))
                .buttonStyle(.plain)
                .disabled(viewModel.phase != .answering)
                .accessibilityLabel(viewModel.accessibilityLabel(for: square))
                .accessibilityIdentifier("positionRecall.square.\(square.description)")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var controls: some View {
        switch viewModel.phase {
        case .studying:
            Button("Hide now") { viewModel.refresh() }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("positionRecall.hideNow")
        case .answering:
            VStack(spacing: 10) {
                Picker("Side", selection: $selectedSide) {
                    Text("White").tag(TrainingSide.white)
                    Text("Black").tag(TrainingSide.black)
                }
                .pickerStyle(.segmented)

                Picker("Piece", selection: $selectedPiece) {
                    ForEach(TrainingPiece.allCases, id: \.self) { piece in
                        Text(piece.rawValue.capitalized).tag(piece)
                    }
                }

                Button("Clear selected square") {
                    if let first = viewModel.answer.pieces.first {
                        viewModel.clear(first.square)
                    }
                }
                .buttonStyle(.bordered)

                Button("Submit recall") { viewModel.submit() }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("positionRecall.submit")
            }
        case .finished:
            EmptyView()
        }
    }

    private func background(for square: ChessSquare) -> Color {
        if viewModel.answer.pieces.contains(where: { $0.square == square }) {
            return Color.accentColor.opacity(0.45)
        }
        if viewModel.prompt.maskedSquares.contains(square) && viewModel.phase != .studying {
            return Color.orange.opacity(0.35)
        }
        return square.color == .light ? Color.secondary.opacity(0.15) : Color.secondary.opacity(0.35)
    }
}
