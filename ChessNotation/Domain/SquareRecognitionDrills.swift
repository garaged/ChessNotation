import Foundation

enum SquareRecognitionDrillKind: String, Codable, CaseIterable, Sendable {
    case findSquare
    case nameSquare
    case squareColor
    case relativeSquare
    case route
}

enum BoardOrientationPolicy: String, Codable, CaseIterable, Sendable {
    case white
    case black
    case alternating
}

enum SquareRecognitionZone: Hashable, Codable, Sendable {
    case all
    case center
    case corners
    case edges
    case file(String)
    case rank(Int)
    case quadrant(Int)
}

enum ChessSquareColor: String, Codable, Sendable {
    case light
    case dark
}

nonisolated struct ChessSquare: Hashable, Codable, Sendable, CustomStringConvertible {
    let file: Int
    let rank: Int

    init?(file: Int, rank: Int) {
        guard (0..<8).contains(file), (0..<8).contains(rank) else { return nil }
        self.file = file
        self.rank = rank
    }

    init?(_ coordinate: String) {
        guard coordinate.count == 2,
              let fileScalar = coordinate.unicodeScalars.first?.value,
              let rankCharacter = coordinate.last,
              let rank = Int(String(rankCharacter)) else { return nil }
        self.init(file: Int(fileScalar - UnicodeScalar("a").value), rank: rank - 1)
    }

    var description: String {
        guard let fileScalar = UnicodeScalar(Int(UnicodeScalar("a").value) + file) else {
            return "?\(rank + 1)"
        }
        return "\(Character(fileScalar))\(rank + 1)"
    }

    var color: ChessSquareColor {
        (file + rank).isMultiple(of: 2) ? .dark : .light
    }

    func offset(file fileDelta: Int, rank rankDelta: Int) -> ChessSquare? {
        ChessSquare(file: file + fileDelta, rank: rank + rankDelta)
    }
}

struct SquareRecognitionPrompt: Hashable, Sendable {
    let target: ChessSquare
    let orientation: BoardOrientationPolicy
    let route: [ChessSquare]
}

struct SquareRecognitionPromptFactory {
    static let allSquares: [ChessSquare] = (0..<8).flatMap { rank in
        (0..<8).compactMap { ChessSquare(file: $0, rank: rank) }
    }

    static func squares(in zone: SquareRecognitionZone) -> [ChessSquare] {
        switch zone {
        case .all:
            return allSquares
        case .center:
            return allSquares.filter { (2...5).contains($0.file) && (2...5).contains($0.rank) }
        case .corners:
            return allSquares.filter { [0, 7].contains($0.file) && [0, 7].contains($0.rank) }
        case .edges:
            return allSquares.filter { [0, 7].contains($0.file) || [0, 7].contains($0.rank) }
        case .file(let file):
            guard let first = file.lowercased().unicodeScalars.first else { return [] }
            let index = Int(first.value - UnicodeScalar("a").value)
            return allSquares.filter { $0.file == index }
        case .rank(let rank):
            return allSquares.filter { $0.rank == rank - 1 }
        case .quadrant(let quadrant):
            return allSquares.filter { square in
                switch quadrant {
                case 1:
                    return square.file >= 4 && square.rank >= 4
                case 2:
                    return square.file < 4 && square.rank >= 4
                case 3:
                    return square.file < 4 && square.rank < 4
                case 4:
                    return square.file >= 4 && square.rank < 4
                default:
                    return false
                }
            }
        }
    }
}
