import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    settingsSection("Evaluation") {
                        ForEach(Difficulty.allCases) { difficulty in
                            Toggle(isOn: binding(for: difficulty)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(difficulty.rawValue.capitalized)
                                        .font(.headline)
                                    Text(evaluationDescription(for: difficulty))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .tint(.accentColor)
                        }
                    }

                    settingsSection("Board Style") {
                        VStack(spacing: 16) {
                            ForEach(ChessVisualTheme.allCases) { theme in
                                Button {
                                    appSettings.visualTheme = theme
                                } label: {
                                    ThemeOptionCard(
                                        theme: theme,
                                        isSelected: appSettings.visualTheme == theme
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func binding(for difficulty: Difficulty) -> Binding<Bool> {
        Binding(
            get: { appSettings.bindingValue(for: difficulty) },
            set: { appSettings.setEvaluationEnabled($0, for: difficulty) }
        )
    }

    private func evaluationDescription(for difficulty: Difficulty) -> String {
        switch difficulty {
        case .beginner:
            return "Off by default to avoid overwhelming new players."
        case .intermediate:
            return "On by default for stronger move feedback."
        case .advanced:
            return "On by default for full training context."
        }
    }
}

private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        Text(title)
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 4)
        VStack(spacing: 14) {
            content()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

private struct ThemeOptionCard: View {
    let theme: ChessVisualTheme
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(theme.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.55))
            }

            ThemePreview(theme: theme)
                .frame(height: 172)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? Color.accentColor : theme.palette.boardBorder.opacity(0.6), lineWidth: isSelected ? 2 : 1)
                }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color(.secondarySystemBackground), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.04), radius: isSelected ? 16 : 8, x: 0, y: 6)
    }
}

private struct ThemePreview: View {
    let theme: ChessVisualTheme

    private let pieces: [(ChessPiece.Kind, ChessSide, Int, Int)] = [
        (.rook, .black, 0, 0),
        (.knight, .black, 1, 0),
        (.bishop, .black, 2, 0),
        (.queen, .black, 3, 0),
        (.king, .black, 4, 0),
        (.bishop, .black, 5, 0),
        (.knight, .black, 6, 0),
        (.rook, .black, 7, 0),
        (.pawn, .black, 1, 1),
        (.pawn, .black, 4, 1),
        (.pawn, .white, 3, 6),
        (.pawn, .white, 6, 6),
        (.rook, .white, 0, 7),
        (.knight, .white, 1, 7),
        (.bishop, .white, 2, 7),
        (.queen, .white, 3, 7),
        (.king, .white, 4, 7),
        (.bishop, .white, 5, 7),
        (.knight, .white, 6, 7),
        (.rook, .white, 7, 7)
    ]

    var body: some View {
        GeometryReader { proxy in
            let boardSize = min(proxy.size.width * 0.94, proxy.size.height * 1.24)
            let squareSize = boardSize / 8

            ZStack {
                LinearGradient(
                    colors: [
                        theme.palette.lightSquareTop.opacity(0.5),
                        theme.palette.darkSquareBottom.opacity(0.24)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(theme.palette.boardBorder.opacity(0.3), lineWidth: 1)
                }
                .overlay {
                    ThemePreviewTexture(theme: theme)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .opacity(0.4)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(theme.palette.lightSquareTop)
                            .frame(width: 8, height: 8)
                        Text(themeLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1.1)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.18))
                            .blur(radius: 18)

                        ZStack {
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(squareSize), spacing: 0), count: 8), spacing: 0) {
                                ForEach(0..<64, id: \.self) { index in
                                    let file = index % 8
                                    let rank = index / 8
                                    Rectangle()
                                        .fill(theme.palette.squareStyle(isLight: (file + rank).isMultiple(of: 2)))
                                        .overlay {
                                            if let piece = pieces.first(where: { $0.2 == file && $0.3 == rank }) {
                                                ChessPieceGraphic(
                                                    kind: piece.0,
                                                    palette: theme.palette.piecePalette(for: piece.1)
                                                )
                                                .frame(
                                                    width: squareSize * previewScale(for: piece.0),
                                                    height: squareSize * previewScale(for: piece.0)
                                                )
                                            }
                                        }
                                }
                            }
                            .frame(width: boardSize, height: boardSize)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: theme.palette.boardShadow.opacity(0.7), radius: 14, x: 0, y: 8)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(theme.palette.boardBorder.opacity(0.7), lineWidth: 1.2)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 126)
                }
                .padding(14)
            }
        }
    }

    private var themeLabel: String {
        switch theme {
        case .current: return "Tournament"
        case .marble: return "Marble Finish"
        case .wood: return "Walnut Grain"
        case .metal: return "Forged Metal"
        }
    }

    private func previewScale(for kind: ChessPiece.Kind) -> CGFloat {
        switch kind {
        case .king: return 0.82
        case .queen: return 0.8
        case .rook: return 0.77
        case .bishop: return 0.77
        case .knight: return 0.75
        case .pawn: return 0.6
        }
    }
}

private struct ThemePreviewTexture: View {
    let theme: ChessVisualTheme

    var body: some View {
        switch theme {
        case .current:
            currentTexture
        case .marble:
            marbleTexture
        case .wood:
            woodTexture
        case .metal:
            metalTexture
        }
    }

    private var currentTexture: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.18),
                .clear,
                Color.white.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var marbleTexture: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<7, id: \.self) { index in
                    Path { path in
                        let y = proxy.size.height * (0.08 + Double(index) * 0.13)
                        path.move(to: CGPoint(x: -20, y: y))
                        path.addCurve(
                            to: CGPoint(x: proxy.size.width + 20, y: y + CGFloat(index.isMultiple(of: 2) ? 14 : -10)),
                            control1: CGPoint(x: proxy.size.width * 0.28, y: y + CGFloat(index.isMultiple(of: 2) ? -18 : 16)),
                            control2: CGPoint(x: proxy.size.width * 0.68, y: y + CGFloat(index.isMultiple(of: 2) ? 18 : -14))
                        )
                    }
                    .stroke(Color.white.opacity(index.isMultiple(of: 2) ? 0.18 : 0.1), lineWidth: index.isMultiple(of: 2) ? 1.6 : 1)
                }
            }
        }
    }

    private var woodTexture: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<11, id: \.self) { index in
                    Path { path in
                        let y = proxy.size.height * (0.05 + Double(index) * 0.09)
                        path.move(to: CGPoint(x: -12, y: y))
                        path.addCurve(
                            to: CGPoint(x: proxy.size.width + 12, y: y + CGFloat(index.isMultiple(of: 2) ? 6 : -5)),
                            control1: CGPoint(x: proxy.size.width * 0.22, y: y + CGFloat(index.isMultiple(of: 2) ? -4 : 6)),
                            control2: CGPoint(x: proxy.size.width * 0.74, y: y + CGFloat(index.isMultiple(of: 2) ? 7 : -5))
                        )
                    }
                    .stroke(Color(red: 0.34, green: 0.20, blue: 0.08).opacity(index.isMultiple(of: 2) ? 0.18 : 0.1), lineWidth: index.isMultiple(of: 2) ? 1.4 : 0.9)
                }
            }
        }
    }

    private var metalTexture: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<18, id: \.self) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 2) ? Color.white.opacity(0.07) : Color.black.opacity(0.05))
                        .frame(height: 2)
                        .offset(y: -proxy.size.height * 0.35 + CGFloat(index) * (proxy.size.height / 18))
                }

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.22),
                        .clear,
                        Color.white.opacity(0.12),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}
