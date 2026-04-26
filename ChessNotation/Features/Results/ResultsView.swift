import SwiftUI

struct ResultsView: View {
    let summary: TrainingSessionSummary
    let restart: () -> Void

    var body: some View {
        List {
            Section("Session") {
                metricRow("Game", summary.game.title)
                metricRow("Completed moves", "\(summary.completedMoves)")
                metricRow("Accuracy", summary.accuracy.formatted(.percent.precision(.fractionLength(0))))
                metricRow("Average move time", summary.averageMoveTime.formattedMoveTime)
                metricRow("First-try correct", "\(summary.firstTryCorrect)")
            }

            Section("Weak areas") {
                if summary.mistakesByTag.isEmpty {
                    Text("No missed move categories. Nice work.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(summary.mistakesByTag, id: \.0) { tag, count in
                        metricRow(tag.displayName, "\(count)")
                    }
                }
            }

            Section {
                Button("Train this game again", action: restart)
                    .accessibilityIdentifier("results.restartButton")
            }
        }
        .navigationTitle("Results")
    }

    private func metricRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

private extension TimeInterval {
    var formattedMoveTime: String {
        String(format: "%.1fs", self)
    }
}
