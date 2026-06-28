import SwiftUI

struct ChessBoardView: View {
    @Environment(AppSettings.self) private var appSettings
    let fen: String
    let highlightedMove: NotationMove?
    let evaluation: EngineEvaluation?
    let showsCoordinates: Bool

    private var squares: [BoardSquare] {
        FENParser.squares(from: fen)
    }

    private var palette: ChessVisualPalette {
        appSettings.visualTheme.palette
    }

    var body: some View {
        GeometryReader { proxy in
            let evaluationBarWidth: CGFloat = evaluation == nil ? 0 : 34
            let barSpacing: CGFloat = evaluation == nil ? 0 : 8
            let availableBoardWidth = max(proxy.size.width - evaluationBarWidth - barSpacing, 0)
            let boardSize = min(availableBoardWidth, proxy.size.height)
            let squareSize = boardSize / 8

            HStack(spacing: barSpacing) {
                if let evaluation {
                    EvaluationBarView(
                        evaluation: evaluation,
                        palette: palette
                    )
                    .frame(width: evaluationBarWidth, height: boardSize)
                }

                ZStack(alignment: .topLeading) {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(squareSize), spacing: 0), count: 8), spacing: 0) {
                        ForEach(squares) { square in
                            ZStack {
                                Rectangle()
                                    .fill(palette.squareStyle(isLight: square.isLight))
                                if let piece = square.piece {
                                    PieceView(piece: piece, squareSize: squareSize, palette: palette)
                                }
                            }
                            .frame(width: squareSize, height: squareSize)
                        }
                    }

                    if let highlightedMove,
                       let fromPoint = point(for: highlightedMove.from, squareSize: squareSize),
                       let toPoint = point(for: highlightedMove.to, squareSize: squareSize) {
                        MoveArrow(from: fromPoint, to: toPoint)
                            .stroke(palette.arrowColor, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                            .shadow(radius: 2)
                    }

                    if showsCoordinates {
                        BoardCoordinatesOverlay(squareSize: squareSize, palette: palette)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
                .frame(width: boardSize, height: boardSize)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: palette.boardShadow, radius: 10, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(palette.boardBorder, lineWidth: 1.2)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func point(for coordinate: String, squareSize: CGFloat) -> CGPoint? {
        guard coordinate.count == 2,
              let fileChar = coordinate.first,
              let rankChar = coordinate.last,
              let fileScalar = fileChar.unicodeScalars.first,
              let rank = Int(String(rankChar)) else { return nil }

        let file = Int(fileScalar.value) - 97
        let boardRank = 8 - rank

        guard (0...7).contains(file), (0...7).contains(boardRank) else { return nil }

        return CGPoint(
            x: CGFloat(file) * squareSize + squareSize / 2,
            y: CGFloat(boardRank) * squareSize + squareSize / 2
        )
    }
}

private struct BoardCoordinatesOverlay: View {
    let squareSize: CGFloat
    let palette: ChessVisualPalette

    private let files = ["a", "b", "c", "d", "e", "f", "g", "h"]

    var body: some View {
        let boardSize = squareSize * 8
        let inset = max(squareSize * 0.16, 7)

        ZStack(alignment: .topLeading) {
            ForEach(0..<8, id: \.self) { file in
                coordinateLabel(files[file], isLightSquare: isLightSquare(file: file, rank: 0))
                    .position(
                        x: CGFloat(file + 1) * squareSize - inset,
                        y: boardSize - inset
                    )
            }

            ForEach(0..<8, id: \.self) { rankIndex in
                let rank = 7 - rankIndex
                coordinateLabel("\(rank + 1)", isLightSquare: isLightSquare(file: 0, rank: rank))
                    .position(
                        x: inset,
                        y: CGFloat(rankIndex) * squareSize + inset
                    )
            }
        }
        .frame(width: boardSize, height: boardSize)
    }

    private func coordinateLabel(_ text: String, isLightSquare: Bool) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .serif))
            .foregroundStyle(palette.coordinateLabelColor(isLightSquare: isLightSquare))
            .shadow(color: Color.black.opacity(isLightSquare ? 0.0 : 0.18), radius: 0.5, x: 0, y: 0.5)
            .lineLimit(1)
    }

    private func isLightSquare(file: Int, rank: Int) -> Bool {
        (file + rank).isMultiple(of: 2)
    }
}

struct EvaluationBarView: View {
    let evaluation: EngineEvaluation
    let palette: ChessVisualPalette

    var body: some View {
        GeometryReader { proxy in
            let whiteFraction = max(0.0, min(1.0, evaluation.whiteAdvantageFraction))
            let whiteHeight = proxy.size.height * whiteFraction
            let valueText = evaluation.displayText
            let textNearTop = whiteFraction >= 0.5
            let scoreLabelBottomInset: CGFloat = 34
            let labelBackground = textNearTop ? palette.whitePieceTop.opacity(0.92) : palette.blackPieceBottom.opacity(0.92)
            let labelForeground = textNearTop ? palette.blackPieceBottom : palette.whitePieceTop

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [palette.blackPieceTop, palette.blackPieceBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [palette.whitePieceTop, palette.whitePieceBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: whiteHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .animation(.easeInOut(duration: 0.35), value: whiteFraction)
            }
            .overlay(alignment: textNearTop ? .top : .bottom) {
                Text(valueText)
                    .font(.system(size: 9, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(labelForeground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 3)
                    .background(
                        Capsule(style: .continuous)
                            .fill(labelBackground)
                    )
                    .padding(.top, textNearTop ? 8 : 0)
                    .padding(.bottom, textNearTop ? 0 : scoreLabelBottomInset)
                    .animation(.easeInOut(duration: 0.35), value: textNearTop)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(palette.boardBorder, lineWidth: 1)
            }
            .overlay(alignment: .bottom) {
                engineDepthBadge(engine: evaluation.engine, depth: evaluation.depth)
                    .padding(.bottom, 8)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Position evaluation")
            .accessibilityValue(Text("\(valueText), \(evaluation.engine), depth \(evaluation.depth)"))
        }
    }

    private func engineDepthBadge(engine: String, depth: Int) -> some View {
        VStack(spacing: 1) {
            Text(engine.prefix(1).uppercased())
                .font(.system(size: 8, weight: .black, design: .rounded))
            Text("\(depth)")
                .font(.system(size: 8, weight: .black, design: .rounded).monospacedDigit())
        }
        .foregroundStyle(palette.blackPieceTop)
        .minimumScaleFactor(0.7)
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .background(Capsule(style: .continuous).fill(palette.whitePieceTop.opacity(0.95)))
    }
}

private struct PieceView: View {
    let piece: ChessPiece
    let squareSize: CGFloat
    let palette: ChessVisualPalette

    var body: some View {
        ChessPieceGraphic(piece: piece)
        .frame(width: squareSize * piece.scale, height: squareSize * piece.scale)
        .shadow(color: palette.piecePalette(for: piece.side).shadow, radius: 1.4, x: 0, y: 1)
        .padding(squareSize * 0.03)
    }
}

struct ChessPieceGraphic: View {
    let piece: ChessPiece

    var body: some View {
        Image(piece.imageName)
            .resizable()
            .scaledToFit()
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ChessPieceShape: Shape {
    let kind: ChessPiece.Kind

    func path(in rect: CGRect) -> Path {
        switch kind {
        case .pawn:
            return PawnShape().path(in: rect)
        case .rook:
            return RookShape().path(in: rect)
        case .knight:
            return KnightShape().path(in: rect)
        case .bishop:
            return BishopShape().path(in: rect)
        case .queen:
            return QueenShape().path(in: rect)
        case .king:
            return KingShape().path(in: rect)
        }
    }
}

struct PawnShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: rect.width * 0.37, y: rect.height * 0.12, width: rect.width * 0.26, height: rect.height * 0.26))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.4, y: rect.height * 0.32, width: rect.width * 0.2, height: rect.height * 0.26), cornerSize: CGSize(width: rect.width * 0.06, height: rect.width * 0.06))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.27, y: rect.height * 0.54, width: rect.width * 0.46, height: rect.height * 0.12), cornerSize: CGSize(width: rect.width * 0.06, height: rect.width * 0.06))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.2, y: rect.height * 0.68, width: rect.width * 0.6, height: rect.height * 0.1), cornerSize: CGSize(width: rect.width * 0.04, height: rect.width * 0.04))
        return path
    }
}

struct RookShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(x: rect.width * 0.26, y: rect.height * 0.24, width: rect.width * 0.48, height: rect.height * 0.38), cornerSize: CGSize(width: rect.width * 0.05, height: rect.width * 0.05))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.2, y: rect.height * 0.63, width: rect.width * 0.6, height: rect.height * 0.1), cornerSize: CGSize(width: rect.width * 0.04, height: rect.width * 0.04))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.16, y: rect.height * 0.74, width: rect.width * 0.68, height: rect.height * 0.09), cornerSize: CGSize(width: rect.width * 0.04, height: rect.width * 0.04))
        path.addRect(CGRect(x: rect.width * 0.22, y: rect.height * 0.13, width: rect.width * 0.12, height: rect.height * 0.12))
        path.addRect(CGRect(x: rect.width * 0.44, y: rect.height * 0.1, width: rect.width * 0.12, height: rect.height * 0.15))
        path.addRect(CGRect(x: rect.width * 0.66, y: rect.height * 0.13, width: rect.width * 0.12, height: rect.height * 0.12))
        return path
    }
}

struct BishopShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.1))
        path.addCurve(to: CGPoint(x: rect.width * 0.69, y: rect.height * 0.34), control1: CGPoint(x: rect.width * 0.66, y: rect.height * 0.16), control2: CGPoint(x: rect.width * 0.73, y: rect.height * 0.25))
        path.addCurve(to: CGPoint(x: rect.width * 0.61, y: rect.height * 0.58), control1: CGPoint(x: rect.width * 0.65, y: rect.height * 0.42), control2: CGPoint(x: rect.width * 0.66, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.68))
        path.addLine(to: CGPoint(x: rect.width * 0.3, y: rect.height * 0.68))
        path.addLine(to: CGPoint(x: rect.width * 0.39, y: rect.height * 0.58))
        path.addCurve(to: CGPoint(x: rect.width * 0.31, y: rect.height * 0.34), control1: CGPoint(x: rect.width * 0.34, y: rect.height * 0.5), control2: CGPoint(x: rect.width * 0.35, y: rect.height * 0.42))
        path.addCurve(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.1), control1: CGPoint(x: rect.width * 0.27, y: rect.height * 0.25), control2: CGPoint(x: rect.width * 0.34, y: rect.height * 0.16))
        path.closeSubpath()
        path.addRoundedRect(in: CGRect(x: rect.width * 0.21, y: rect.height * 0.74, width: rect.width * 0.58, height: rect.height * 0.08), cornerSize: CGSize(width: rect.width * 0.04, height: rect.width * 0.04))
        return path
    }
}

struct QueenShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: rect.width * 0.15, y: rect.height * 0.14, width: rect.width * 0.14, height: rect.width * 0.14))
        path.addEllipse(in: CGRect(x: rect.width * 0.43, y: rect.height * 0.08, width: rect.width * 0.14, height: rect.width * 0.14))
        path.addEllipse(in: CGRect(x: rect.width * 0.71, y: rect.height * 0.14, width: rect.width * 0.14, height: rect.width * 0.14))
        path.move(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.28))
        path.addLine(to: CGPoint(x: rect.width * 0.34, y: rect.height * 0.56))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.26))
        path.addLine(to: CGPoint(x: rect.width * 0.66, y: rect.height * 0.56))
        path.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.28))
        path.addLine(to: CGPoint(x: rect.width * 0.72, y: rect.height * 0.68))
        path.addLine(to: CGPoint(x: rect.width * 0.28, y: rect.height * 0.68))
        path.closeSubpath()
        path.addRoundedRect(in: CGRect(x: rect.width * 0.19, y: rect.height * 0.74, width: rect.width * 0.62, height: rect.height * 0.08), cornerSize: CGSize(width: rect.width * 0.04, height: rect.width * 0.04))
        return path
    }
}

struct KingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(x: rect.width * 0.41, y: rect.height * 0.08, width: rect.width * 0.18, height: rect.height * 0.08), cornerSize: CGSize(width: rect.width * 0.03, height: rect.width * 0.03))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.455, y: rect.height * 0.03, width: rect.width * 0.09, height: rect.height * 0.18), cornerSize: CGSize(width: rect.width * 0.03, height: rect.width * 0.03))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.32, y: rect.height * 0.22, width: rect.width * 0.36, height: rect.height * 0.4), cornerSize: CGSize(width: rect.width * 0.12, height: rect.width * 0.12))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.23, y: rect.height * 0.62, width: rect.width * 0.54, height: rect.height * 0.1), cornerSize: CGSize(width: rect.width * 0.04, height: rect.width * 0.04))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.18, y: rect.height * 0.74, width: rect.width * 0.64, height: rect.height * 0.08), cornerSize: CGSize(width: rect.width * 0.04, height: rect.width * 0.04))
        return path
    }
}

struct KnightShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.73, y: rect.height * 0.2))
        path.addCurve(to: CGPoint(x: rect.width * 0.56, y: rect.height * 0.16), control1: CGPoint(x: rect.width * 0.69, y: rect.height * 0.11), control2: CGPoint(x: rect.width * 0.62, y: rect.height * 0.1))
        path.addCurve(to: CGPoint(x: rect.width * 0.31, y: rect.height * 0.36), control1: CGPoint(x: rect.width * 0.45, y: rect.height * 0.18), control2: CGPoint(x: rect.width * 0.33, y: rect.height * 0.24))
        path.addCurve(to: CGPoint(x: rect.width * 0.39, y: rect.height * 0.56), control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.44), control2: CGPoint(x: rect.width * 0.33, y: rect.height * 0.51))
        path.addLine(to: CGPoint(x: rect.width * 0.28, y: rect.height * 0.66))
        path.addLine(to: CGPoint(x: rect.width * 0.72, y: rect.height * 0.66))
        path.addLine(to: CGPoint(x: rect.width * 0.66, y: rect.height * 0.34))
        path.addCurve(to: CGPoint(x: rect.width * 0.73, y: rect.height * 0.2), control1: CGPoint(x: rect.width * 0.74, y: rect.height * 0.29), control2: CGPoint(x: rect.width * 0.75, y: rect.height * 0.24))
        path.closeSubpath()
        path.addRoundedRect(in: CGRect(x: rect.width * 0.2, y: rect.height * 0.74, width: rect.width * 0.62, height: rect.height * 0.08), cornerSize: CGSize(width: rect.width * 0.04, height: rect.width * 0.04))
        return path
    }
}

struct MoveArrow: Shape {
    let from: CGPoint
    let to: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)

        let angle = atan2(to.y - from.y, to.x - from.x)
        let headLength: CGFloat = 22
        let headAngle: CGFloat = .pi / 7

        let first = CGPoint(
            x: to.x - headLength * cos(angle - headAngle),
            y: to.y - headLength * sin(angle - headAngle)
        )
        let second = CGPoint(
            x: to.x - headLength * cos(angle + headAngle),
            y: to.y - headLength * sin(angle + headAngle)
        )

        path.move(to: first)
        path.addLine(to: to)
        path.addLine(to: second)
        return path
    }
}
