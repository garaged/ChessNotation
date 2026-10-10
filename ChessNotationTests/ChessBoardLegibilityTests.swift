import Foundation
import Testing
@testable import ChessNotation

struct ChessBoardLegibilityTests {
    @Test
    func everyThemeMaintainsSquareAndPieceBoundaryContrast() {
        for theme in ChessVisualTheme.allCases {
            let contract = theme.legibilityContract

            #expect(
                contract.meetsMinimumContrast(),
                Comment(rawValue: "\(theme.displayName) must keep square and visible piece boundaries at or above 3:1 contrast.")
            )

            for side in ChessSide.allCases {
                for square in contract.squareColors {
                    #expect(
                        contract.visiblePieceContrast(side: side, against: square) >= 3,
                        Comment(rawValue: "\(theme.displayName) \(side) pieces must remain visible on every square endpoint.")
                    )
                }
            }
        }
    }

    @Test
    func sharedPieceScalePrioritizesSmallMobilePiecesWithoutOversizingMajorPieces() {
        #expect(ChessPiecePresentationMetrics.imageScale(for: .pawn) >= 1.15)
        #expect(ChessPiecePresentationMetrics.imageScale(for: .pawn) <= 1.20)

        for kind in [ChessPiece.Kind.knight, .bishop, .rook, .queen, .king] {
            let scale = ChessPiecePresentationMetrics.imageScale(for: kind)
            #expect(scale >= 1.04)
            #expect(scale <= 1.10)
        }
    }

    @Test
    func contourAndDepthEffectsRemainVisibleAtCompactBoardSizes() {
        #expect(ChessPiecePresentationMetrics.contourRadius(for: 32) >= 1.1)
        #expect(ChessPiecePresentationMetrics.contourRadius(for: 96) <= 2.2)
        #expect(ChessPiecePresentationMetrics.shadowRadius(for: 32) >= 0.8)
        #expect(ChessPiecePresentationMetrics.shadowRadius(for: 96) <= 1.8)
    }

    @Test
    func boardConsumersUseTheSharedPiecePresentationPolicy() throws {
        let root = try repositoryRoot()
        let requiredConsumers = [
            "ChessNotation/Features/Game/ChessBoardView.swift",
            "ChessNotation/Features/PieceMovement/PieceMovementFeature.swift",
            "ChessNotation/Features/PositionRecall/PositionRecallReconstructionView.swift",
            "ChessNotation/Features/Home/AppearanceSettingsView.swift",
            "ChessNotation/Features/Home/GameThumbnailPreview.swift"
        ]

        for path in requiredConsumers {
            let source = try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
            #expect(
                source.contains("ChessPiecePresentationMetrics") || source.contains("ChessPieceGraphic("),
                Comment(rawValue: "\(path) must consume the shared chess piece presentation.")
            )
            #expect(
                !source.contains("piece.scale") && !source.contains("* 0.82"),
                Comment(rawValue: "\(path) must not reintroduce an isolated piece scale.")
            )
        }
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

        throw ChessBoardLegibilityAuditError.repositoryRootNotFound
    }
}

private enum ChessBoardLegibilityAuditError: Error {
    case repositoryRootNotFound
}
