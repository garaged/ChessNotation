import Foundation
import Testing
@testable import ChessNotation

struct PositionRecallGameTests {
    private func sampleSnapshot() throws -> PositionRecallSnapshot {
        PositionRecallSnapshot(pieces: [
            PositionRecallPlacedPiece(square: try #require(ChessSquare("e4")), piece: PositionRecallPiece(piece: .king, side: .white)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("a8")), piece: PositionRecallPiece(piece: .queen, side: .black)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("c3")), piece: PositionRecallPiece(piece: .knight, side: .white)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("h1")), piece: PositionRecallPiece(piece: .rook, side: .black))
        ])
    }

    @Test
    func duplicateOccupiedSquaresAreInvalid() throws {
        let square = try #require(ChessSquare("e4"))
        let snapshot = PositionRecallSnapshot(pieces: [
            PositionRecallPlacedPiece(square: square, piece: PositionRecallPiece(piece: .king, side: .white)),
            PositionRecallPlacedPiece(square: square, piece: PositionRecallPiece(piece: .queen, side: .black))
        ])

        #expect(!snapshot.isValid)
        #expect(PositionRecallReconstructionPromptFactory.makePrompt(
            snapshot: snapshot,
            difficulty: .beginner,
            orientation: .white,
            randomizer: SeededChallengeRandomizer(seed: 1)
        ) == nil)
    }

    @Test
    func beginnerMasksExactlyOneOccupiedSquare() throws {
        let prompt = try #require(PositionRecallReconstructionPromptFactory.makePrompt(
            snapshot: sampleSnapshot(),
            difficulty: .beginner,
            orientation: .white,
            randomizer: SeededChallengeRandomizer(seed: 2)
        ))

        #expect(prompt.maskedSquares.count == 1)
        #expect(prompt.maskedSquares.isSubset(of: prompt.snapshot.occupiedSquares))
        #expect(prompt.expectedPieces.count == 1)
    }

    @Test
    func advancedMaskCountIsBoundedByOccupiedPieces() throws {
        let snapshot = PositionRecallSnapshot(pieces: [
            PositionRecallPlacedPiece(square: try #require(ChessSquare("e4")), piece: PositionRecallPiece(piece: .king, side: .white)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("a8")), piece: PositionRecallPiece(piece: .queen, side: .black))
        ])
        let prompt = try #require(PositionRecallReconstructionPromptFactory.makePrompt(
            snapshot: snapshot,
            difficulty: .advanced,
            orientation: .black,
            randomizer: SeededChallengeRandomizer(seed: 3)
        ))

        #expect(prompt.maskedSquares.count == 2)
        #expect(prompt.expectedPieces.count == 2)
    }

    @Test
    func exactAnswerIsOrderIndependent() throws {
        let prompt = try #require(PositionRecallReconstructionPromptFactory.makePrompt(
            snapshot: sampleSnapshot(),
            difficulty: .intermediate,
            orientation: .white,
            randomizer: SeededChallengeRandomizer(seed: 4)
        ))
        let reversed = PositionRecallReconstructionAnswer(pieces: Set(prompt.expectedPieces.reversed()))
        let evaluation = PositionRecallEvaluation(answer: reversed, expected: prompt.expectedPieces)

        #expect(evaluation.isExact)
        #expect(evaluation.missing.isEmpty)
        #expect(evaluation.extra.isEmpty)
    }

    @Test
    func missingExtraWrongPieceAndWrongSideAreRecorded() throws {
        let prompt = try #require(PositionRecallReconstructionPromptFactory.makePrompt(
            snapshot: sampleSnapshot(),
            difficulty: .beginner,
            orientation: .white,
            randomizer: SeededChallengeRandomizer(seed: 5)
        ))
        let expected = try #require(prompt.expectedPieces.first)
        let wrongPiece = PositionRecallPlacedPiece(
            square: expected.square,
            piece: PositionRecallPiece(piece: expected.piece.piece == .rook ? .bishop : .rook, side: expected.piece.side)
        )
        let wrongSide = PositionRecallPlacedPiece(
            square: expected.square,
            piece: PositionRecallPiece(piece: expected.piece.piece, side: expected.piece.side == .white ? .black : .white)
        )
        let extra = PositionRecallPlacedPiece(
            square: try #require(SquareRecognitionPromptFactory.allSquares.first { !prompt.maskedSquares.contains($0) }),
            piece: PositionRecallPiece(piece: .pawn, side: .white)
        )

        let wrongPieceEval = PositionRecallEvaluation(answer: PositionRecallReconstructionAnswer(pieces: [wrongPiece, extra]), expected: prompt.expectedPieces)
        let wrongSideEval = PositionRecallEvaluation(answer: PositionRecallReconstructionAnswer(pieces: [wrongSide]), expected: prompt.expectedPieces)
        let missingEval = PositionRecallEvaluation(answer: PositionRecallReconstructionAnswer(pieces: []), expected: prompt.expectedPieces)

        #expect(wrongPieceEval.wrongPieceSquares == [expected.square])
        #expect(wrongPieceEval.extra.contains(extra))
        #expect(wrongSideEval.wrongSideSquares == [expected.square])
        #expect(!missingEval.missing.isEmpty)
        #expect(PositionRecallReconstructionFeedback.message(for: wrongPieceEval).contains("piece types"))
        #expect(PositionRecallReconstructionFeedback.message(for: wrongSideEval).contains("colors"))
        #expect(PositionRecallReconstructionFeedback.message(for: missingEval).contains("missing"))
    }

    @Test
    func seededPromptGenerationIsDeterministicAndAlternatesOrientation() throws {
        let snapshots = try [sampleSnapshot()]
        let first = PositionRecallReconstructionPromptGenerator(
            snapshots: snapshots,
            difficulty: .intermediate,
            orientation: .alternating,
            randomizer: SeededChallengeRandomizer(seed: 9)
        )
        let second = PositionRecallReconstructionPromptGenerator(
            snapshots: snapshots,
            difficulty: .intermediate,
            orientation: .alternating,
            randomizer: SeededChallengeRandomizer(seed: 9)
        )

        let firstPrompt = try #require(first.next())
        let secondPrompt = try #require(first.next())
        #expect(firstPrompt == #require(second.next()))
        #expect(secondPrompt == #require(second.next()))
        #expect(firstPrompt.orientation == .white)
        #expect(secondPrompt.orientation == .black)
    }

    @Test
    func blackOrientationMappingRoundTripsMaskedSquares() throws {
        let prompt = try #require(PositionRecallReconstructionPromptFactory.makePrompt(
            snapshot: sampleSnapshot(),
            difficulty: .beginner,
            orientation: .black,
            randomizer: SeededChallengeRandomizer(seed: 6)
        ))
        for square in prompt.maskedSquares {
            let index = SquareBoardMapping.displayIndex(for: square, orientation: .black)
            #expect(SquareBoardMapping.square(forDisplayIndex: index, orientation: .black) == square)
        }
    }

    @Test
    func resultRoundTripsMetrics() throws {
        let result = PositionRecallSessionResult(
            difficulty: .advanced,
            orientation: .alternating,
            promptCount: 3,
            exactCount: 1,
            partialCount: 2,
            missingCount: 4,
            extraCount: 1,
            wrongPieceCount: 2,
            wrongSideCount: 1,
            averageLatency: 2.25,
            bestStreak: 1,
            finishReason: .completed
        )

        let data = try JSONEncoder().encode(result)
        #expect(try JSONDecoder().decode(PositionRecallSessionResult.self, from: data) == result)
    }

    @Test
    func accessibilityDescriptionMentionsVisibleMaskedAndReconstructedPieces() throws {
        let prompt = try #require(PositionRecallReconstructionPromptFactory.makePrompt(
            snapshot: sampleSnapshot(),
            difficulty: .beginner,
            orientation: .black,
            randomizer: SeededChallengeRandomizer(seed: 7)
        ))
        let answer = PositionRecallReconstructionAnswer(pieces: prompt.expectedPieces)
        let summary = PositionRecallReconstructionFeedback.accessibilityDescription(prompt: prompt, answer: answer, progress: "Prompt 1 of 5")

        #expect(summary.contains("Position recall"))
        #expect(summary.contains("Orientation: black"))
        #expect(summary.contains("Visible pieces"))
        #expect(summary.contains("Masked squares"))
        #expect(summary.contains("Reconstructed pieces"))
        #expect(summary.contains("Prompt 1 of 5"))
    }

    @Test
    func thousandPromptGenerationIsBoundedAndValid() throws {
        let generator = PositionRecallReconstructionPromptGenerator(
            snapshots: try [sampleSnapshot()],
            difficulty: .advanced,
            orientation: .alternating,
            randomizer: SeededChallengeRandomizer(seed: 99),
            maximumAttempts: 32
        )

        for _ in 0..<1_000 {
            let prompt = try #require(generator.next())
            #expect(prompt.snapshot.isValid)
            #expect(!prompt.maskedSquares.isEmpty)
            #expect(prompt.maskedSquares.isSubset(of: prompt.snapshot.occupiedSquares))
        }
    }
}
