import Foundation

nonisolated struct PositionRecallPiece: Hashable, Codable, Sendable {
    let piece: TrainingPiece
    let side: TrainingSide
}

nonisolated struct PositionRecallPlacedPiece: Hashable, Codable, Sendable {
    let square: ChessSquare
    let piece: PositionRecallPiece
}

nonisolated struct PositionRecallSnapshot: Hashable, Codable, Sendable {
    let pieces: [PositionRecallPlacedPiece]

    init(pieces: [PositionRecallPlacedPiece]) {
        self.pieces = pieces
    }

    var occupiedSquares: Set<ChessSquare> {
        Set(pieces.map(\.square))
    }

    var isValid: Bool {
        occupiedSquares.count == pieces.count
    }

    func piece(at square: ChessSquare) -> PositionRecallPiece? {
        pieces.first { $0.square == square }?.piece
    }
}

nonisolated struct PositionRecallReconstructionPrompt: Hashable, Codable, Sendable {
    let snapshot: PositionRecallSnapshot
    let maskedSquares: Set<ChessSquare>
    let orientation: BoardOrientationPolicy
    let difficulty: TrainingDifficulty

    var expectedPieces: Set<PositionRecallPlacedPiece> {
        Set(snapshot.pieces.filter { maskedSquares.contains($0.square) })
    }
}

nonisolated struct PositionRecallReconstructionAnswer: Hashable, Codable, Sendable {
    let pieces: Set<PositionRecallPlacedPiece>
}

nonisolated struct PositionRecallEvaluation: Hashable, Codable, Sendable {
    let isExact: Bool
    let missing: Set<PositionRecallPlacedPiece>
    let extra: Set<PositionRecallPlacedPiece>
    let wrongPieceSquares: Set<ChessSquare>
    let wrongSideSquares: Set<ChessSquare>

    init(answer: PositionRecallReconstructionAnswer, expected: Set<PositionRecallPlacedPiece>) {
        missing = expected.subtracting(answer.pieces)
        extra = answer.pieces.subtracting(expected)
        var wrongPieces: Set<ChessSquare> = []
        var wrongSides: Set<ChessSquare> = []

        for submitted in answer.pieces {
            guard let expectedAtSquare = expected.first(where: { $0.square == submitted.square }) else { continue }
            if expectedAtSquare.piece.piece != submitted.piece.piece {
                wrongPieces.insert(submitted.square)
            }
            if expectedAtSquare.piece.side != submitted.piece.side {
                wrongSides.insert(submitted.square)
            }
        }

        wrongPieceSquares = wrongPieces
        wrongSideSquares = wrongSides
        isExact = missing.isEmpty && extra.isEmpty
    }
}

nonisolated struct PositionRecallReconstructionPromptFactory {
    static func maskCount(for difficulty: TrainingDifficulty, occupiedCount: Int) -> Int {
        let requested: Int
        switch difficulty {
        case .beginner: requested = 1
        case .intermediate: requested = 2
        case .advanced: requested = 4
        }
        return min(max(1, requested), occupiedCount)
    }

    static func makePrompt(
        snapshot: PositionRecallSnapshot,
        difficulty: TrainingDifficulty,
        orientation: BoardOrientationPolicy,
        randomizer: ChallengeRandomizing
    ) -> PositionRecallReconstructionPrompt? {
        guard snapshot.isValid, !snapshot.pieces.isEmpty else { return nil }
        var available = snapshot.pieces.map(\.square)
        var masked: Set<ChessSquare> = []
        let count = maskCount(for: difficulty, occupiedCount: available.count)
        for _ in 0..<count where !available.isEmpty {
            let index = randomizer.nextInt(upperBound: available.count)
            masked.insert(available.remove(at: index))
        }
        guard !masked.isEmpty else { return nil }
        return PositionRecallReconstructionPrompt(
            snapshot: snapshot,
            maskedSquares: masked,
            orientation: orientation,
            difficulty: difficulty
        )
    }
}

final class PositionRecallReconstructionPromptGenerator {
    private let snapshots: [PositionRecallSnapshot]
    private let difficulty: TrainingDifficulty
    private let orientation: BoardOrientationPolicy
    private let randomizer: ChallengeRandomizing
    private let maximumAttempts: Int
    private var promptIndex = 0

    init(
        snapshots: [PositionRecallSnapshot],
        difficulty: TrainingDifficulty,
        orientation: BoardOrientationPolicy,
        randomizer: ChallengeRandomizing,
        maximumAttempts: Int = 32
    ) {
        self.snapshots = snapshots
        self.difficulty = difficulty
        self.orientation = orientation
        self.randomizer = randomizer
        self.maximumAttempts = max(1, maximumAttempts)
    }

    func next() -> PositionRecallReconstructionPrompt? {
        guard !snapshots.isEmpty else { return nil }
        for _ in 0..<maximumAttempts {
            let snapshot = snapshots[randomizer.nextInt(upperBound: snapshots.count)]
            let resolvedOrientation: BoardOrientationPolicy
            switch orientation {
            case .white, .black:
                resolvedOrientation = orientation
            case .alternating:
                resolvedOrientation = promptIndex.isMultiple(of: 2) ? .white : .black
            }
            guard let prompt = PositionRecallReconstructionPromptFactory.makePrompt(
                snapshot: snapshot,
                difficulty: difficulty,
                orientation: resolvedOrientation,
                randomizer: randomizer
            ) else { continue }
            promptIndex += 1
            return prompt
        }
        return nil
    }
}

nonisolated struct PositionRecallSessionResult: Hashable, Codable, Sendable {
    let difficulty: TrainingDifficulty
    let orientation: BoardOrientationPolicy
    let promptCount: Int
    let exactCount: Int
    let partialCount: Int
    let missingCount: Int
    let extraCount: Int
    let wrongPieceCount: Int
    let wrongSideCount: Int
    let averageLatency: TimeInterval
    let bestStreak: Int
    let finishReason: TrainingFinishReason
}

enum PositionRecallReconstructionFeedback {
    static func message(for evaluation: PositionRecallEvaluation) -> String {
        if evaluation.isExact { return "Correct. The hidden position was recalled exactly." }
        var parts: [String] = []
        if !evaluation.missing.isEmpty { parts.append("Some hidden pieces are missing") }
        if !evaluation.extra.isEmpty { parts.append("Some recalled pieces were extra") }
        if !evaluation.wrongPieceSquares.isEmpty { parts.append("Some recalled piece types were wrong") }
        if !evaluation.wrongSideSquares.isEmpty { parts.append("Some recalled piece colors were wrong") }
        return parts.joined(separator: ", ") + "."
    }

    static func accessibilityDescription(
        prompt: PositionRecallReconstructionPrompt,
        answer: PositionRecallReconstructionAnswer,
        progress: String
    ) -> String {
        let visible = prompt.snapshot.pieces
            .filter { !prompt.maskedSquares.contains($0.square) }
            .map { "\($0.piece.side.rawValue) \($0.piece.piece.rawValue) on \($0.square.description)" }
            .sorted()
            .joined(separator: ", ")
        let masked = prompt.maskedSquares.map { $0.description }.sorted().joined(separator: ", ")
        let reconstructed = answer.pieces
            .map { "\($0.piece.side.rawValue) \($0.piece.piece.rawValue) on \($0.square.description)" }
            .sorted()
            .joined(separator: ", ")
        return "Position recall. Orientation: \(prompt.orientation.rawValue). Visible pieces: \(visible.isEmpty ? "none" : visible). Masked squares: \(masked). Reconstructed pieces: \(reconstructed.isEmpty ? "none" : reconstructed). \(progress)"
    }
}
