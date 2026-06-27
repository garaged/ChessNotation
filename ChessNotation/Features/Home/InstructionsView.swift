import SwiftUI

struct InstructionsView: View {
    var body: some View {
        List {
            Section("Choose A Mode") {
                instructionRow(
                    title: "Quick Practice",
                    description: "Starts an untimed notation session from the games currently shown in the library."
                )
                instructionRow(
                    title: "Timed Notation",
                    description: "Uses the same game library, then asks for a 1, 3, or 5 minute limit before play begins."
                )
                instructionRow(
                    title: "Square Recognition",
                    description: "Shows a coordinate such as `e4`; tap that square before the clock runs out."
                )
            }

            Section("Notation Training") {
                instructionRow(
                    title: "Read the board",
                    description: "The highlighted arrow shows the move to name from the current position."
                )
                NavigationLink {
                    SANInstructionsView()
                } label: {
                    linkedInstructionRow(
                        title: "Type SAN",
                        description: "Enter moves like `Nf3`, `exd5`, `O-O`, or `Qh7#` as they would appear in a score sheet.",
                        callout: "Open detailed SAN guide"
                    )
                }
                instructionRow(
                    title: "Use your attempts",
                    description: "Each move gives three tries. Missed attempts show hints without revealing the exact answer until attempts are exhausted."
                )
                instructionRow(
                    title: "Reveal",
                    description: "Shows the current answer, records the move as missed, and advances the session."
                )
            }

            Section("Timed Play") {
                instructionRow(
                    title: "Countdown",
                    description: "Timed notation shows the remaining time above the board and finishes immediately when the timer reaches zero."
                )
                instructionRow(
                    title: "Completion",
                    description: "If the final move is solved, skipped, or exhausted before timeout, the result is marked completed."
                )
                instructionRow(
                    title: "Restart",
                    description: "Restarting a timed result keeps the same game and selected time limit."
                )
            }

            Section("Square Recognition") {
                instructionRow(
                    title: "Orientation",
                    description: "The board is shown from White's perspective. The White side label marks the bottom edge."
                )
                instructionRow(
                    title: "Bonus variant",
                    description: "Correct taps add 0.5 seconds after answer time is deducted. Wrong taps only deduct elapsed time."
                )
                instructionRow(
                    title: "Strict variant",
                    description: "Correct and wrong taps both deduct elapsed time, with no bonus seconds."
                )
                instructionRow(
                    title: "History",
                    description: "Finished square-recognition runs are saved locally with score, accuracy, average latency, time limit, and variant."
                )
            }

            Section("Board And Settings") {
                instructionRow(
                    title: "Coordinates",
                    description: "Settings can show classic file and rank labels inside the board without changing square size."
                )
                instructionRow(
                    title: "Evaluation",
                    description: "The engine evaluation bar can be enabled or disabled per difficulty level."
                )
                instructionRow(
                    title: "Board style",
                    description: "Choose the visual theme that makes pieces and coordinates easiest to read."
                )
            }

            Section("Tips") {
                instructionRow(
                    title: "Filter first",
                    description: "Difficulty, opening, and search filters affect both library selection and random starts."
                )
                instructionRow(
                    title: "Think in move features",
                    description: "Look first for captures, checks, castling, promotions, and which piece is moving."
                )
                instructionRow(
                    title: "Train coordinates separately",
                    description: "Use square recognition when notation mistakes come from finding board coordinates slowly."
                )
            }
        }
        .navigationTitle("Instructions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func instructionRow(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func linkedInstructionRow(title: String, description: String, callout: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(callout)
                .font(.caption)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
    }
}

private struct SANInstructionsView: View {
    var body: some View {
        List {
            Section("Core Pattern") {
                sanExample(
                    notation: "Nf3",
                    meaning: "Knight moves to f3. Pieces use capital letters: K, Q, R, B, N."
                )
                sanExample(
                    notation: "e4",
                    meaning: "Pawn moves to e4. Pawn moves omit the piece letter."
                )
                sanExample(
                    notation: "Rae1",
                    meaning: "When two identical pieces can move to the same square, SAN adds file or rank disambiguation."
                )
            }

            Section("Captures And Checks") {
                sanExample(
                    notation: "Bxe6",
                    meaning: "The bishop captures on e6. Captures use `x`."
                )
                sanExample(
                    notation: "Qh7+",
                    meaning: "The queen moves to h7 and gives check. Check uses `+`."
                )
                sanExample(
                    notation: "Qh7#",
                    meaning: "Checkmate uses `#`."
                )
            }

            Section("Special Moves") {
                sanExample(
                    notation: "O-O",
                    meaning: "Kingside castling. The app also accepts zeroes and normalizes them."
                )
                sanExample(
                    notation: "O-O-O",
                    meaning: "Queenside castling."
                )
                sanExample(
                    notation: "exd8=Q",
                    meaning: "Pawn from the e-file captures on d8 and promotes to a queen."
                )
            }

            Section("Practical Tips") {
                instructionRow(
                    title: "Read the destination last",
                    description: "First identify the moving piece and whether the move is a capture, check, castle, or promotion."
                )
                instructionRow(
                    title: "Watch pawn captures",
                    description: "Pawn captures include the file of origin, like `exd5` or `gxh8=Q`."
                )
                instructionRow(
                    title: "Whitespace is ignored",
                    description: "Leading and trailing spaces do not matter, but the notation itself still needs to match the move."
                )
            }
        }
        .navigationTitle("SAN Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sanExample(notation: String, meaning: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(notation)
                .font(.headline.monospaced())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(meaning)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func instructionRow(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
