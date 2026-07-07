import Foundation
import Testing
@testable import ChessNotation

struct NotationConceptGameTests {
    @Test
    func sanBuilderParsesAndReassemblesRepresentativeMoves() throws {
        let moves = ["e4", "Nf3", "Raxd1+", "exd8=Q#", "O-O", "O-O-O"]

        for move in moves {
            let challenge = try #require(SANBuilderParser.parse(move))
            #expect(challenge.isCorrect(challenge.components))
        }
    }

    @Test
    func sanBuilderReportsDisambiguationMistake() throws {
        let challenge = try #require(SANBuilderParser.parse("Raxd1+"))
        let wrong = challenge.components.filter { $0.kind != .disambiguation }

        #expect(!challenge.isCorrect(wrong))
        #expect(challenge.firstMistake(in: wrong) == .disambiguation)
    }

    @Test
    func invalidSANCannotCreateChallenge() {
        #expect(SANBuilderParser.parse("") == nil)
        #expect(SANBuilderParser.parse("invalid") == nil)
    }

    @Test
    func locatePieceReturnsUniqueSquare() throws {
        let e4 = try #require(ChessSquare("e4"))
        let prompt = PositionRecallPrompt(
            items: [PositionRecallItem(name: "white queen", square: e4)],
            question: .locatePiece,
            requestedName: "white queen",
            requestedSquare: nil,
            subset: [],
            orientation: .white,
            studyDuration: 3
        )

        #expect(prompt.expectedSquares == [e4])
    }

    @Test
    func squareOccupantHandlesOccupiedAndEmptySquares() throws {
        let e4 = try #require(ChessSquare("e4"))
        let d5 = try #require(ChessSquare("d5"))
        let occupied = PositionRecallPrompt(
            items: [PositionRecallItem(name: "black pawn", square: e4)],
            question: .squareOccupant,
            requestedName: nil,
            requestedSquare: e4,
            subset: [],
            orientation: .black,
            studyDuration: 3
        )
        let empty = PositionRecallPrompt(
            items: occupied.items,
            question: .squareOccupant,
            requestedName: nil,
            requestedSquare: d5,
            subset: [],
            orientation: .black,
            studyDuration: 3
        )

        #expect(occupied.expectedSquares == [e4])
        #expect(empty.expectedSquares.isEmpty)
    }

    @Test
    func occupiedSubsetUsesExactSetIndependentOfOrder() throws {
        let a1 = try #require(ChessSquare("a1"))
        let b2 = try #require(ChessSquare("b2"))
        let c3 = try #require(ChessSquare("c3"))
        let prompt = PositionRecallPrompt(
            items: [
                PositionRecallItem(name: "rook", square: a1),
                PositionRecallItem(name: "bishop", square: b2),
                PositionRecallItem(name: "knight", square: c3)
            ],
            question: .occupiedSubset,
            requestedName: nil,
            requestedSquare: nil,
            subset: [a1, c3],
            orientation: .white,
            studyDuration: 5
        )

        #expect(prompt.expectedSquares == [a1, c3])
    }

    @Test
    func modelsRoundTripThroughCodable() throws {
        let square = try #require(ChessSquare("e4"))
        let prompt = PositionRecallPrompt(
            items: [PositionRecallItem(name: "queen", square: square)],
            question: .locatePiece,
            requestedName: "queen",
            requestedSquare: nil,
            subset: [],
            orientation: .black,
            studyDuration: 4
        )

        let data = try JSONEncoder().encode(prompt)
        let decoded = try JSONDecoder().decode(PositionRecallPrompt.self, from: data)

        #expect(decoded == prompt)
    }
}
