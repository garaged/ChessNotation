import SwiftUI
import XCTest
@testable import ChessNotation

final class ChessPieceRenderedMatrixTests: XCTestCase {
    @MainActor
    func testRenderEveryPieceOnBothSquareColorsInEveryTheme() throws {
        for theme in ChessVisualTheme.allCases {
            let renderer = ImageRenderer(content: PieceMatrix(palette: theme.palette, showsPieces: true))
            renderer.scale = 3
            let image = try XCTUnwrap(renderer.uiImage, "Could not render piece matrix for \(theme.displayName)")
            let attachment = XCTAttachment(image: image)
            attachment.name = "piece-matrix-\(theme.displayName)"
            attachment.lifetime = .keepAlways
            add(attachment)
            let reference = ImageRenderer(content: PieceMatrix(palette: theme.palette, showsPieces: false))
            reference.scale = 3
            let blankImage = try XCTUnwrap(reference.uiImage)
            try verifyVisibleContrast(rendered: image, background: blankImage, theme: theme.displayName)
        }
    }
    private func verifyVisibleContrast(rendered: UIImage, background: UIImage, theme: String) throws {
        let foreground = try rgbaPixels(rendered)
        let backdrop = try rgbaPixels(background)
        let cell = 108
        let width = cell * 6
        XCTAssertEqual(foreground.count, width * cell * 4 * 4)
        XCTAssertEqual(backdrop.count, foreground.count)
        guard foreground.count == width * cell * 4 * 4, backdrop.count == foreground.count else { return }

        for row in 0..<4 {
            for column in 0..<6 {
                var contrastingPixels = 0
                for y in (row * cell)..<((row + 1) * cell) {
                    for x in (column * cell)..<((column + 1) * cell) {
                        let index = (y * width + x) * 4
                        let a = luminance(foreground, at: index)
                        let b = luminance(backdrop, at: index)
                        if (max(a, b) + 0.05) / (min(a, b) + 0.05) >= 3 {
                            contrastingPixels += 1
                        }
                    }
                }
                XCTAssertGreaterThan(contrastingPixels, cell * cell / 100,
                    "\(theme): cell row \(row), column \(column) must contain at least 1% pixels with 3:1 contrast against the rendered background")
            }
        }
    }

    private func rgbaPixels(_ image: UIImage) throws -> [UInt8] {
        let source = try XCTUnwrap(image.cgImage)
        let width = source.width
        let height = source.height
        var result = [UInt8](repeating: 0, count: width * height * 4)
        try result.withUnsafeMutableBytes { bytes in
            let context = try XCTUnwrap(CGContext(
                data: bytes.baseAddress, width: width, height: height,
                bitsPerComponent: 8, bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        return result
    }

    private func luminance(_ pixels: [UInt8], at index: Int) -> Double {
        func linear(_ value: UInt8) -> Double {
            let component = Double(value) / 255
            return component <= 0.04045 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(pixels[index]) + 0.7152 * linear(pixels[index + 1]) + 0.0722 * linear(pixels[index + 2])
    }

}

private struct PieceMatrix: View {
    let palette: ChessVisualPalette
    let showsPieces: Bool
    private let kinds: [ChessPiece.Kind] = [.king, .queen, .rook, .bishop, .knight, .pawn]
    private let sides: [ChessSide] = [.white, .black]
    private let squareSize: CGFloat = 36

    init(palette: ChessVisualPalette, showsPieces: Bool) {
        self.palette = palette
        self.showsPieces = showsPieces
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<2, id: \.self) { sideIndex in
                ForEach(0..<2, id: \.self) { squareIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<6, id: \.self) { kindIndex in
                            ZStack {
                                Rectangle().fill(palette.squareStyle(isLight: squareIndex == 0))
                                if showsPieces {
                                    ChessPieceGraphic(
                                        piece: ChessPiece(kind: kinds[kindIndex], side: sides[sideIndex]),
                                        palette: palette,
                                        squareSize: squareSize
                                    )
                                    .frame(width: squareSize, height: squareSize)
                                }
                            }
                            .frame(width: squareSize, height: squareSize)
                        }
                    }
                }
            }
        }
    }
}
