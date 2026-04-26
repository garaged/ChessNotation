import SwiftUI

struct InstructionsView: View {
    var body: some View {
        List {
            Section("How It Works") {
                instructionRow(
                    title: "Read the board",
                    description: "Each position highlights the move you need to name using standard algebraic notation."
                )
                NavigationLink {
                    SANInstructionsView()
                } label: {
                    linkedInstructionRow(
                        title: "Type SAN",
                        description: "Enter moves like `Nf3`, `exd5`, `O-O`, or `Qh7#` exactly as they would appear in a score sheet.",
                        callout: "Open detailed SAN guide"
                    )
                }
                instructionRow(
                    title: "Use your attempts",
                    description: "You get three tries per move. Hints become more specific, but they do not reveal the answer."
                )
            }

            Section("Controls") {
                instructionRow(
                    title: "Submit",
                    description: "Checks your notation and advances when correct."
                )
                instructionRow(
                    title: "Reveal",
                    description: "Shows the answer for the current move and marks it as missed."
                )
                instructionRow(
                    title: "Evaluation",
                    description: "If enabled for the selected level, the side bar shows the current engine evaluation."
                )
            }

            Section("Tips") {
                instructionRow(
                    title: "Beginner focus",
                    description: "Start with beginner games and disable evaluation if you want to train pure notation recognition."
                )
                instructionRow(
                    title: "Think in move features",
                    description: "Look first for captures, checks, castling, promotions, and which piece is moving."
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
                    meaning: "Kingside castling."
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
                    title: "Use zeros never",
                    description: "Castling is written with capital letter O: `O-O`, not zeroes."
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
                .clipShape(RoundedRectangle(cornerRadius: 10))

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
