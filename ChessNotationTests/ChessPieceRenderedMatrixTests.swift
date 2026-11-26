import SwiftUI
import XCTest
@testable import ChessNotation

final class ChessPieceRenderedMatrixTests: XCTestCase {
    @MainActor
    func testRenderEveryPieceOnBothSquareColorsInEveryTheme() throws {
        for theme in ChessVisualTheme.allCases {
            let renderer = ImageRenderer(content: PieceMatrix(palette: theme.palette))
            renderer.scale = 3
            let image = try XCTUnwrap(renderer.uiImage, "Could not render piece matrix for \(theme.displayName)")
            let attachment = XCTAttachment(image: image)
            attachment.name = "piece-matrix-\(theme.displayName)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }
}

private struct PieceMatrix: View {
    let palette: ChessVisualPalette
    private let kinds: [ChessPiece.Kind] = [.king, .queen, .rook, .bishop, .knight, .pawn]
    private let sides: [ChessSide] = [.white, .black]
    private let squareSize: CGFloat = 36

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<2, id: \.self) { sideIndex in
                ForEach(0..<2, id: \.self) { squareIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<6, id: \.self) { kindIndex in
                            ZStack {
                                Rectangle().fill(palette.squareStyle(isLight: squareIndex == 0))
                                ChessPieceGraphic(
                                    piece: ChessPiece(kind: kinds[kindIndex], side: sides[sideIndex]),
                                    palette: palette,
                                    squareSize: squareSize
                                )
                                .frame(width: squareSize, height: squareSize)
                            }
                            .frame(width: squareSize, height: squareSize)
                        }
                    }
                }
            }
        }
    }
}
