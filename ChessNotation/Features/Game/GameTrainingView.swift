import SwiftUI

struct GameTrainingView: View {
    @Environment(AppSettings.self) private var appSettings
    @State var viewModel: GameViewModel

    var body: some View {
        Group {
            if viewModel.isFinished {
                ResultsView(summary: viewModel.summary) {
                    viewModel.reset()
                }
            } else {
                trainingContent
            }
        }
        .navigationTitle(viewModel.game.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var trainingContent: some View {
        ScrollView {
            VStack(spacing: 10) {
                statsCard
                header

                if let move = viewModel.currentMove {
                    ChessBoardView(
                        fen: move.fenBefore,
                        highlightedMove: move,
                        showsEvaluation: appSettings.isEvaluationEnabled(for: viewModel.game.difficulty)
                    )
                        .padding(.horizontal)

                    VStack(spacing: 6) {
                        notationAnswerField

                        ChessNotationKeyboard(
                            onKey: viewModel.appendToAnswer,
                            onBackspace: viewModel.removeLastAnswerCharacter,
                            onClear: viewModel.clearAnswer,
                            onSubmit: viewModel.submitAnswer,
                            enabledKeys: ChessNotationKeyAvailability.availableKeys(for: viewModel.answerText)
                        )

                        HStack {
                            Button("Reveal") {
                                viewModel.skipMove()
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("game.revealButton")
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal)
                }

                feedbackCard
            }
            .padding(.vertical, 10)
        }
    }

    private var notationAnswerField: some View {
        HStack(spacing: 8) {
            Text(viewModel.answerText.isEmpty ? "Enter SAN, e.g. Nf3" : viewModel.answerText)
                .font(.title3.monospaced())
                .foregroundStyle(viewModel.answerText.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .accessibilityIdentifier("game.answerField")
                .accessibilityLabel("Move answer")
                .accessibilityValue(viewModel.answerText.isEmpty ? "Empty" : viewModel.answerText)

            Divider()
                .frame(height: 24)

            Button {
                viewModel.removeLastAnswerCharacter()
            } label: {
                Image(systemName: "delete.left")
                    .font(.body.weight(.semibold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.answerText.isEmpty)
            .accessibilityIdentifier("game.answerBackspaceButton")
            .accessibilityLabel("Backspace")

            Button {
                viewModel.submitAnswer()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.answerText.isEmpty)
            .accessibilityIdentifier("game.answerSubmitButton")
            .accessibilityLabel("Submit move")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var header: some View {
        VStack(spacing: 4) {
            ProgressView(value: Double(viewModel.currentMoveIndex), total: Double(max(viewModel.game.moves.count, 1)))
                .padding(.horizontal)

            Text(viewModel.progressAttemptsText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("game.progressText")
        }
    }

    private var statsCard: some View {
        HStack(spacing: 8) {
            statPill(title: "Solved", value: "\(viewModel.completedMoves)")
            statPill(title: "Accuracy", value: viewModel.accuracyText)
            statPill(title: "1st Try", value: "\(viewModel.firstTryCorrectMoves)")
        }
        .padding(.horizontal)
    }

    private var feedbackCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Feedback")
                .font(.headline)
            Text(viewModel.feedback)
                .font(.body)
                .foregroundStyle(.primary)
                .accessibilityIdentifier("game.feedbackText")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
