import Foundation
import Testing
@testable import ChessNotation

struct SquareRecognitionSessionTests {
    @Test
    func blackOrientationMappingRoundTripsEverySquare() throws {
        for index in 0..<64 {
            let square = try #require(SquareBoardMapping.square(forDisplayIndex: index, orientation: .black))
            #expect(SquareBoardMapping.displayIndex(for: square, orientation: .black) == index)
        }
    }

    @Test
    func nameSquareAcceptsCoordinateAndRejectsAnother() throws {
        let clock = TestMonotonicClock(now: 10)
        let target = try #require(ChessSquare("e4"))
        let prompt = SquareRecognitionPrompt(target: target, orientation: .white, route: [])
        let configuration = SquareRecognitionDrillConfiguration(drill: .nameSquare, orientation: .white, zone: .all, difficulty: .beginner, variant: .bonus)
        let correct = SquareRecognitionSession(configuration: configuration, prompt: prompt, clock: clock)
        let incorrect = SquareRecognitionSession(configuration: configuration, prompt: prompt, clock: clock)

        #expect(correct.submit(.coordinate("e4"), at: 11)?.isCorrect == true)
        #expect(incorrect.submit(.coordinate("d4"), at: 11)?.isCorrect == false)
    }

    @Test
    func squareColorUsesBoardGeometry() throws {
        let clock = TestMonotonicClock()
        let a1 = try #require(ChessSquare("a1"))
        let b1 = try #require(ChessSquare("b1"))
        let configuration = SquareRecognitionDrillConfiguration(drill: .squareColor, orientation: .white, zone: .all, difficulty: .beginner, variant: .bonus)

        let first = SquareRecognitionSession(configuration: configuration, prompt: SquareRecognitionPrompt(target: a1, orientation: .white, route: []), clock: clock)
        let second = SquareRecognitionSession(configuration: configuration, prompt: SquareRecognitionPrompt(target: b1, orientation: .white, route: []), clock: clock)

        #expect(first.submit(.color(.dark), at: 1)?.isCorrect == true)
        #expect(second.submit(.color(.light), at: 1)?.isCorrect == true)
    }

    @Test
    func routeRequiresExactOrder() throws {
        let clock = TestMonotonicClock()
        let a1 = try #require(ChessSquare("a1"))
        let b2 = try #require(ChessSquare("b2"))
        let c3 = try #require(ChessSquare("c3"))
        let prompt = SquareRecognitionPrompt(target: c3, orientation: .white, route: [a1, b2, c3])
        let configuration = SquareRecognitionDrillConfiguration(drill: .route, orientation: .white, zone: .all, difficulty: .intermediate, variant: .bonus)
        let correct = SquareRecognitionSession(configuration: configuration, prompt: prompt, clock: clock)
        let wrong = SquareRecognitionSession(configuration: configuration, prompt: prompt, clock: clock)

        #expect(correct.submit(.route([a1, b2, c3]), at: 2)?.isCorrect == true)
        #expect(wrong.submit(.route([b2, a1, c3]), at: 2)?.isCorrect == false)
    }

    @Test
    func feedbackLockPreventsDuplicateScoring() throws {
        let clock = TestMonotonicClock(now: 5)
        let target = try #require(ChessSquare("e4"))
        let configuration = SquareRecognitionDrillConfiguration(drill: .findSquare, orientation: .white, zone: .all, difficulty: .beginner, variant: .strict)
        let session = SquareRecognitionSession(configuration: configuration, prompt: SquareRecognitionPrompt(target: target, orientation: .white, route: []), clock: clock)

        #expect(session.submit(.square(target), at: 6) != nil)
        #expect(session.submit(.square(target), at: 6.1) == nil)
        #expect(session.totalPrompts == 1)
        #expect(session.score == 100)
    }

    @Test
    func scoringUsesCapturedTimestampNotFeedbackDelay() throws {
        let target = try #require(ChessSquare("e4"))
        let configuration = SquareRecognitionDrillConfiguration(drill: .findSquare, orientation: .white, zone: .all, difficulty: .beginner, variant: .bonus)
        let firstClock = TestMonotonicClock(now: 10)
        let secondClock = TestMonotonicClock(now: 10)
        let first = SquareRecognitionSession(configuration: configuration, prompt: SquareRecognitionPrompt(target: target, orientation: .white, route: []), clock: firstClock)
        let second = SquareRecognitionSession(configuration: configuration, prompt: SquareRecognitionPrompt(target: target, orientation: .white, route: []), clock: secondClock)

        _ = first.submit(.square(target), at: 12)
        secondClock.advance(by: 20)
        _ = second.submit(.square(target), at: 12)

        #expect(first.result.averageLatency == second.result.averageLatency)
        #expect(first.result.score == second.result.score)
    }

    @Test
    func invalidRestoredZoneFallsBackToAllSquares() throws {
        let target = try #require(ChessSquare("e4"))
        let configuration = SquareRecognitionDrillConfiguration(drill: .findSquare, orientation: .white, zone: .file("z"), difficulty: .beginner, variant: .bonus)
        let session = SquareRecognitionSession(configuration: configuration, prompt: SquareRecognitionPrompt(target: target, orientation: .white, route: []), clock: TestMonotonicClock())

        #expect(session.configuration.zone == .all)
    }

    @Test
    func resultRoundTripsSessionMetrics() throws {
        let target = try #require(ChessSquare("e4"))
        let configuration = SquareRecognitionDrillConfiguration(drill: .findSquare, orientation: .black, zone: .center, difficulty: .advanced, variant: .strict)
        let session = SquareRecognitionSession(configuration: configuration, prompt: SquareRecognitionPrompt(target: target, orientation: .black, route: []), clock: TestMonotonicClock())
        _ = session.submit(.square(target), at: 1.5)

        let data = try JSONEncoder().encode(session.result)
        #expect(try JSONDecoder().decode(SquareRecognitionDrillResult.self, from: data) == session.result)
    }
}
