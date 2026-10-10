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
                    image.alphaInfo != .none && image.alphaInfo != .noneSkipFirst,
                    Comment(rawValue: "\(piece.imageName) must preserve transparency for its normalized board-safe margins.")
                )
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
