import Foundation

nonisolated enum PositionRecallQuestion: String, Codable {
    case locatePiece
    case squareOccupant
    case occupiedSubset
}

nonisolated struct PositionRecallItem: Hashable, Codable {
    let name: String
    let square: ChessSquare
}

nonisolated struct PositionRecallPrompt: Hashable, Codable {
    let items: [PositionRecallItem]
    let question: PositionRecallQuestion
    let requestedName: String?
    let requestedSquare: ChessSquare?
    let subset: Set<ChessSquare>
    let orientation: BoardOrientationPolicy
    let studyDuration: TimeInterval

    var expectedSquares: Set<ChessSquare> {
        switch question {
        case .locatePiece:
            guard let requestedName else { return [] }
            guard let item = items.first(where: { $0.name == requestedName }) else { return [] }
            return [item.square]
        case .squareOccupant:
            guard let requestedSquare else { return [] }
            return items.contains(where: { $0.square == requestedSquare }) ? [requestedSquare] : []
        case .occupiedSubset:
            return Set(items.map { $0.square }).intersection(subset)
        }
    }
}
