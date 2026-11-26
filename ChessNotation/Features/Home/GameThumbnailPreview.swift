import SwiftUI

struct GameThumbnailPreview: Equatable {
    enum Source: String, Equatable {
        case appliedMoves
        case shortGameFinalPosition
        case fenFallback
    }

    let squares: [BoardSquare]
    let source: Source
    let appliedPlyCount: Int
}

enum GameThumbnailGenerator {
    static let preferredPreviewPly = 8

    static func preview(for game: NotationGame) -> GameThumbnailPreview {
        guard let firstMove = game.moves.first else {
            return GameThumbnailPreview(squares: FENParser.squares(from: "startpos"), source: .shortGameFinalPosition, appliedPlyCount: 0)
        }

        var board = boardDictionary(from: FENParser.squares(from: firstMove.fenBefore))
        let targetPly = min(preferredPreviewPly, game.moves.count)
        var lastValidSquares = squares(from: board)
        var appliedCount = 0

        for move in game.moves.prefix(targetPly) {
            if requiresFallback(move) || !apply(move, to: &board) {
                return GameThumbnailPreview(squares: fallbackSquares(for: move, lastValidSquares: lastValidSquares), source: .fenFallback, appliedPlyCount: appliedCount)
            }

            appliedCount += 1
            lastValidSquares = squares(from: board)
        }

        let source: GameThumbnailPreview.Source = game.moves.count < preferredPreviewPly ? .shortGameFinalPosition : .appliedMoves
        return GameThumbnailPreview(squares: lastValidSquares, source: source, appliedPlyCount: appliedCount)
    }

    private static func requiresFallback(_ move: NotationMove) -> Bool {
        move.tags.contains(.castling) || move.tags.contains(.promotion) || move.tags.contains(.enPassant)
    }

    private static func apply(_ move: NotationMove, to board: inout [String: ChessPiece]) -> Bool {
        guard isValidCoordinate(move.from), isValidCoordinate(move.to), let piece = board[move.from] else { return false }
        board[move.from] = nil
        board[move.to] = piece
        return true
    }

    private static func fallbackSquares(for move: NotationMove, lastValidSquares: [BoardSquare]) -> [BoardSquare] {
        let fallback = FENParser.squares(from: move.fenBefore)
        return fallback.count == 64 ? fallback : lastValidSquares
    }

    private static func boardDictionary(from squares: [BoardSquare]) -> [String: ChessPiece] {
        Dictionary(uniqueKeysWithValues: squares.compactMap { square in
            guard let piece = square.piece else { return nil }
            return (square.coordinate, piece)
        })
    }

    private static func squares(from board: [String: ChessPiece]) -> [BoardSquare] {
        (0..<8).flatMap { rankIndex in
            let rank = 7 - rankIndex
            return (0..<8).map { file in
                let coordinate = coordinate(file: file, rank: rank)
                return BoardSquare(file: file, rank: rank, piece: board[coordinate])
            }
        }
    }

    private static func coordinate(file: Int, rank: Int) -> String {
        let scalar = UnicodeScalar(97 + file)!
        return "\(Character(scalar))\(rank + 1)"
    }

    private static func isValidCoordinate(_ coordinate: String) -> Bool {
        guard coordinate.count == 2,
              let file = coordinate.first,
              let rank = coordinate.last,
              ("a"..."h").contains(file),
              ("1"..."8").contains(rank) else { return false }
        return true
    }
}

struct GameThumbnailView: View {
    @Environment(AppSettings.self) private var appSettings
    let game: NotationGame
    let preview: GameThumbnailPreview

    init(game: NotationGame) {
        self.game = game
        self.preview = GameThumbnailGenerator.preview(for: game)
    }

    var body: some View {
        GeometryReader { proxy in
            let squareSize = min(proxy.size.width, proxy.size.height) / 8

            ZStack {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(squareSize), spacing: 0), count: 8), spacing: 0) {
                    ForEach(preview.squares) { square in
                        ZStack {
                            Rectangle()
                                .fill(appSettings.visualTheme.palette.squareStyle(isLight: square.isLight))
                            if let piece = square.piece {
                                ChessPieceGraphic(
                                    piece: piece,
                                    palette: appSettings.visualTheme.palette,
                                    squareSize: squareSize
                                )
                                .frame(width: squareSize, height: squareSize)
                            }
                        }
                        .frame(width: squareSize, height: squareSize)
                    }
                }
                .frame(width: squareSize * 8, height: squareSize * 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
        .background(PremiumDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: PremiumDesign.Radius.small))
        .overlay {
            RoundedRectangle(cornerRadius: PremiumDesign.Radius.small)
                .stroke(PremiumDesign.stroke, lineWidth: 1)
        }
        .accessibilityLabel("Board preview for \(game.title)")
        .accessibilityIdentifier("library.thumbnail.\(game.id)")
    }

}
