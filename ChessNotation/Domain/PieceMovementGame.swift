import Foundation

enum TrainingPiece: String, Codable, CaseIterable, Sendable {
    case king
    case queen
    case rook
    case bishop
    case knight
    case pawn
}

enum TrainingSide: String, Codable, Sendable {
    case white
    case black
}

struct PieceMovementOccupancy: Hashable, Codable, Sendable {
    let friendly: Set<ChessSquare>
    let enemy: Set<ChessSquare>

    init(friendly: Set<ChessSquare> = [], enemy: Set<ChessSquare> = []) {
        self.friendly = friendly
        self.enemy = enemy.subtracting(friendly)
    }

    var isValid: Bool { friendly.isDisjoint(with: enemy) }
}

struct PieceMovementPrompt: Hashable, Codable, Sendable {
    let piece: TrainingPiece
    let side: TrainingSide
    let source: ChessSquare
    let occupancy: PieceMovementOccupancy
    let orientation: BoardOrientationPolicy
    let difficulty: TrainingDifficulty
    let allowPawnDoubleStep: Bool
    let expectedDestinations: Set<ChessSquare>
}

struct PieceMovementSubmission: Hashable, Codable, Sendable {
    let selected: Set<ChessSquare>
    let missing: Set<ChessSquare>
    let extra: Set<ChessSquare>

    var isExact: Bool { missing.isEmpty && extra.isEmpty }

    init(selected: Set<ChessSquare>, expected: Set<ChessSquare>) {
        self.selected = selected
        self.missing = expected.subtracting(selected)
        self.extra = selected.subtracting(expected)
    }
}

enum PieceMovementGeometry {
    static func destinations(
        piece: TrainingPiece,
        side: TrainingSide,
        source: ChessSquare,
        occupancy: PieceMovementOccupancy,
        allowPawnDoubleStep: Bool = false
    ) -> Set<ChessSquare> {
        switch piece {
        case .king:
            return jumpingDestinations(
                offsets: [-1, 0, 1].flatMap { file in
                    [-1, 0, 1].compactMap { rank in
                        file == 0 && rank == 0 ? nil : (file, rank)
                    }
                },
                source: source,
                occupancy: occupancy
            )
        case .knight:
            return jumpingDestinations(
                offsets: [
                    (-2, -1), (-2, 1), (-1, -2), (-1, 2),
                    (1, -2), (1, 2), (2, -1), (2, 1)
                ],
                source: source,
                occupancy: occupancy
            )
        case .rook:
            return slidingDestinations(
                directions: [(1, 0), (-1, 0), (0, 1), (0, -1)],
                source: source,
                occupancy: occupancy
            )
        case .bishop:
            return slidingDestinations(
                directions: [(1, 1), (1, -1), (-1, 1), (-1, -1)],
                source: source,
                occupancy: occupancy
            )
        case .queen:
            return slidingDestinations(
                directions: [
                    (1, 0), (-1, 0), (0, 1), (0, -1),
                    (1, 1), (1, -1), (-1, 1), (-1, -1)
                ],
                source: source,
                occupancy: occupancy
            )
        case .pawn:
            return pawnDestinations(
                side: side,
                source: source,
                occupancy: occupancy,
                allowDoubleStep: allowPawnDoubleStep
            )
        }
    }

    private static func jumpingDestinations(
        offsets: [(Int, Int)],
        source: ChessSquare,
        occupancy: PieceMovementOccupancy
    ) -> Set<ChessSquare> {
        Set(offsets.compactMap { file, rank in
            guard let destination = source.offset(file: file, rank: rank),
                  !occupancy.friendly.contains(destination) else { return nil }
            return destination
        })
    }

    private static func slidingDestinations(
        directions: [(Int, Int)],
        source: ChessSquare,
        occupancy: PieceMovementOccupancy
    ) -> Set<ChessSquare> {
        var result: Set<ChessSquare> = []

        for direction in directions {
            var distance = 1
            while let destination = source.offset(
                file: direction.0 * distance,
                rank: direction.1 * distance
            ) {
                if occupancy.friendly.contains(destination) {
                    break
                }
                result.insert(destination)
                if occupancy.enemy.contains(destination) {
                    break
                }
                distance += 1
            }
        }

        return result
    }

    private static func pawnDestinations(
        side: TrainingSide,
        source: ChessSquare,
        occupancy: PieceMovementOccupancy,
        allowDoubleStep: Bool
    ) -> Set<ChessSquare> {
        let direction = side == .white ? 1 : -1
        let initialRank = side == .white ? 1 : 6
        var result: Set<ChessSquare> = []

        if let forward = source.offset(file: 0, rank: direction),
           !occupancy.friendly.contains(forward),
           !occupancy.enemy.contains(forward) {
            result.insert(forward)

            if allowDoubleStep,
               source.rank == initialRank,
               let double = source.offset(file: 0, rank: direction * 2),
               !occupancy.friendly.contains(double),
               !occupancy.enemy.contains(double) {
                result.insert(double)
            }
        }

        for fileDelta in [-1, 1] {
            if let capture = source.offset(file: fileDelta, rank: direction),
               occupancy.enemy.contains(capture) {
                result.insert(capture)
            }
        }

        return result
    }
}

struct PieceMovementPromptFactory {
    static func makePrompt(
        piece: TrainingPiece,
        side: TrainingSide,
        source: ChessSquare,
        occupancy: PieceMovementOccupancy,
        orientation: BoardOrientationPolicy,
        difficulty: TrainingDifficulty,
        allowPawnDoubleStep: Bool = false
    ) -> PieceMovementPrompt? {
        guard occupancy.isValid,
              !occupancy.friendly.contains(source),
              !occupancy.enemy.contains(source) else { return nil }

        let expected = PieceMovementGeometry.destinations(
            piece: piece,
            side: side,
            source: source,
            occupancy: occupancy,
            allowPawnDoubleStep: allowPawnDoubleStep
        )
        guard !expected.isEmpty else { return nil }

        return PieceMovementPrompt(
            piece: piece,
            side: side,
            source: source,
            occupancy: occupancy,
            orientation: orientation,
            difficulty: difficulty,
            allowPawnDoubleStep: allowPawnDoubleStep,
            expectedDestinations: expected
        )
    }
}

struct PieceMovementSessionResult: Hashable, Codable, Sendable {
    let pieceTypes: Set<TrainingPiece>
    let difficulty: TrainingDifficulty
    let orientation: BoardOrientationPolicy
    let promptCount: Int
    let exactCount: Int
    let partialCount: Int
    let missingSelectionCount: Int
    let extraSelectionCount: Int
    let averageLatency: TimeInterval
    let bestStreak: Int
    let finishReason: TrainingFinishReason
}

enum PieceMovementFeedback {
    static func message(for submission: PieceMovementSubmission) -> String {
        if submission.isExact { return "Correct. All legal movement squares were selected." }
        if !submission.missing.isEmpty && !submission.extra.isEmpty {
            return "Some legal squares are missing, and some selected squares are not valid."
        }
        if !submission.missing.isEmpty {
            return "Some legal movement squares are still missing."
        }
        return "Some selected squares are not valid movement destinations."
    }

    static func accessibilityDescription(
        piece: TrainingPiece,
        side: TrainingSide,
        source: ChessSquare,
        occupancy: PieceMovementOccupancy,
        selected: Set<ChessSquare>,
        progress: String
    ) -> String {
        let friendly = occupancy.friendly.map(\.description).sorted().joined(separator: ", ")
        let enemy = occupancy.enemy.map(\.description).sorted().joined(separator: ", ")
        let selections = selected.map(\.description).sorted().joined(separator: ", ")
        return "\(side.rawValue.capitalized) \(piece.rawValue) on \(source.description). Friendly blockers: \(friendly.isEmpty ? "none" : friendly). Enemy pieces: \(enemy.isEmpty ? "none" : enemy). Selected squares: \(selections.isEmpty ? "none" : selections). \(progress)"
    }
}
