import Foundation

enum ChessSide: String, Codable, CaseIterable, Identifiable, Hashable {
    case white
    case black

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .white: return "White"
        case .black: return "Black"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable, Identifiable, Hashable {
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }
}

enum MoveTypeTag: String, Codable, CaseIterable, Identifiable, Hashable {
    case pawnMove
    case pieceMove
    case capture
    case check
    case checkmate
    case castling
    case promotion
    case disambiguation
    case enPassant

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pawnMove: return "Pawn move"
        case .pieceMove: return "Piece move"
        case .capture: return "Capture"
        case .check: return "Check"
        case .checkmate: return "Checkmate"
        case .castling: return "Castling"
        case .promotion: return "Promotion"
        case .disambiguation: return "Disambiguation"
        case .enPassant: return "En passant"
        }
    }
}

struct NotationGame: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let white: String
    let black: String
    let year: Int?
    let opening: String?
    let difficulty: Difficulty
    let moves: [NotationMove]
}

struct NotationMove: Identifiable, Codable, Equatable, Hashable {
    var id: String { "\(moveNumber)-\(side.rawValue)-\(from)-\(to)-\(san)" }

    let moveNumber: Int
    let side: ChessSide
    let fenBefore: String
    let from: String
    let to: String
    let san: String
    let coordinate: String
    let tags: [MoveTypeTag]
    let engineEvaluation: EngineEvaluation?
}

struct EngineEvaluation: Codable, Equatable, Hashable {
    let engine: String
    let depth: Int
    let fen: String
    let score: EngineScore?

    var whiteAdvantageFraction: Double {
        score?.whiteAdvantageFraction ?? 0.5
    }

    var displayText: String {
        score?.displayText ?? "0.0"
    }
}

enum EngineScoreKind: String, Codable, Equatable, Hashable {
    case centipawn = "centipawn"
    case mate = "mate"
}

struct EngineScore: Codable, Equatable, Hashable {
    let kind: EngineScoreKind
    let whiteCentipawns: Int?
    let mateIn: Int?

    var whiteAdvantageFraction: Double {
        switch kind {
        case .mate:
            guard let mateIn else { return 0.5 }
            return mateIn >= 0 ? 1.0 : 0.0

        case .centipawn:
            guard let whiteCentipawns else { return 0.5 }
            let clampedCp = max(-1000, min(1000, whiteCentipawns))
            return 1 / (1 + exp(-Double(clampedCp) / 350.0))
        }
    }

    var displayText: String {
        switch kind {
        case .mate:
            guard let mateIn else { return "0.0" }
            return mateIn >= 0 ? "M\(mateIn)" : "-M\(abs(mateIn))"

        case .centipawn:
            guard let whiteCentipawns else { return "0.0" }
            let pawns = Double(whiteCentipawns) / 100
            return pawns >= 0 ? String(format: "+%.1f", pawns) : String(format: "%.1f", pawns)
        }
    }
}

struct BoardSquare: Identifiable, Equatable {
    let file: Int
    let rank: Int
    let piece: ChessPiece?

    var id: String { coordinate }

    var coordinate: String {
        let fileScalar = UnicodeScalar(97 + file)!
        return "\(Character(fileScalar))\(rank + 1)"
    }

    var isLight: Bool {
        (file + rank).isMultiple(of: 2)
    }
}

struct ChessPiece: Equatable {
    enum Kind: Character {
        case king = "k"
        case queen = "q"
        case rook = "r"
        case bishop = "b"
        case knight = "n"
        case pawn = "p"
    }

    let kind: Kind
    let side: ChessSide

    init(kind: Kind, side: ChessSide) {
        self.kind = kind
        self.side = side
    }

    var symbol: String {
        switch (side, kind) {
        case (.white, .king): return "♔"
        case (.white, .queen): return "♕"
        case (.white, .rook): return "♖"
        case (.white, .bishop): return "♗"
        case (.white, .knight): return "♘"
        case (.white, .pawn): return "♙"
        case (.black, .king): return "♚"
        case (.black, .queen): return "♛"
        case (.black, .rook): return "♜"
        case (.black, .bishop): return "♝"
        case (.black, .knight): return "♞"
        case (.black, .pawn): return "♟"
        }
    }

    var imageName: String {
        switch (side, kind) {
        case (.white, .king): return "white-king"
        case (.white, .queen): return "white-queen"
        case (.white, .rook): return "white-rook"
        case (.white, .bishop): return "white-bishop"
        case (.white, .knight): return "white-knight"
        case (.white, .pawn): return "white-pawn"
        case (.black, .king): return "black-king"
        case (.black, .queen): return "black-queen"
        case (.black, .rook): return "black-rook"
        case (.black, .bishop): return "black-bishop"
        case (.black, .knight): return "black-knight"
        case (.black, .pawn): return "black-pawn"
        }
    }

    var scale: Double {
        switch kind {
        case .king: return 0.94
        case .queen: return 0.92
        case .rook: return 0.9
        case .bishop: return 0.9
        case .knight: return 0.88
        case .pawn: return 0.74
        }
    }

    init?(fenCharacter: Character) {
        let lower = Character(String(fenCharacter).lowercased())
        guard let kind = Kind(rawValue: lower) else { return nil }
        self.kind = kind
        self.side = fenCharacter.isUppercase ? .white : .black
    }
}

private extension Character {
    var isUppercase: Bool {
        String(self) == String(self).uppercased()
    }
}
