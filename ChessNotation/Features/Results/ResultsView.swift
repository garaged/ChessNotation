import SwiftUI

struct ResultsView: View {
    @Environment(\.dismiss) private var dismiss

    let summary: TrainingSessionSummary
    var historySaveError: String?
    let restart: () -> Void
    var startNewGame: (() -> Void)?

    var body: some View {
        List {
            Section("Session") {
                metricRow("Game", summary.game.title)
                metricRow("Completed moves", "\(summary.completedMoves)")
                metricRow("Accuracy", summary.accuracy.formatted(.percent.precision(.fractionLength(0))))
                metricRow("Average move time", summary.averageMoveTime.formattedMoveTime)
                metricRow("First-try correct", "\(summary.firstTryCorrect)")
            }

            if summary.mode.isTimed {
                Section("Timed game") {
                    metricRow("Finish reason", summary.finishReason.displayName)
                    metricRow("Selected duration", summary.selectedDurationSeconds?.formattedClockDuration ?? "-")
                    metricRow("Time used", summary.timeUsedSeconds?.formattedClockDuration ?? "-")
                    metricRow("Moves attempted", "\(summary.completedMoves)")
                    metricRow("Correct moves", "\(summary.correctMoves)")
                    metricRow("Incorrect moves", "\(summary.incorrectMoves)")
                    metricRow("Accuracy", summary.accuracy.formatted(.percent.precision(.fractionLength(0))))
                }
            }

            if let historySaveError {
                Section("History") {
                    Text("This result could not be saved: \(historySaveError)")
                        .foregroundStyle(PremiumDesign.Accent.danger.color)
                }
            }

            Section("Weak areas") {
                if summary.mistakesByTag.isEmpty {
                    Text("No missed move categories. Nice work.")
                        .foregroundStyle(PremiumDesign.secondaryText)
                } else {
                    ForEach(summary.mistakesByTag, id: \.0) { tag, count in
                        metricRow(tag.displayName, "\(count)")
                    }
                }
            }

            Section {
                Button(summary.mode.isTimed ? "Restart timed game" : "Train this game again", action: restart)
                    .tint(PremiumDesign.Accent.practice.color)
                    .accessibilityIdentifier("results.restartButton")

                if summary.mode.isTimed {
                    Button("Choose another game") {
                        if let startNewGame {
                            startNewGame()
                        } else {
                            dismiss()
                        }
                    }
                    .accessibilityIdentifier("results.newGameButton")
                }
            }
        }
        .listStyle(.insetGrouped)
        .premiumScreenBackground()
        .navigationTitle("Results")
    }

    private func metricRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(PremiumDesign.primaryText)
            Spacer()
            Text(value)
                .foregroundStyle(PremiumDesign.secondaryText)
        }
    }
}

extension TimeInterval {
    var formattedMoveTime: String {
        String(format: "%.1fs", self)
    }
}

extension Int {
    var formattedClockDuration: String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
