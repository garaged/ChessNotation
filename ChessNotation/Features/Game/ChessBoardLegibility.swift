import Foundation
import SwiftUI

struct ChessBoardColor: Equatable, Sendable {
    let red: Double
    let green: Double
    let blue: Double

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    var relativeLuminance: Double {
        0.2126 * linearized(red) + 0.7152 * linearized(green) + 0.0722 * linearized(blue)
    }

    func contrastRatio(with other: ChessBoardColor) -> Double {
        let lighter = max(relativeLuminance, other.relativeLuminance)
        let darker = min(relativeLuminance, other.relativeLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private func linearized(_ component: Double) -> Double {
        component <= 0.04045
            ? component / 12.92
            : pow((component + 0.055) / 1.055, 2.4)
    }
}

struct ChessBoardLegibilityContract: Equatable, Sendable {
    let lightSquareTop: ChessBoardColor
    let lightSquareBottom: ChessBoardColor
    let darkSquareTop: ChessBoardColor
    let darkSquareBottom: ChessBoardColor
    let whitePiece: ChessBoardColor
    let whiteContour: ChessBoardColor
    let blackPiece: ChessBoardColor
    let blackContour: ChessBoardColor

    var squareColors: [ChessBoardColor] {
        [lightSquareTop, lightSquareBottom, darkSquareTop, darkSquareBottom]
    }

    var squareContrastRatio: Double {
        squareColors.map { lightSquareTop.contrastRatio(with: $0) }
            .filter { $0 > 1 }
            .min() ?? 1
    }

    func visiblePieceContrast(side: ChessSide, against square: ChessBoardColor) -> Double {
        let pieceColors = side == .white
            ? [whitePiece, whiteContour]
            : [blackPiece, blackContour]

        return pieceColors
            .map { $0.contrastRatio(with: square) }
            .max() ?? 1
    }

    func meetsMinimumContrast() -> Bool {
        let required: Double = 3

        guard lightSquareTop.contrastRatio(with: darkSquareTop) >= required,
              lightSquareTop.contrastRatio(with: darkSquareBottom) >= required,
              lightSquareBottom.contrastRatio(with: darkSquareTop) >= required,
              lightSquareBottom.contrastRatio(with: darkSquareBottom) >= required else {
            return false
        }

        return ChessSide.allCases.allSatisfy { side in
            squareColors.allSatisfy { visiblePieceContrast(side: side, against: $0) >= required }
        }
    }
}

enum ChessPiecePresentationMetrics {
    static func imageScale(for kind: ChessPiece.Kind) -> CGFloat {
        1
    }

    static func contourRadius(for squareSize: CGFloat) -> CGFloat {
        min(max(squareSize * 0.045, 1.1), 2.2)
    }

    static func shadowRadius(for squareSize: CGFloat) -> CGFloat {
        min(max(squareSize * 0.035, 0.8), 1.8)
    }
}

extension ChessVisualTheme {
    var legibilityContract: ChessBoardLegibilityContract {
        switch self {
        case .current:
            return ChessBoardLegibilityContract(
                lightSquareTop: ChessBoardColor(red: 0.90, green: 0.94, blue: 0.96),
                lightSquareBottom: ChessBoardColor(red: 0.79, green: 0.86, blue: 0.90),
                darkSquareTop: ChessBoardColor(red: 0.16, green: 0.39, blue: 0.48),
                darkSquareBottom: ChessBoardColor(red: 0.09, green: 0.28, blue: 0.36),
                whitePiece: ChessBoardColor(red: 0.99, green: 0.98, blue: 0.94),
                whiteContour: ChessBoardColor(red: 0.05, green: 0.12, blue: 0.17),
                blackPiece: ChessBoardColor(red: 0.04, green: 0.07, blue: 0.10),
                blackContour: ChessBoardColor(red: 0.86, green: 0.94, blue: 0.97)
            )
        case .marble:
            return ChessBoardLegibilityContract(
                lightSquareTop: ChessBoardColor(red: 0.94, green: 0.95, blue: 0.97),
                lightSquareBottom: ChessBoardColor(red: 0.79, green: 0.83, blue: 0.88),
                darkSquareTop: ChessBoardColor(red: 0.24, green: 0.30, blue: 0.39),
                darkSquareBottom: ChessBoardColor(red: 0.14, green: 0.19, blue: 0.27),
                whitePiece: ChessBoardColor(red: 0.99, green: 0.99, blue: 0.99),
                whiteContour: ChessBoardColor(red: 0.05, green: 0.09, blue: 0.14),
                blackPiece: ChessBoardColor(red: 0.04, green: 0.06, blue: 0.10),
                blackContour: ChessBoardColor(red: 0.89, green: 0.93, blue: 0.97)
            )
        case .wood:
            return ChessBoardLegibilityContract(
                lightSquareTop: ChessBoardColor(red: 0.91, green: 0.75, blue: 0.53),
                lightSquareBottom: ChessBoardColor(red: 0.78, green: 0.60, blue: 0.39),
                darkSquareTop: ChessBoardColor(red: 0.31, green: 0.18, blue: 0.09),
                darkSquareBottom: ChessBoardColor(red: 0.19, green: 0.10, blue: 0.05),
                whitePiece: ChessBoardColor(red: 0.99, green: 0.95, blue: 0.86),
                whiteContour: ChessBoardColor(red: 0.10, green: 0.05, blue: 0.02),
                blackPiece: ChessBoardColor(red: 0.05, green: 0.04, blue: 0.03),
                blackContour: ChessBoardColor(red: 0.97, green: 0.86, blue: 0.68)
            )
        case .metal:
            return ChessBoardLegibilityContract(
                lightSquareTop: ChessBoardColor(red: 0.82, green: 0.86, blue: 0.91),
                lightSquareBottom: ChessBoardColor(red: 0.66, green: 0.72, blue: 0.80),
                darkSquareTop: ChessBoardColor(red: 0.20, green: 0.27, blue: 0.36),
                darkSquareBottom: ChessBoardColor(red: 0.10, green: 0.15, blue: 0.22),
                whitePiece: ChessBoardColor(red: 0.96, green: 0.98, blue: 0.99),
                whiteContour: ChessBoardColor(red: 0.04, green: 0.08, blue: 0.13),
                blackPiece: ChessBoardColor(red: 0.03, green: 0.05, blue: 0.08),
                blackContour: ChessBoardColor(red: 0.84, green: 0.91, blue: 0.96)
            )
        }
    }
}
