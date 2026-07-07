import Foundation
import Testing
@testable import ChessNotation

struct NotationConceptSessionTests {
    @Test
    func studyDeadlineTransitionsOnce() throws {
        let clock = TestMonotonicClock(now: 100)
        let square = try #require(ChessSquare("d4"))
        let prompt = PositionRecallPrompt(items: [PositionRecallItem(name: "queen", square: square)], question: .locatePiece, requestedName: "queen", requestedSquare: nil, subset: [], orientation: .white, studyDuration: 3)
        let session = PositionRecallSession(prompt: prompt, clock: clock)

        session.refresh()
        clock.advance(by: 3)
        session.refresh()
        session.refresh()

        #expect(session.phase == .answering)
        #expect(session.transitionCount == 1)
    }

    @Test
    func answerTracksMissingAndExtra() throws {
        let a1 = try #require(ChessSquare("a1"))
        let b2 = try #require(ChessSquare("b2"))
        let c3 = try #require(ChessSquare("c3"))
        let answer = PositionRecallAnswer(selected: [a1, c3], expected: [a1, b2])

        #expect(!answer.isCorrect)
        #expect(answer.missing == [b2])
        #expect(answer.extra == [c3])
    }

    @Test
    func answeringAccessibilityOmitsPieces() {
        #expect(PositionRecallAccessibility.exposesPieces(in: .studying))
        #expect(!PositionRecallAccessibility.exposesPieces(in: .answering))
    }

    @Test
    func resultRoundTrips() throws {
        let result = NotationConceptResult(kind: .positionRecall, difficulty: .advanced, promptCount: 12, correctCount: 9, firstTryCount: 7, mistakeCategories: ["subset": 3], averageLatency: 1.4, studyDuration: 5, orientation: .black, finishReason: .completed)
        let data = try JSONEncoder().encode(result)
        #expect(try JSONDecoder().decode(NotationConceptResult.self, from: data) == result)
    }
}
