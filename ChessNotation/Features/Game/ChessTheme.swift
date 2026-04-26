import SwiftUI

struct ChessVisualPalette {
    let lightSquareTop: Color
    let lightSquareBottom: Color
    let darkSquareTop: Color
    let darkSquareBottom: Color
    let boardBorder: Color
    let boardShadow: Color
    let whitePieceTop: Color
    let whitePieceBottom: Color
    let whitePieceHighlight: Color
    let whiteStroke: Color
    let whiteShadow: Color
    let blackPieceTop: Color
    let blackPieceBottom: Color
    let blackPieceHighlight: Color
    let blackStroke: Color
    let blackShadow: Color
    let arrowColor: Color

    func squareStyle(isLight: Bool) -> AnyShapeStyle {
        let gradient = LinearGradient(
            colors: isLight ? [lightSquareTop, lightSquareBottom] : [darkSquareTop, darkSquareBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        return AnyShapeStyle(gradient)
    }

    func piecePalette(for side: ChessSide) -> ChessPiecePalette {
        switch side {
        case .white:
            return ChessPiecePalette(
                fill: AnyShapeStyle(
                    LinearGradient(
                        colors: [whitePieceTop, whitePieceBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                ),
                highlight: whitePieceHighlight,
                stroke: whiteStroke,
                shadow: whiteShadow
            )
        case .black:
            return ChessPiecePalette(
                fill: AnyShapeStyle(
                    LinearGradient(
                        colors: [blackPieceTop, blackPieceBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                ),
                highlight: blackPieceHighlight,
                stroke: blackStroke,
                shadow: blackShadow
            )
        }
    }
}

struct ChessPiecePalette {
    let fill: AnyShapeStyle
    let highlight: Color
    let stroke: Color
    let shadow: Color
}

extension ChessVisualTheme {
    var palette: ChessVisualPalette {
        switch self {
        case .current:
            return ChessVisualPalette(
                lightSquareTop: Color(red: 0.93, green: 0.94, blue: 0.95),
                lightSquareBottom: Color(red: 0.84, green: 0.85, blue: 0.88),
                darkSquareTop: Color(red: 0.50, green: 0.84, blue: 0.60),
                darkSquareBottom: Color(red: 0.39, green: 0.76, blue: 0.51),
                boardBorder: Color.black.opacity(0.12),
                boardShadow: Color.black.opacity(0.18),
                whitePieceTop: Color(red: 0.99, green: 0.98, blue: 0.95),
                whitePieceBottom: Color(red: 0.87, green: 0.85, blue: 0.78),
                whitePieceHighlight: Color.white.opacity(0.6),
                whiteStroke: Color.black.opacity(0.25),
                whiteShadow: Color.black.opacity(0.18),
                blackPieceTop: Color(red: 0.28, green: 0.30, blue: 0.34),
                blackPieceBottom: Color(red: 0.10, green: 0.11, blue: 0.14),
                blackPieceHighlight: Color.white.opacity(0.08),
                blackStroke: Color.white.opacity(0.06),
                blackShadow: Color.black.opacity(0.22),
                arrowColor: Color(red: 0.97, green: 0.22, blue: 0.24)
            )
        case .marble:
            return ChessVisualPalette(
                lightSquareTop: Color(red: 0.97, green: 0.97, blue: 0.98),
                lightSquareBottom: Color(red: 0.86, green: 0.88, blue: 0.91),
                darkSquareTop: Color(red: 0.56, green: 0.60, blue: 0.67),
                darkSquareBottom: Color(red: 0.39, green: 0.43, blue: 0.50),
                boardBorder: Color.black.opacity(0.16),
                boardShadow: Color.black.opacity(0.2),
                whitePieceTop: Color(red: 0.99, green: 0.99, blue: 0.99),
                whitePieceBottom: Color(red: 0.83, green: 0.84, blue: 0.86),
                whitePieceHighlight: Color.white.opacity(0.72),
                whiteStroke: Color(red: 0.43, green: 0.46, blue: 0.50).opacity(0.32),
                whiteShadow: Color.black.opacity(0.16),
                blackPieceTop: Color(red: 0.42, green: 0.45, blue: 0.51),
                blackPieceBottom: Color(red: 0.18, green: 0.20, blue: 0.24),
                blackPieceHighlight: Color.white.opacity(0.12),
                blackStroke: Color.white.opacity(0.05),
                blackShadow: Color.black.opacity(0.24),
                arrowColor: Color(red: 0.78, green: 0.14, blue: 0.18)
            )
        case .wood:
            return ChessVisualPalette(
                lightSquareTop: Color(red: 0.88, green: 0.73, blue: 0.52),
                lightSquareBottom: Color(red: 0.78, green: 0.60, blue: 0.40),
                darkSquareTop: Color(red: 0.55, green: 0.34, blue: 0.18),
                darkSquareBottom: Color(red: 0.43, green: 0.24, blue: 0.11),
                boardBorder: Color(red: 0.24, green: 0.14, blue: 0.08).opacity(0.42),
                boardShadow: Color.black.opacity(0.24),
                whitePieceTop: Color(red: 0.98, green: 0.92, blue: 0.78),
                whitePieceBottom: Color(red: 0.82, green: 0.67, blue: 0.46),
                whitePieceHighlight: Color.white.opacity(0.46),
                whiteStroke: Color(red: 0.32, green: 0.18, blue: 0.08).opacity(0.26),
                whiteShadow: Color.black.opacity(0.17),
                blackPieceTop: Color(red: 0.45, green: 0.28, blue: 0.14),
                blackPieceBottom: Color(red: 0.21, green: 0.11, blue: 0.05),
                blackPieceHighlight: Color(red: 0.82, green: 0.66, blue: 0.44).opacity(0.14),
                blackStroke: Color.white.opacity(0.04),
                blackShadow: Color.black.opacity(0.25),
                arrowColor: Color(red: 0.89, green: 0.22, blue: 0.12)
            )
        case .metal:
            return ChessVisualPalette(
                lightSquareTop: Color(red: 0.76, green: 0.80, blue: 0.86),
                lightSquareBottom: Color(red: 0.61, green: 0.66, blue: 0.73),
                darkSquareTop: Color(red: 0.32, green: 0.38, blue: 0.46),
                darkSquareBottom: Color(red: 0.19, green: 0.23, blue: 0.29),
                boardBorder: Color.white.opacity(0.08),
                boardShadow: Color.black.opacity(0.26),
                whitePieceTop: Color(red: 0.95, green: 0.97, blue: 0.99),
                whitePieceBottom: Color(red: 0.66, green: 0.72, blue: 0.80),
                whitePieceHighlight: Color.white.opacity(0.74),
                whiteStroke: Color.black.opacity(0.28),
                whiteShadow: Color.black.opacity(0.18),
                blackPieceTop: Color(red: 0.40, green: 0.44, blue: 0.50),
                blackPieceBottom: Color(red: 0.10, green: 0.12, blue: 0.16),
                blackPieceHighlight: Color.white.opacity(0.12),
                blackStroke: Color.white.opacity(0.05),
                blackShadow: Color.black.opacity(0.28),
                arrowColor: Color(red: 0.98, green: 0.34, blue: 0.18)
            )
        }
    }
}
