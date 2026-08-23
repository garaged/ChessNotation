import Observation
import SwiftUI

@Observable
final class PositionRecallReconstructionViewModel {
    private let configuration: PositionRecallReconstructionConfiguration
    private let snapshots: [PositionRecallSnapshot]
    private let randomizerFactory: () -> ChallengeRandomizing
    private let clock: MonotonicTimeProviding
    private let historyStore: PositionRecallReconstructionHistoryStoring
    private var session: PositionRecallReconstructionSession
    private(set) var phase: PositionRecallPhase
    private(set) var prompt: PositionRecallReconstructionPrompt
    private(set) var answer: PositionRecallReconstructionAnswer
    private(set) var score: Int
    private(set) var canAdvanceToNextPrompt: Bool
    private(set) var isComplete: Bool
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
        self.configuration = configuration
        self.snapshots = snapshots
        self.randomizerFactory = { randomizer }
        self.clock = clock
        self.historyStore = historyStore
        guard let session = Self.makeSession(
            configuration: configuration,
            snapshots: snapshots,
            randomizer: randomizer,
            clock: clock
        ) else { return nil }
        self.session = session
        self.phase = session.phase
        self.prompt = session.currentPrompt
        self.answer = session.answer
        self.score = session.score
        self.canAdvanceToNextPrompt = false
        self.isComplete = false
    }

    init?(
        configuration: PositionRecallReconstructionConfiguration,
        snapshots: [PositionRecallSnapshot],
        randomizerFactory: @escaping () -> ChallengeRandomizing,
        clock: MonotonicTimeProviding = SystemMonotonicClock(),
        historyStore: PositionRecallReconstructionHistoryStoring = PositionRecallReconstructionHistoryStore()
    ) {
        self.configuration = configuration
        self.snapshots = snapshots
        self.randomizerFactory = randomizerFactory
        self.clock = clock
        self.historyStore = historyStore
        guard let session = Self.makeSession(
            configuration: configuration,
            snapshots: snapshots,
            randomizer: randomizerFactory(),
            clock: clock
        ) else { return nil }
        self.session = session
        self.phase = session.phase
        self.prompt = session.currentPrompt
        self.answer = session.answer
        self.score = session.score
        self.canAdvanceToNextPrompt = false
        self.isComplete = false
    }

    var progressText: String { "Prompt \(min(session.promptCount + 1, configuration.promptLimit)) of \(configuration.promptLimit)" }
    var accessibilitySummary: String {
        if isComplete { return "Position Recall complete" }
        return PositionRecallReconstructionFeedback.accessibilityDescription(
            prompt: prompt,
            answer: answer,
            progress: progressText
        )
    }

    func refresh() {
        session.refresh()
        syncSessionState()
    }

    func hideNow() {
        session.hideNow()
        syncSessionState()
    }

    func place(_ piece: PositionRecallPiece, at square: ChessSquare) {
        session.place(piece, at: square)
        syncSessionState()
    }

    func clear(_ square: ChessSquare) {
        session.clear(square)
        syncSessionState()
    }

    func submit() {
        guard let submission = session.submit() else { return }
        syncSessionState()
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

    func advanceOrFinish() {
        if canAdvanceToNextPrompt, session.advance() {
            feedback = nil
            savedResult = nil
            syncSessionState()
        } else {
            finish()
        }
    }

    @discardableResult
    func handleExternalKeyboardCommand(_ command: ExternalKeyboardTrainingCommand) -> Bool {
        guard !isComplete else { return false }

        switch command {
        case .submitPrimaryAction:
            switch phase {
            case .studying:
                hideNow()
            case .answering:
                submit()
            case .finished:
                advanceOrFinish()
            }
            return true
        case .secondaryAction:
            finish(reason: .userExited)
            return true
        case .moveFocusForward, .moveFocusBackward:
            return true
        case .insertText, .deleteBackward, .clearAnswer:
            return false
        }
    }

    func playAgain() {
        guard let newSession = Self.makeSession(
            configuration: configuration,
            snapshots: snapshots,
            randomizer: randomizerFactory(),
            clock: clock
        ) else { return }
        session = newSession
        feedback = nil
        saveError = nil
        savedResult = nil
        isComplete = false
        syncSessionState()
    }

    func displayedPiece(at square: ChessSquare) -> PositionRecallPiece? {
        if let reconstructed = answer.pieces.first(where: { $0.square == square })?.piece {
            return reconstructed
        }
        if phase == .studying {
            return prompt.snapshot.piece(at: square)
        }
        if !prompt.maskedSquares.contains(square) {
            return prompt.snapshot.piece(at: square)
        }
        return nil
    }

    func isMaskedPlaceholder(at square: ChessSquare) -> Bool {
        phase != .studying && prompt.maskedSquares.contains(square) && !answer.pieces.contains(where: { $0.square == square })
    }

    func isReconstructed(at square: ChessSquare) -> Bool {
        answer.pieces.contains { $0.square == square }
    }

    func pieceLabel(at square: ChessSquare) -> String {
        if let piece = displayedPiece(at: square) {
            return shortLabel(for: piece)
        }
        return isMaskedPlaceholder(at: square) ? "?" : square.description
    }

    func accessibilityLabel(for square: ChessSquare) -> String {
        var parts = ["Square \(square.description)", prompt.orientation == .black ? "Black orientation" : "White orientation"]
        if phase == .studying, let piece = prompt.snapshot.piece(at: square) {
            parts.append("visible \(piece.side.rawValue) \(piece.piece.rawValue)")
        } else if prompt.maskedSquares.contains(square) {
            parts.append("masked square")
        } else if let visiblePiece = prompt.snapshot.piece(at: square) {
            parts.append("visible \(visiblePiece.side.rawValue) \(visiblePiece.piece.rawValue)")
        }
        if let reconstructed = answer.pieces.first(where: { $0.square == square })?.piece {
            parts.append("reconstructed \(reconstructed.side.rawValue) \(reconstructed.piece.rawValue)")
        }
        return parts.joined(separator: ", ")
    }

    private func finish(reason: TrainingFinishReason = .completed) {
        savedResult = savedResult ?? session.result(reason: reason)
        isComplete = true
        canAdvanceToNextPrompt = false
    }

    private func syncSessionState() {
        phase = session.phase
        prompt = session.currentPrompt
        answer = session.answer
        score = session.score
        canAdvanceToNextPrompt = phase == .finished && session.promptCount < configuration.promptLimit
    }

    private static func makeSession(
        configuration: PositionRecallReconstructionConfiguration,
        snapshots: [PositionRecallSnapshot],
        randomizer: ChallengeRandomizing,
        clock: MonotonicTimeProviding
    ) -> PositionRecallReconstructionSession? {
        let generator = PositionRecallReconstructionPromptGenerator(
            snapshots: snapshots,
            difficulty: configuration.difficulty,
            orientation: configuration.orientation,
            randomizer: randomizer
        )
        return PositionRecallReconstructionSession(
            configuration: configuration,
            generator: generator,
            clock: clock
        )
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
            if viewModel.isComplete, let result = viewModel.savedResult {
                completionSummary(result)
                    .padding()
            } else {
                activeGame
                    .padding()
            }
        }
        .navigationTitle("Position Recall")
        .onAppear { viewModel.refresh() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.accessibilitySummary)
    }

    private var activeGame: some View {
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
                Button(viewModel.canAdvanceToNextPrompt ? "Next" : "Finish") { viewModel.advanceOrFinish() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [])
                    .accessibilityIdentifier(viewModel.canAdvanceToNextPrompt ? "positionRecall.next" : "positionRecall.finish")
            }

            if let saveError = viewModel.saveError {
                Text("History save failed: \(saveError)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func completionSummary(_ result: PositionRecallSessionResult) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            Text("Position Recall Complete")
                .font(.title2.weight(.bold))
                .accessibilityIdentifier("positionRecall.resultsTitle")

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
            .accessibilityIdentifier("positionRecall.resultsSummary")

            Button("Play Again") { viewModel.playAgain() }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: [])
                .accessibilityIdentifier("positionRecall.playAgain")

            if let saveError = viewModel.saveError {
                Text("History could not be saved: \(saveError)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
        ThemedMiniGameBoard(orientation: viewModel.prompt.orientation) { square, squareSize, palette in
            Button {
                if viewModel.phase == .answering {
                    viewModel.place(PositionRecallPiece(piece: selectedPiece, side: selectedSide), at: square)
                }
            } label: {
                ZStack {
                    squareOverlay(for: square, palette: palette)
                    squareContent(for: square, squareSize: squareSize, palette: palette)
                }
                .frame(width: squareSize, height: squareSize)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(viewModel.phase != .answering)
            .accessibilityLabel(viewModel.accessibilityLabel(for: square))
            .accessibilityIdentifier("positionRecall.square.\(square.description)")
        }
        .id(boardIdentity)
    }

    private var boardIdentity: String {
        [
            viewModel.phase.rawValue,
            viewModel.prompt.maskedSquares.map(\.description).sorted().joined(separator: ","),
            viewModel.answer.pieces.map { "\($0.square.description)-\($0.piece.side.rawValue)-\($0.piece.piece.rawValue)" }.sorted().joined(separator: ",")
        ].joined(separator: "|")
    }

    @ViewBuilder
    private func squareOverlay(for square: ChessSquare, palette: ChessVisualPalette) -> some View {
        if viewModel.isReconstructed(at: square) {
            Rectangle().fill(PremiumDesign.Accent.practice.color.opacity(0.35))
        } else if viewModel.isMaskedPlaceholder(at: square) {
            Rectangle().fill(PremiumDesign.Accent.timed.color.opacity(0.26))
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func squareContent(for square: ChessSquare, squareSize: CGFloat, palette: ChessVisualPalette) -> some View {
        if let piece = viewModel.displayedPiece(at: square) {
            ChessPieceGraphic(piece: piece.chessPiece)
                .frame(width: squareSize * 0.82, height: squareSize * 0.82)
                .shadow(color: palette.piecePalette(for: piece.chessPiece.side).shadow, radius: 1.4, x: 0, y: 1)
        } else if viewModel.isMaskedPlaceholder(at: square) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: max(16, squareSize * 0.42), weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(PremiumDesign.Accent.timed.color)
        }
    }

    @ViewBuilder
    private var controls: some View {
        switch viewModel.phase {
        case .studying:
            Button("Hide now") { viewModel.hideNow() }
                .buttonStyle(.bordered)
                .keyboardShortcut(.return, modifiers: [])
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
                    .keyboardShortcut(.return, modifiers: [])
                    .accessibilityIdentifier("positionRecall.submit")
            }
        case .finished:
            EmptyView()
        }
    }
}
