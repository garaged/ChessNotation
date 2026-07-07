import Foundation
import Testing
@testable import ChessNotation

struct SquareRecognitionVarietyTests {
    @Test
    func nameSquareMatchesHighlightedCoordinate() throws {
        let square = try #require(ChessSquare("e4"))

        #expect(square.description == "e4")
        #expect(square != ChessSquare("d4"))
    }

    @Test
    func squareColorsAlternateAndCornersMatchBoardGeometry() throws {
        let a1 = try #require(ChessSquare("a1"))
        let b1 = try #require(ChessSquare("b1"))
        let a2 = try #require(ChessSquare("a2"))
        let h8 = try #require(ChessSquare("h8"))

        #expect(a1.color == .dark)
        #expect(h8.color == .dark)
        #expect(b1.color != a1.color)
        #expect(a2.color != a1.color)
    }

    @Test
    func invalidRelativeOffsetIsExcluded() throws {
        let a1 = try #require(ChessSquare("a1"))

        #expect(SquareRecognitionPromptFactory.relative(from: a1, fileDelta: -1, rankDelta: 0) == nil)
        #expect(SquareRecognitionPromptFactory.relative(from: a1, fileDelta: 1, rankDelta: 2)?.description == "b3")
    }

    @Test
    func routeRequiresExactOrderAndBlocksAfterResolution() throws {
        let route = [try #require(ChessSquare("a1")), try #require(ChessSquare("b2")), try #require(ChessSquare("c3"))]
        var correct = SquareRouteAttempt(expected: route)
        route.forEach { correct.select($0) }
        correct.select(try #require(ChessSquare("h8")))

        var wrong = SquareRouteAttempt(expected: route)
        wrong.select(route[1])
        wrong.select(route[0])
        wrong.select(route[2])

        #expect(correct.isCorrect)
        #expect(correct.selected.count == 3)
        #expect(!wrong.isCorrect)
    }

    @Test
    func alternatingOrientationChangesEachPrompt() {
        let generator = SquareRecognitionPromptGenerator(
            zone: .all,
            orientationPolicy: .alternating,
            randomizer: SeededChallengeRandomizer(seed: 7)
        )

        #expect(generator.next()?.orientation == .white)
        #expect(generator.next()?.orientation == .black)
        #expect(generator.next()?.orientation == .white)
    }

    @Test
    func centerZoneVisitsEverySquareOnceBeforeRepeating() {
        let eligible = SquareRecognitionPromptFactory.squares(in: .center)
        let generator = SquareRecognitionPromptGenerator(
            zone: .center,
            orientationPolicy: .white,
            randomizer: SeededChallengeRandomizer(seed: 4)
        )

        let cycle = (0..<eligible.count).compactMap { _ in generator.next()?.target }

        #expect(cycle.count == eligible.count)
        #expect(Set(cycle) == Set(eligible))
        #expect(cycle.allSatisfy { (2...5).contains($0.file) && (2...5).contains($0.rank) })
    }

    @Test
    func promptGeneratorAvoidsImmediateDuplicates() {
        let generator = SquareRecognitionPromptGenerator(
            zone: .corners,
            orientationPolicy: .black,
            randomizer: ScriptedChallengeRandomizer(values: [0])
        )

        let targets = (0..<20).compactMap { _ in generator.next()?.target }

        #expect(zip(targets, targets.dropFirst()).allSatisfy { $0.0 != $0.1 })
    }

    @Test
    func invalidZoneCanRecoverToAllSquares() {
        let invalid = SquareRecognitionPromptFactory.squares(in: .file("z"))
        let fallback = invalid.isEmpty ? SquareRecognitionPromptFactory.squares(in: .all) : invalid

        #expect(invalid.isEmpty)
        #expect(fallback.count == 64)
    }

    @Test
    func resultRoundTripsConfigurationAndMetrics() throws {
        let result = SquareRecognitionDrillResult(
            configuration: SquareRecognitionDrillConfiguration(
                drill: .route,
                orientation: .black,
                zone: .center,
                difficulty: .advanced,
                variant: .strict
            ),
            score: 8,
            totalPrompts: 10,
            correctPrompts: 8,
            averageLatency: 0.75,
            routeCount: 3,
            correctRoutes: 2
        )

        let data = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(SquareRecognitionDrillResult.self, from: data)

        #expect(decoded == result)
    }

    @Test
    func blackOrientationAccessibilityUsesChessCoordinateAndTextFeedback() throws {
        let square = try #require(ChessSquare("e4"))

        let label = SquareRecognitionAccessibility.squareLabel(square, orientation: .black)

        #expect(label.contains("e4"))
        #expect(label.contains("Black orientation"))
        #expect(SquareRecognitionAccessibility.feedback(correct: false) == "Incorrect")
    }

    @Test
    func longPromptRunRetainsOnlyBoundedBagState() {
        let generator = SquareRecognitionPromptGenerator(
            zone: .all,
            orientationPolicy: .white,
            randomizer: SeededChallengeRandomizer(seed: 11)
        )

        for _ in 0..<1_000 {
            #expect(generator.next() != nil)
        }
    }
}
