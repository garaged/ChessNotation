import Foundation
import Testing
@testable import ChessNotation

struct PositionRecallReconstructionSessionTests {
    private func snapshot() throws -> PositionRecallSnapshot {
        PositionRecallSnapshot(pieces: [
            PositionRecallPlacedPiece(square: try #require(ChessSquare("e4")), piece: PositionRecallPiece(piece: .king, side: .white)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("a8")), piece: PositionRecallPiece(piece: .queen, side: .black)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("c3")), piece: PositionRecallPiece(piece: .knight, side: .white)),
            PositionRecallPlacedPiece(square: try #require(ChessSquare("h1")), piece: PositionRecallPiece(piece: .rook, side: .black))
        ])
    }

    private func makeSession(
        difficulty: TrainingDifficulty = .beginner,
        promptLimit: Int = 2,
        clock: TestMonotonicClock = TestMonotonicClock(now: 10)
    ) throws -> PositionRecallReconstructionSession {
        let configuration = PositionRecallReconstructionConfiguration(
            difficulty: difficulty,
            orientation: .alternating,
            promptLimit: promptLimit,
            studyDuration: 3
        )
        let generator = PositionRecallReconstructionPromptGenerator(
            snapshots: try [snapshot()],
            difficulty: difficulty,
            orientation: .alternating,
            randomizer: SeededChallengeRandomizer(seed: 8)
        )
        return try #require(PositionRecallReconstructionSession(
            configuration: configuration,
            generator: generator,
            clock: clock
        ))
    }

    @Test
    func studyDeadlineTransitionsOnceAndHidesAnswers() throws {
        let clock = TestMonotonicClock(now: 100)
        let session = try makeSession(clock: clock)

        session.refresh()
        #expect(session.phase == .studying)
        #expect(PositionRecallAccessibility.exposesPieces(in: session.phase))

        clock.advance(by: 3)
        session.refresh()
        session.refresh()

        #expect(session.phase == .answering)
        #expect(session.transitionCount == 1)
        #expect(!PositionRecallAccessibility.exposesPieces(in: session.phase))
    }

    @Test
    func exactReconstructionScoresAndPersistsMetrics() throws {
        let clock = TestMonotonicClock(now: 20)
        let session = try makeSession(clock: clock)
        clock.advance(by: 3)
        session.refresh()
        for piece in session.currentPrompt.expectedPieces {
            session.place(piece.piece, at: piece.square)
        }
        clock.advance(by: 2)

        let submission = try #require(session.submit(at: clock.now))

        #expect(submission.evaluation.isExact)
        #expect(submission.scoreAwarded == 100)
        #expect(submission.latency == 2)
        #expect(session.phase == .finished)
        let result = session.result()
        #expect(result.exactCount == 1)
        #expect(result.promptCount == 1)
        #expect(result.averageLatency == 2)
        #expect(result.bestStreak == 1)
    }

    @Test
    func partialReconstructionRecordsMistakeCategories() throws {
        let clock = TestMonotonicClock(now: 30)
        let session = try makeSession(clock: clock)
        clock.advance(by: 3)
        session.refresh()
        let expected = try #require(session.currentPrompt.expectedPieces.first)
        let wrongPiece = PositionRecallPiece(piece: expected.piece.piece == .rook ? .bishop : .rook, side: expected.piece.side)
        let extraSquare = try #require(SquareRecognitionPromptFactory.allSquares.first { square in
            square != expected.square && !session.currentPrompt.maskedSquares.contains(square)
        })
        session.place(wrongPiece, at: expected.square)
        session.place(PositionRecallPiece(piece: .pawn, side: .white), at: extraSquare)

        let submission = try #require(session.submit(at: clock.now + 1))

        #expect(!submission.evaluation.isExact)
        #expect(submission.evaluation.wrongPieceSquares == [expected.square])
        #expect(!submission.evaluation.missing.isEmpty)
        #expect(!submission.evaluation.extra.isEmpty)
        #expect(PositionRecallReconstructionFeedback.message(for: submission.evaluation).contains("piece types"))
        let result = session.result(reason: .userExited)
        #expect(result.partialCount == 1)
        #expect(result.wrongPieceCount == 1)
        #expect(result.extraCount == 2)
        #expect(result.finishReason == .userExited)
    }

    @Test
    func advanceStartsNextStudyAndClearsAnswer() throws {
        let clock = TestMonotonicClock(now: 40)
        let session = try makeSession(promptLimit: 2, clock: clock)
        clock.advance(by: 3)
        session.refresh()
        for piece in session.currentPrompt.expectedPieces {
            session.place(piece.piece, at: piece.square)
        }
        _ = session.submit(at: clock.now)

        #expect(session.advance())
        #expect(session.phase == .studying)
        #expect(session.answer.pieces.isEmpty)
        #expect(session.promptCount == 1)
    }

    @Test
    func notationConceptResultPreservesRecallMetrics() throws {
        let clock = TestMonotonicClock(now: 50)
        let session = try makeSession(clock: clock)
        clock.advance(by: 3)
        session.refresh()
        _ = session.submit(at: clock.now + 4)

        let result = session.notationConceptResult(reason: .completed)

        #expect(result.kind == .positionRecall)
        #expect(result.promptCount == 1)
        #expect(result.studyDuration == 3)
        #expect(result.averageLatency == 4)
        #expect(result.orientation == .alternating)
        #expect(result.mistakeCategories.keys.contains("missing"))
    }

    @Test
    func reconstructionHistoryStoreRoundTripsResults() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("position-recall-history.json")
        let store = PositionRecallReconstructionHistoryStore(fileURL: url)
        let result = PositionRecallSessionResult(
            difficulty: .advanced,
            orientation: .black,
            promptCount: 2,
            exactCount: 1,
            partialCount: 1,
            missingCount: 2,
            extraCount: 1,
            wrongPieceCount: 1,
            wrongSideCount: 0,
            averageLatency: 1.75,
            bestStreak: 1,
            finishReason: .completed
        )

        try store.saveResult(result)
        #expect(try store.loadResults() == [result])
    }
}
