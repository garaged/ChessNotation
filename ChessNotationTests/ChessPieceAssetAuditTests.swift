import CoreGraphics
import Foundation
import ImageIO
import Testing
@testable import ChessNotation

struct ChessPieceAssetAuditTests {
    @Test
    func productionPiecesHaveTransparentCanvasesAndNormalizedVisibleHeights() throws {
        let root = try repositoryRoot()
        let kinds: [ChessPiece.Kind] = [.king, .queen, .rook, .bishop, .knight, .pawn]

        for side in ChessSide.allCases {
            for kind in kinds {
                let piece = ChessPiece(kind: kind, side: side)
                let image = try #require(
                    sourceImage(for: piece, from: root),
                    "Missing piece artwork: \(piece.imageName)"
                )
                let bounds = try #require(
                    alphaBounds(in: image),
                    "Piece artwork has no visible pixels: \(piece.imageName)"
                )

                let visibleHeight = bounds.height / CGFloat(image.height)
                let expected = kind == .pawn ? 0.83 : 0.88
                #expect(
                    abs(visibleHeight - expected) <= 0.03,
                    Comment(rawValue: "\(piece.imageName) must use the normalized mobile visible-height contract.")
                )

                let topClearance = bounds.minY / CGFloat(image.height)
                let bottomClearance = CGFloat(image.height - 1) - bounds.maxY
                #expect(topClearance >= 0.04)
                #expect(bottomClearance / CGFloat(image.height) >= 0.04)
            }
        }
    }

    private func sourceImage(for piece: ChessPiece, from root: URL) -> CGImage? {
        let assetURL = root
            .appendingPathComponent("ChessNotation/Assets.xcassets")
            .appendingPathComponent("\(piece.imageName).imageset")
            .appendingPathComponent("\(piece.imageName).png")

        guard let source = CGImageSourceCreateWithURL(assetURL as CFURL, nil) else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    private func alphaBounds(in image: CGImage) -> CGRect? {
        let width = image.width
        let height = image.height
        let bytesPerRow = width * 4
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else {
            return nil
        }

        var minX = width
        var minY = height
        var maxX = -1
        var maxY = -1

        for y in 0..<height {
            for x in 0..<width {
                let alpha = data[y * bytesPerRow + x * 4 + 3]
                guard alpha > 12 else { continue }
                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
            }
        }

        guard maxX >= minX, maxY >= minY else { return nil }
        return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    }

    private func repositoryRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

        while candidate.path != "/" {
            let project = candidate.appendingPathComponent("ChessNotation.xcodeproj/project.pbxproj")
            if FileManager.default.fileExists(atPath: project.path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }

        throw ChessPieceAssetAuditError.repositoryRootNotFound
    }
}

private enum ChessPieceAssetAuditError: Error {
    case repositoryRootNotFound
}
