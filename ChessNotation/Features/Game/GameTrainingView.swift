import SwiftUI

struct GameTrainingView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: GameViewModel
    @FocusState private var isAnswerFieldFocused: Bool

    var body: some View {
        Group {
            if viewModel.isFinished {
                ResultsView(summary: viewModel.summary) {
                    viewModel.reset()
                    refocusAnswerFieldIfNeeded()
                } startNewGame: {
                    dismiss()
                }
            } else {
                trainingContent
            }
        }
        .task(id: viewModel.isFinished) {
            await runCountdownIfNeeded()
        }
        .onAppear {
            refocusAnswerFieldIfNeeded()
        }
        .onChange(of: viewModel.currentMoveIndex) { _, _ in
            refocusAnswerFieldIfNeeded()
        }
        .onChange(of: viewModel.isFinished) { _, _ in
            refocusAnswerFieldIfNeeded()
        }
        .navigationTitle(viewModel.game.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var trainingContent: some View {
        ScrollView {
            VStack(spacing: 12) {
                header
                statsCard

                if let move = viewModel.currentMove {
                    ChessBoardView(
                        fen: move.fenBefore,
                        highlightedMove: move,
                        showsEvaluation: appSettings.isEvaluationEnabled(for: viewModel.game.difficulty),
                        showsCoordinates: appSettings.showBoardCoordinates
                    )
                        .padding(.horizontal)

                    VStack(spacing: 8) {
                        Text("\(move.side.displayName) to move")
                            .font(.headline)
                            .foregroundStyle(PremiumDesign.primaryText)

                        TextField("Enter SAN, e.g. Nf3", text: $viewModel.answerText)
                            .focused($isAnswerFieldFocused)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .accessibilityIdentifier("game.answerField")
                            .padding(12)
                            .foregroundStyle(PremiumDesign.primaryText)
                            .background(PremiumDesign.elevatedSurface)
                            .clipShape(RoundedRectangle(cornerRadius: PremiumDesign.Radius.medium))
                            .overlay {
                                RoundedRectangle(cornerRadius: PremiumDesign.Radius.medium)
                                    .stroke(PremiumDesign.stroke, lineWidth: 1)
                            }
                            .onSubmit {
                                viewModel.submitAnswer()
                                refocusAnswerFieldIfNeeded()
                            }

                        HStack {
                            Button("Submit") {
                                viewModel.submitAnswer()
                                refocusAnswerFieldIfNeeded()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(PremiumDesign.Accent.practice.color)
                            .accessibilityIdentifier("game.submitButton")

                            Button("Reveal") {
                                viewModel.skipMove()
                                refocusAnswerFieldIfNeeded()
                            }
                            .buttonStyle(.bordered)
                            .tint(PremiumDesign.Accent.learning.color)
                            .accessibilityIdentifier("game.revealButton")
                        }
                    }
                    .padding(.horizontal)
                }

                feedbackCard
            }
            .padding(.vertical, 10)
        }
        .premiumScreenBackground()
    }

    private var header: some View {
        VStack(spacing: 6) {
            if viewModel.isTimed, let timerText = viewModel.timerText {
                Text(timerText)
                    .font(.title2.monospacedDigit().weight(.bold))
                    .foregroundStyle(viewModel.isLowTime ? PremiumDesign.Accent.danger.color : PremiumDesign.primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(timerBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityIdentifier("game.timerText")
                    .accessibilityLabel("Timed mode, \(timerText) remaining")
                    .accessibilityValue(viewModel.selectedDurationText.map { "Selected duration \($0)" } ?? "Timed game")
            }

            Text(viewModel.progressText)
                .font(.subheadline)
                .foregroundStyle(PremiumDesign.secondaryText)
                .accessibilityIdentifier("game.progressText")
            ProgressView(value: Double(viewModel.currentMoveIndex), total: Double(max(viewModel.game.moves.count, 1)))
                .padding(.horizontal)
            Text(viewModel.attemptsText)
                .font(.caption)
                .foregroundStyle(PremiumDesign.secondaryText)
        }
    }

    private var timerBackground: some ShapeStyle {
        viewModel.isLowTime ? PremiumDesign.Accent.danger.color.opacity(0.16) : PremiumDesign.elevatedSurface
    }

    private var statsCard: some View {
        HStack(spacing: 8) {
            PremiumMetricPill(title: "Solved", value: "\(viewModel.completedMoves)", accent: .practice)
            PremiumMetricPill(title: "Accuracy", value: viewModel.accuracyText, accent: .brand)
            PremiumMetricPill(title: "1st Try", value: "\(viewModel.firstTryCorrectMoves)", accent: .timed)
        }
        .padding(.horizontal)
    }

    private var feedbackCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Feedback")
                .font(.headline)
                .foregroundStyle(PremiumDesign.primaryText)
            Text(viewModel.feedback)
                .font(.body)
                .foregroundStyle(PremiumDesign.primaryText)
                .accessibilityIdentifier("game.feedbackText")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .premiumPanel(accent: .brand)
        .padding(.horizontal)
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.monospacedDigit())
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.caption2)
                .foregroundStyle(PremiumDesign.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func refocusAnswerFieldIfNeeded() {
        isAnswerFieldFocused = !viewModel.isFinished && viewModel.currentMove != nil
    }

    private func runCountdownIfNeeded() async {
        guard viewModel.isTimed, !viewModel.isFinished else { return }

        while !Task.isCancelled && !viewModel.isFinished {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                viewModel.tickTimer()
            }
        }
    }
}
