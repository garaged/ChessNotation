import Foundation

enum ChessNotationKeyCategory {
    case piece
    case file
    case rank
    case symbol
    case castling
    case action
}

struct ChessNotationKeyAvailability {
    static let pieceKeys: Set<String> = ["K", "Q", "R", "B", "N"]
    static let promotionPieceKeys: Set<String> = ["Q", "R", "B", "N"]
    static let fileKeys: Set<String> = ["a", "b", "c", "d", "e", "f", "g", "h"]
    static let rankKeys: Set<String> = ["1", "2", "3", "4", "5", "6", "7", "8"]
    static let symbolKeys: Set<String> = ["x", "+", "#", "="]
    static let castlingKeys: Set<String> = ["O-O", "O-O-O"]
    static let actionKeys: Set<String> = ["Backspace", "Clear", "Submit"]

    static func availableKeys(for currentInput: String) -> Set<String> {
        let input = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)

        if input.isEmpty {
            return pieceKeys
                .union(fileKeys)
                .union(rankKeys)
                .union(castlingKeys)
        }

        let alwaysAvailableActions = actionKeys

        if input.hasSuffix("+") || input.hasSuffix("#") {
            return alwaysAvailableActions
        }

        if input == "O-O" || input == "O-O-O" {
            return Set(["+", "#"]).union(alwaysAvailableActions)
        }

        if input.hasSuffix("=") {
            return promotionPieceKeys.union(alwaysAvailableActions)
        }

        if let promotionMarkerIndex = input.lastIndex(of: "=") {
            let suffix = input[input.index(after: promotionMarkerIndex)...]
            if suffix.count == 1, let promotedPiece = suffix.first, promotionPieceKeys.contains(String(promotedPiece)) {
                return Set(["+", "#"]).union(alwaysAvailableActions)
            }
        }

        var availableKeys = pieceKeys
            .union(fileKeys)
            .union(rankKeys)
            .union(symbolKeys)
            .union(alwaysAvailableActions)

        availableKeys.subtract(castlingKeys)

        if input.contains("=") {
            availableKeys.remove("=")
        }

        return availableKeys
    }
}
