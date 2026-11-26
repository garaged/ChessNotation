import CoreGraphics
import Foundation
import ImageIO
import Testing
@testable import ChessNotation

struct ChessPieceAssetAuditTests {
    @Test
    func productionPiecesUseNormalizedTransparentMobileCanvases() throws {
        let root = try repositoryRoot()
        let kinds: [ChessPiece.Kind] = [.king, .queen, .rook, .bishop, .knight, .pawn]

        for side in ChessSide.allCases {
            for kind in kinds {
                let piece = ChessPiece(kind: kind, side: side)
                let image = try #require(
                    sourceImage(for: piece, from: root),
                    "Missing piece artwork: \(piece.imageName)"
                )

                #expect(
                    image.width == 1024 && image.height == 1024,
                    Comment(rawValue: "\(piece.imageName) must retain the normalized square canvas used by the shared 1.0 mobile presentation scale.")
                )
                #expect(
                    image.alphaInfo != .none && image.alphaInfo != .noneSkipFirst && image.alphaInfo != .noneSkipLast,
                    Comment(rawValue: "\(piece.imageName) must preserve transparency for its normalized board-safe margins.")
                )
                let bounds = try #require(alphaBounds(in: image), "No visible pixels in \(piece.imageName)")
                let height = bounds.height / CGFloat(image.height)
                let minimum: CGFloat = kind == .pawn ? 0.80 : 0.86
                #expect(height >= minimum && height <= 0.96, Comment(rawValue: "\(piece.imageName) visible height is \(height); expected \(minimum)...0.96"))
                let margins = [bounds.minX, bounds.minY, CGFloat(image.width) - bounds.maxX, CGFloat(image.height) - bounds.maxY]
                #expect(margins.allSatisfy { $0 > 0 }, Comment(rawValue: "\(piece.imageName) has visible pixels at the canvas edge: \(margins)"))
            }
        }
    }

    private func alphaBounds(in image: CGImage) -> CGRect? {
        let width = image.width, height = image.height
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let pixels = context.data?.assumingMemoryBound(to: UInt8.self) else { return nil }
        var minX = width, minY = height, maxX = -1, maxY = -1
        for y in 0..<height {
            for x in 0..<width where pixels[(y * width + x) * 4 + 3] > 12 {
                minX = min(minX, x); minY = min(minY, y)
                maxX = max(maxX, x); maxY = max(maxY, y)
            }
        }
        guard maxX >= minX, maxY >= minY else { return nil }
        return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
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
