import Foundation

enum FENParser {
    static let startPosition = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    static func squares(from fen: String) -> [BoardSquare] {
        let normalizedFen = fen == "startpos" ? startPosition : fen
        let placement = normalizedFen.split(separator: " ").first.map(String.init) ?? normalizedFen
        let ranks = placement.split(separator: "/").map(String.init)

        var piecesByCoordinate: [String: ChessPiece] = [:]

        for (fenRankIndex, rankString) in ranks.enumerated() {
            let rank = 7 - fenRankIndex
            var file = 0

            for character in rankString {
                if let emptyCount = character.wholeNumberValue {
                    file += emptyCount
                } else if let piece = ChessPiece(fenCharacter: character) {
                    let coordinate = coordinate(file: file, rank: rank)
                    piecesByCoordinate[coordinate] = piece
                    file += 1
                }
            }
        }

        var squares: [BoardSquare] = []
        for rank in (0...7).reversed() {
            for file in 0...7 {
                let coordinate = coordinate(file: file, rank: rank)
                squares.append(BoardSquare(file: file, rank: rank, piece: piecesByCoordinate[coordinate]))
            }
        }
        return squares
    }

    private static func coordinate(file: Int, rank: Int) -> String {
        let fileScalar = UnicodeScalar(97 + file)!
        return "\(Character(fileScalar))\(rank + 1)"
    }
}
