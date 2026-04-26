import SwiftUI

struct ChessNotationKeyboard: View {
    @ScaledMetric(relativeTo: .body) private var scaledKeyHeight = 38

    let onKey: (String) -> Void
    let onBackspace: () -> Void
    let onClear: () -> Void
    let onSubmit: () -> Void
    let enabledKeys: Set<String>?

    private let pieceRow = ["K", "Q", "R", "B", "N", "x"]
    private let fileRow = ["a", "b", "c", "d", "e", "f", "g", "h"]
    private let rankRow = ["1", "2", "3", "4", "5", "6", "7", "8"]
    private let symbolRow = ["O-O", "O-O-O", "+", "#", "="]

    private var keyHeight: CGFloat {
        min(max(scaledKeyHeight, 36), 40)
    }

    private let rowSpacing: CGFloat = 5
    private let keyboardPadding: CGFloat = 8
    private let keyHorizontalPadding: CGFloat = 6

    var body: some View {
        VStack(spacing: rowSpacing) {
            adaptiveRow(pieceRow)
            adaptiveRow(fileRow)
            rankKeysRow
            symbolKeysRow
            actionRow
        }
        .padding(keyboardPadding)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06))
        )
        .dynamicTypeSize(.medium ... .xxLarge)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ChessNotationKeyboard.Root")
    }

    private func adaptiveRow(_ values: [String]) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: rowSpacing) {
                ForEach(values, id: \.self) { value in
                    keyButton(
                        title: value,
                        accessibilityLabel: accessibilityLabel(for: value),
                        isEnabled: isEnabled(value),
                        action: { onKey(value) }
                    )
                }
            }

            LazyVGrid(columns: adaptiveColumns(minimum: 38), spacing: rowSpacing) {
                ForEach(values, id: \.self) { value in
                    keyButton(
                        title: value,
                        accessibilityLabel: accessibilityLabel(for: value),
                        isEnabled: isEnabled(value),
                        action: { onKey(value) }
                    )
                }
            }
        }
    }

    private var rankKeysRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: rowSpacing) {
                ForEach(rankRow, id: \.self) { value in
                    keyButton(
                        title: value,
                        accessibilityLabel: "Rank \(value)",
                        isEnabled: isEnabled(value),
                        action: { onKey(value) }
                    )
                }
            }

            LazyVGrid(columns: adaptiveColumns(minimum: 38), spacing: rowSpacing) {
                ForEach(rankRow, id: \.self) { value in
                    keyButton(
                        title: value,
                        accessibilityLabel: "Rank \(value)",
                        isEnabled: isEnabled(value),
                        action: { onKey(value) }
                    )
                }
            }
        }
    }

    private var symbolKeysRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: rowSpacing) {
                ForEach(symbolRow, id: \.self) { value in
                    keyButton(
                        title: value,
                        accessibilityLabel: accessibilityLabel(for: value),
                        isEnabled: isEnabled(value),
                        action: { onKey(value) }
                    )
                }

                keyButton(
                    title: "Delete",
                    systemImage: "delete.left",
                    accessibilityLabel: "Backspace",
                    isEnabled: isEnabled("Backspace"),
                    action: onBackspace
                )
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: rowSpacing)], spacing: rowSpacing) {
                ForEach(symbolRow, id: \.self) { value in
                    keyButton(
                        title: value,
                        accessibilityLabel: accessibilityLabel(for: value),
                        isEnabled: isEnabled(value),
                        action: { onKey(value) }
                    )
                }

                keyButton(
                    title: "Delete",
                    systemImage: "delete.left",
                    accessibilityLabel: "Backspace",
                    isEnabled: isEnabled("Backspace"),
                    action: onBackspace
                )
            }
        }
    }

    private var actionRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: rowSpacing) {
                clearButton
                submitButton
            }

            VStack(spacing: rowSpacing) {
                clearButton
                submitButton
            }
        }
    }

    private var clearButton: some View {
        keyButton(
            title: "Clear",
            accessibilityLabel: "Clear input",
            accessibilityIdentifier: "ChessNotationKeyboard.Clear",
            isEnabled: isEnabled("Clear"),
            role: .destructive,
            action: onClear
        )
    }

    private var submitButton: some View {
        keyButton(
            title: "Submit",
            systemImage: "return",
            accessibilityLabel: "Submit move",
            accessibilityIdentifier: "ChessNotationKeyboard.Submit",
            isEnabled: isEnabled("Submit"),
            prominence: .primary,
            action: onSubmit
        )
    }

    private func adaptiveColumns(minimum: CGFloat) -> [GridItem] {
        [GridItem(.adaptive(minimum: minimum), spacing: rowSpacing)]
    }

    private func keyButton(
        title: String,
        systemImage: String? = nil,
        accessibilityLabel: String,
        accessibilityIdentifier: String? = nil,
        isEnabled: Bool,
        role: ButtonRole? = nil,
        prominence: KeyProminence = .standard,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                        .labelStyle(.titleAndIcon)
                } else {
                    Text(title)
                }
            }
            .font(font(for: title))
            .lineLimit(1)
            .minimumScaleFactor(minimumScaleFactor(for: title))
            .frame(maxWidth: .infinity, minHeight: keyHeight)
            .padding(.horizontal, keyHorizontalPadding)
        }
        .buttonStyle(ChessNotationKeyButtonStyle(prominence: prominence))
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier ?? keyIdentifier(for: title))
    }

    private func isEnabled(_ key: String) -> Bool {
        enabledKeys?.contains(key) ?? true
    }

    private func font(for title: String) -> Font {
        switch title {
        case "O-O-O", "Submit", "Delete", "Clear":
            return .footnote.weight(.semibold)
        case "O-O":
            return .callout.weight(.semibold)
        default:
            return .callout.weight(.semibold)
        }
    }

    private func minimumScaleFactor(for title: String) -> CGFloat {
        switch title {
        case "O-O-O", "Submit", "Delete", "Clear":
            return 0.65
        default:
            return 0.8
        }
    }

    private func accessibilityLabel(for value: String) -> String {
        switch value {
        case "K":
            return "King"
        case "Q":
            return "Queen"
        case "R":
            return "Rook"
        case "B":
            return "Bishop"
        case "N":
            return "Knight"
        case "x":
            return "Capture"
        case "+":
            return "Check"
        case "#":
            return "Checkmate"
        case "=":
            return "Promotion"
        case "O-O":
            return "Kingside castle"
        case "O-O-O":
            return "Queenside castle"
        case "a", "b", "c", "d", "e", "f", "g", "h":
            return "File \(value)"
        case "1", "2", "3", "4", "5", "6", "7", "8":
            return "Rank \(value)"
        default:
            return value
        }
    }

    private func keyIdentifier(for value: String) -> String {
        switch value {
        case "+":
            return "ChessNotationKeyboard.Key.+"
        case "#":
            return "ChessNotationKeyboard.Key.#"
        case "=":
            return "ChessNotationKeyboard.Key.="
        case "x":
            return "ChessNotationKeyboard.Key.x"
        case "Delete":
            return "ChessNotationKeyboard.Backspace"
        default:
            return "ChessNotationKeyboard.Key.\(value)"
        }
    }
}

private enum KeyProminence {
    case standard
    case primary
}

private struct ChessNotationKeyButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let prominence: KeyProminence

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(background(configuration: configuration))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
    }

    private var foregroundColor: Color {
        switch prominence {
        case .standard:
            return .primary
        case .primary:
            return .white
        }
    }

    private func background(configuration: Configuration) -> some ShapeStyle {
        switch prominence {
        case .standard:
            return AnyShapeStyle(
                Color(.tertiarySystemBackground)
                    .opacity(configuration.isPressed && isEnabled ? 0.8 : 1)
            )
        case .primary:
            return AnyShapeStyle(
                Color.accentColor
                    .opacity(configuration.isPressed && isEnabled ? 0.8 : 1)
            )
        }
    }
}

#Preview("Empty Input") {
    ChessNotationKeyboard(
        onKey: { _ in },
        onBackspace: {},
        onClear: {},
        onSubmit: {},
        enabledKeys: nil
    )
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Promotion e8=") {
    ChessNotationKeyboard(
        onKey: { _ in },
        onBackspace: {},
        onClear: {},
        onSubmit: {},
        enabledKeys: ChessNotationKeyAvailability.availableKeys(for: "e8=")
    )
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Checkmate Qxf7#") {
    ChessNotationKeyboard(
        onKey: { _ in },
        onBackspace: {},
        onClear: {},
        onSubmit: {},
        enabledKeys: ChessNotationKeyAvailability.availableKeys(for: "Qxf7#")
    )
    .padding()
    .background(Color(.systemBackground))
}
