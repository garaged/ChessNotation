import SwiftUI

struct GameTrainingView: View {
    @Environment(AppSettings.self) private var appSettings
    @State var viewModel: GameViewModel
    @FocusState private var isAnswerFieldFocused: Bool

    var body: some View {
        Group {
            if viewModel.isFinished {
                ResultsView(summary: viewModel.summary) {
                    viewModel.reset()
                    refocusAnswerFieldIfNeeded()
                }
            } else {
                trainingContent
            }
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
                        showsEvaluation: appSettings.isEvaluationEnabled(for: viewModel.game.difficulty)
                    )
                        .padding(.horizontal)

                    VStack(spacing: 8) {
                        Text("\(move.side.displayName) to move")
                            .font(.headline)

                        TextField("Enter SAN, e.g. Nf3", text: $viewModel.answerText)
                            .focused($isAnswerFieldFocused)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .accessibilityIdentifier("game.answerField")
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                            .accessibilityIdentifier("game.submitButton")

                            Button("Reveal") {
                                viewModel.skipMove()
                                refocusAnswerFieldIfNeeded()
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("game.revealButton")
                        }
                    }
                    .padding(.horizontal)
                }

                feedbackCard
            }
            .padding(.vertical, 10)
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text(viewModel.progressText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("game.progressText")
            ProgressView(value: Double(viewModel.currentMoveIndex), total: Double(max(viewModel.game.moves.count, 1)))
                .padding(.horizontal)
            Text(viewModel.attemptsText)
                .font(.caption)
                .foregroundStyle(.secondary)
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

    private func refocusAnswerFieldIfNeeded() {
        isAnswerFieldFocused = !viewModel.isFinished && viewModel.currentMove != nil
    }
}
