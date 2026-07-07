import Foundation
import Testing
@testable import ChessNotation

struct PieceMovementGameTests {
    @Test
    func emptyBoardGeometryMatchesRepresentativeSquares() throws {
        let d4 = try #require(ChessSquare("d4"))
        let a1 = try #require(ChessSquare("a1"))
        let empty = PieceMovementOccupancy()

        #expect(PieceMovementGeometry.destinations(piece: .king, side: .white, source: d4, occupancy: empty).count == 8)
        #expect(PieceMovementGeometry.destinations(piece: .knight, side: .white, source: d4, occupancy: empty).count == 8)
        #expect(PieceMovementGeometry.destinations(piece: .rook, side: .white, source: d4, occupancy: empty).count == 14)
        #expect(PieceMovementGeometry.destinations(piece: .bishop, side: .white, source: d4, occupancy: empty).count == 13)
        #expect(PieceMovementGeometry.destinations(piece: .queen, side: .white, source: d4, occupancy: empty).count == 27)
        #expect(PieceMovementGeometry.destinations(piece: .king, side: .white, source: a1, occupancy: empty).count == 3)
        #expect(PieceMovementGeometry.destinations(piece: .knight, side: .white, source: a1, occupancy: empty).count == 2)
    }

    @Test
    func friendlySlidingBlockerStopsRayAndIsExcluded() throws {
        let source = try #require(ChessSquare("d4"))
        let blocker = try #require(ChessSquare("d6"))
        let beyond = try #require(ChessSquare("d7"))
        let destinations = PieceMovementGeometry.destinations(
            piece: .rook,
            side: .white,
            source: source,
            occupancy: PieceMovementOccupancy(friendly: [blocker])
        )

        #expect(!destinations.contains(blocker))
        #expect(!destinations.contains(beyond))
        #expect(destinations.contains(try #require(ChessSquare("d5"))))
    }

    @Test
    func enemySlidingBlockerIsCaptureAndStopsRay() throws {
        let source = try #require(ChessSquare("d4"))
        let enemy = try #require(ChessSquare("d6"))
        let beyond = try #require(ChessSquare("d7"))
        let destinations = PieceMovementGeometry.destinations(
            piece: .rook,
            side: .white,
            source: source,
            occupancy: PieceMovementOccupancy(enemy: [enemy])
        )

        #expect(destinations.contains(enemy))
        #expect(!destinations.contains(beyond))
    }

    @Test
    func jumpingPiecesExcludeFriendlyAndIncludeEnemySquares() throws {
        let source = try #require(ChessSquare("d4"))
        let friendly = try #require(ChessSquare("f5"))
        let enemy = try #require(ChessSquare("e6"))
        let occupancy = PieceMovementOccupancy(friendly: [friendly], enemy: [enemy])

        let knight = PieceMovementGeometry.destinations(piece: .knight, side: .white, source: source, occupancy: occupancy)

        #expect(!knight.contains(friendly))
        #expect(knight.contains(enemy))
    }

    @Test
    func whiteAndBlackPawnDirectionsMirror() throws {
        let whiteSource = try #require(ChessSquare("d4"))
        let blackSource = try #require(ChessSquare("d5"))
        let whiteEnemy = try #require(ChessSquare("e5"))
        let blackEnemy = try #require(ChessSquare("e4"))

        let white = PieceMovementGeometry.destinations(
            piece: .pawn,
            side: .white,
            source: whiteSource,
            occupancy: PieceMovementOccupancy(enemy: [whiteEnemy])
        )
        let black = PieceMovementGeometry.destinations(
            piece: .pawn,
            side: .black,
            source: blackSource,
            occupancy: PieceMovementOccupancy(enemy: [blackEnemy])
        )

        #expect(white.contains(try #require(ChessSquare("d5"))))
        #expect(white.contains(whiteEnemy))
        #expect(black.contains(try #require(ChessSquare("d4"))))
        #expect(black.contains(blackEnemy))
    }

    @Test
    func occupiedPawnForwardSquareBlocksSingleAndDoubleMoves() throws {
        let source = try #require(ChessSquare("d2"))
        let blocker = try #require(ChessSquare("d3"))
        let destinations = PieceMovementGeometry.destinations(
            piece: .pawn,
            side: .white,
            source: source,
            occupancy: PieceMovementOccupancy(friendly: [blocker]),
            allowPawnDoubleStep: true
        )

        #expect(!destinations.contains(blocker))
        #expect(!destinations.contains(try #require(ChessSquare("d4"))))
    }

    @Test
    func promptFactoryRejectsOverlapSourceAndZeroMoveStates() throws {
        let source = try #require(ChessSquare("a1"))
        let invalid = PieceMovementPromptFactory.makePrompt(
            piece: .king,
            side: .white,
            source: source,
            occupancy: PieceMovementOccupancy(friendly: [source]),
            orientation: .white,
            difficulty: .beginner
        )

        #expect(invalid == nil)
    }

    @Test
    func exactSubmissionIgnoresSelectionOrder() throws {
        let expected: Set<ChessSquare> = [
            try #require(ChessSquare("a1")),
            try #require(ChessSquare("b2")),
            try #require(ChessSquare("c3"))
        ]
        let selected: Set<ChessSquare> = [
            try #require(ChessSquare("c3")),
            try #require(ChessSquare("a1")),
            try #require(ChessSquare("b2"))
        ]

        let submission = PieceMovementSubmission(selected: selected, expected: expected)

        #expect(submission.isExact)
        #expect(submission.missing.isEmpty)
        #expect(submission.extra.isEmpty)
    }

    @Test
    func missingAndExtraSelectionsAreRecordedSeparately() throws {
        let expected: Set<ChessSquare> = [try #require(ChessSquare("a1")), try #require(ChessSquare("b2"))]
        let selected: Set<ChessSquare> = [try #require(ChessSquare("a1")), try #require(ChessSquare("c3"))]

        let submission = PieceMovementSubmission(selected: selected, expected: expected)

        #expect(submission.missing == [try #require(ChessSquare("b2"))])
        #expect(submission.extra == [try #require(ChessSquare("c3"))])
        #expect(PieceMovementFeedback.message(for: submission).contains("missing"))
    }

    @Test
    func resultRoundTripsMovementMetrics() throws {
        let result = PieceMovementSessionResult(
            pieceTypes: [.rook, .knight],
            difficulty: .intermediate,
            orientation: .black,
            promptCount: 10,
            exactCount: 7,
            partialCount: 3,
            missingSelectionCount: 4,
            extraSelectionCount: 2,
            averageLatency: 1.25,
            bestStreak: 5,
            finishReason: .completed
        )

        let data = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(PieceMovementSessionResult.self, from: data)

        #expect(decoded == result)
    }

    @Test
    func accessibilityDescriptionIncludesPieceOccupancySelectionAndProgress() throws {
        let source = try #require(ChessSquare("d4"))
        let friendly = try #require(ChessSquare("d5"))
        let enemy = try #require(ChessSquare("e5"))
        let selected = try #require(ChessSquare("c4"))

        let description = PieceMovementFeedback.accessibilityDescription(
            piece: .bishop,
            side: .black,
            source: source,
            occupancy: PieceMovementOccupancy(friendly: [friendly], enemy: [enemy]),
            selected: [selected],
            progress: "Prompt 2 of 10"
        )

        #expect(description.contains("Black bishop on d4"))
        #expect(description.contains("d5"))
        #expect(description.contains("e5"))
        #expect(description.contains("c4"))
        #expect(description.contains("Prompt 2 of 10"))
    }

    @Test
    func oneThousandRepresentativePromptCalculationsRemainBounded() throws {
        let sources = try ["a1", "d4", "h8", "b7"].map { try #require(ChessSquare($0)) }

        for index in 0..<1_000 {
            let source = sources[index % sources.count]
            let destinations = PieceMovementGeometry.destinations(
                piece: TrainingPiece.allCases[index % TrainingPiece.allCases.count],
                side: index.isMultiple(of: 2) ? .white : .black,
                source: source,
                occupancy: PieceMovementOccupancy(),
                allowPawnDoubleStep: true
            )
            #expect(destinations.count <= 27)
        }
    }
}
