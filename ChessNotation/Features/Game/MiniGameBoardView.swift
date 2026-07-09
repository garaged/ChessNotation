import SwiftUI

struct ThemedMiniGameBoard<Content: View>: View {
    @Environment(AppSettings.self) private var appSettings

    let orientation: BoardOrientationPolicy
    let content: (ChessSquare, CGFloat, ChessVisualPalette) -> Content

    init(
        orientation: BoardOrientationPolicy,
        @ViewBuilder content: @escaping (ChessSquare, CGFloat, ChessVisualPalette) -> Content
    ) {
        self.orientation = orientation
        self.content = content
    }

    private var palette: ChessVisualPalette {
        appSettings.visualTheme.palette
    }

    var body: some View {
        GeometryReader { proxy in
            let boardSize = min(proxy.size.width, proxy.size.height)
            let squareSize = boardSize / 8

            ZStack(alignment: .topLeading) {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(squareSize), spacing: 0), count: 8), spacing: 0) {
                    ForEach(0..<64, id: \.self) { index in
                        if let square = SquareBoardMapping.square(forDisplayIndex: index, orientation: orientation) {
                            ZStack {
                                Rectangle()
                                    .fill(palette.squareStyle(isLight: isLightSquare(square)))
                                content(square, squareSize, palette)

                                if appSettings.showBoardCoordinates {
                                    MiniGameBoardCoordinateOverlay(
                                        square: square,
                                        squareSize: squareSize,
                                        palette: palette
                                    )
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                                }
                            }
                            .frame(width: squareSize, height: squareSize)
                        }
                    }
                }
                .frame(width: boardSize, height: boardSize)
            }
            .frame(width: boardSize, height: boardSize)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: palette.boardShadow, radius: 10, x: 0, y: 6)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(palette.boardBorder, lineWidth: 1.2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct MiniGameBoardCoordinateOverlay: View {
    let square: ChessSquare
    let squareSize: CGFloat
    let palette: ChessVisualPalette

    var body: some View {
        ZStack {
            if square.rank == 0 {
                Text(fileLabel)
                    .font(.system(size: max(8, squareSize * 0.18), weight: .bold, design: .serif))
                    .foregroundStyle(palette.coordinateLabelColor(isLightSquare: isLightSquare(square)))
                    .padding(3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }

            if square.file == 0 {
                Text("\(square.rank + 1)")
                    .font(.system(size: max(8, squareSize * 0.18), weight: .bold, design: .serif))
                    .foregroundStyle(palette.coordinateLabelColor(isLightSquare: isLightSquare(square)))
                    .padding(3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    private var fileLabel: String {
        guard let scalar = UnicodeScalar(Int(UnicodeScalar("a").value) + square.file) else { return "" }
        return String(Character(scalar))
    }
}

private func isLightSquare(_ square: ChessSquare) -> Bool {
    (square.file + square.rank).isMultiple(of: 2)
}

extension TrainingPiece {
    var chessPieceKind: ChessPiece.Kind {
        switch self {
        case .king: return .king
        case .queen: return .queen
        case .rook: return .rook
        case .bishop: return .bishop
        case .knight: return .knight
        case .pawn: return .pawn
        }
    }
}

extension TrainingSide {
    var chessSide: ChessSide {
        switch self {
        case .white: return .white
        case .black: return .black
        }
    }
}

extension PositionRecallPiece {
    var chessPiece: ChessPiece {
        ChessPiece(kind: piece.chessPieceKind, side: side.chessSide)
    }
}

extension PieceMovementPrompt {
    var sourceChessPiece: ChessPiece {
        ChessPiece(kind: piece.chessPieceKind, side: side.chessSide)
    }
}
