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

    init(contract: ChessBoardLegibilityContract, boardBorder: Color, boardShadow: Color, arrowColor: Color) {
        lightSquareTop = contract.lightSquareTop.color
        lightSquareBottom = contract.lightSquareBottom.color
        darkSquareTop = contract.darkSquareTop.color
        darkSquareBottom = contract.darkSquareBottom.color
        self.boardBorder = boardBorder
        self.boardShadow = boardShadow
        whitePieceTop = contract.whitePiece.color
        whitePieceBottom = contract.whitePiece.color
        whitePieceHighlight = Color.white.opacity(0.42)
        whiteStroke = contract.whiteContour.color
        whiteShadow = contract.whiteContour.color.opacity(0.34)
        blackPieceTop = contract.blackPiece.color
        blackPieceBottom = contract.blackPiece.color
        blackPieceHighlight = contract.blackContour.color.opacity(0.18)
        blackStroke = contract.blackContour.color
        blackShadow = Color.black.opacity(0.36)
        self.arrowColor = arrowColor
    }

    func squareStyle(isLight: Bool) -> AnyShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                colors: isLight ? [lightSquareTop, lightSquareBottom] : [darkSquareTop, darkSquareBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    func coordinateLabelColor(isLightSquare: Bool) -> Color {
        isLightSquare ? darkSquareBottom : lightSquareTop
    }

    func piecePalette(for side: ChessSide) -> ChessPiecePalette {
        switch side {
        case .white:
            return ChessPiecePalette(
                fill: AnyShapeStyle(whitePieceTop),
                highlight: whitePieceHighlight,
                stroke: whiteStroke,
                shadow: whiteShadow
            )
        case .black:
            return ChessPiecePalette(
                fill: AnyShapeStyle(blackPieceTop),
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
                contract: legibilityContract,
                boardBorder: Color(red: 0.78, green: 0.90, blue: 0.95).opacity(0.72),
                boardShadow: Color.black.opacity(0.30),
                arrowColor: Color(red: 0.93, green: 0.22, blue: 0.25)
            )
        case .marble:
            return ChessVisualPalette(
                contract: legibilityContract,
                boardBorder: Color.white.opacity(0.45),
                boardShadow: Color.black.opacity(0.32),
                arrowColor: Color(red: 0.84, green: 0.18, blue: 0.22)
            )
        case .wood:
            return ChessVisualPalette(
                contract: legibilityContract,
                boardBorder: Color(red: 0.96, green: 0.82, blue: 0.58).opacity(0.48),
                boardShadow: Color.black.opacity(0.34),
                arrowColor: Color(red: 0.92, green: 0.26, blue: 0.12)
            )
        case .metal:
            return ChessVisualPalette(
                contract: legibilityContract,
                boardBorder: Color(red: 0.81, green: 0.90, blue: 0.97).opacity(0.48),
                boardShadow: Color.black.opacity(0.36),
                arrowColor: Color(red: 0.98, green: 0.36, blue: 0.18)
            )
        }
    }
}
