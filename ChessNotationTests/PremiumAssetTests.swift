import Testing
@testable import ChessNotation

struct PremiumAssetTests {
    @Test
    func requiredPremiumArtworkAssetsAreAvailable() {
        let requiredAssets = [
            PremiumAssetName.homeHero,
            PremiumAssetName.notationTrainingTile,
            PremiumAssetName.timedNotationTile,
            PremiumAssetName.squareRecognitionTile,
            PremiumAssetName.instructionsTile,
            PremiumAssetName.libraryRandomGame,
            PremiumAssetName.darkBoardTexture
        ]

        for assetName in requiredAssets {
            #expect(PremiumAssetAvailability.hasImage(named: assetName), "Missing premium asset: \(assetName)")
        }
    }

    @Test
    func requiredChessPieceArtworkAssetsAreAvailable() {
        let pieceKinds: [ChessPiece.Kind] = [.king, .queen, .rook, .bishop, .knight, .pawn]
        let requiredPieces = ChessSide.allCases.flatMap { side in
            pieceKinds.map { kind in
                ChessPiece(kind: kind, side: side).imageName
            }
        }

        for assetName in requiredPieces {
            #expect(PremiumAssetAvailability.hasImage(named: assetName), "Missing chess piece asset: \(assetName)")
        }
    }
}
