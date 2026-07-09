import Foundation
import Testing
@testable import ChessNotation

struct PieceMovementSessionTests {
    @Test
    func beginnerGenerationUsesEmptyBoardsAndValidDestinations() throws {
        let configuration = PieceMovementConfiguration(
            pieces: Set(TrainingPiece.allCases),
            difficulty: .beginner,
            orientation: .white
        )
        let generator = PieceMovementPromptGenerator(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 12)
        )

        for _ in 0..<100 {
            let prompt = try #require(generator.next())
            #expect(prompt.occupancy.friendly.isEmpty)
            #expect(prompt.occupancy.enemy.isEmpty)
            #expect(!prompt.expectedDestinations.isEmpty)
        }
    }

    @Test
    func advancedGenerationAddsDisjointBlockersAndCaptures() throws {
        let configuration = PieceMovementConfiguration(
            pieces: [.rook, .bishop, .queen, .knight],
            difficulty: .advanced,
            orientation: .black
        )
        let generator = PieceMovementPromptGenerator(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 31)
        )

        for _ in 0..<50 {
            let prompt = try #require(generator.next())
            #expect(prompt.occupancy.friendly.count == 3)
            #expect(prompt.occupancy.enemy.count == 2)
            #expect(prompt.occupancy.isValid)
            #expect(!prompt.occupancy.friendly.contains(prompt.source))
            #expect(!prompt.occupancy.enemy.contains(prompt.source))
            #expect(!prompt.expectedDestinations.isEmpty)
        }
    }

    @Test
    func alternatingOrientationChangesWithEachGeneratedPrompt() throws {
        let configuration = PieceMovementConfiguration(
            pieces: [.king],
            difficulty: .beginner,
            orientation: .alternating
        )
        let generator = PieceMovementPromptGenerator(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 5)
        )

        #expect(try #require(generator.next()).orientation == .white)
        #expect(try #require(generator.next()).orientation == .black)
        #expect(try #require(generator.next()).orientation == .white)
    }

    @Test
    func seededGenerationIsDeterministic() throws {
        let configuration = PieceMovementConfiguration(
            pieces: [.king, .queen, .rook, .bishop, .knight, .pawn],
            difficulty: .intermediate,
            orientation: .alternating,
            allowPawnDoubleStep: true
        )
        let first = PieceMovementPromptGenerator(configuration: configuration, randomizer: SeededChallengeRandomizer(seed: 77))
        let second = PieceMovementPromptGenerator(configuration: configuration, randomizer: SeededChallengeRandomizer(seed: 77))

        for _ in 0..<40 {
            #expect(try #require(first.next()) == #require(second.next()))
        }
    }

    @Test
    func exactSubmissionScoresAndBuildsStreak() throws {
        let clock = TestMonotonicClock(now: 10)
        let configuration = PieceMovementConfiguration(
            pieces: [.knight],
            difficulty: .beginner,
            orientation: .white,
            promptLimit: 2
        )
        let generator = PieceMovementPromptGenerator(configuration: configuration, randomizer: SeededChallengeRandomizer(seed: 6))
        let session = try #require(PieceMovementSession(configuration: configuration, generator: generator, clock: clock))

        for square in session.currentPrompt.expectedDestinations { session.toggle(square) }
        clock.advance(by: 2)
        let first = try #require(session.submit(at: clock.now))
        #expect(first.submission.isExact)
        #expect(first.scoreAwarded == 100)
        #expect(first.streak == 1)

        #expect(session.advance())
        for square in session.currentPrompt.expectedDestinations { session.toggle(square) }
        clock.advance(by: 1)
        let second = try #require(session.submit(at: clock.now))
        #expect(second.scoreAwarded == 110)
        #expect(second.streak == 2)
        #expect(session.result().bestStreak == 2)
    }

    @Test
    func partialSubmissionRecordsMissingAndExtraSelections() throws {
        let clock = TestMonotonicClock()
        let configuration = PieceMovementConfiguration(pieces: [.rook], difficulty: .beginner, orientation: .white)
        let generator = PieceMovementPromptGenerator(configuration: configuration, randomizer: SeededChallengeRandomizer(seed: 10))
        let session = try #require(PieceMovementSession(configuration: configuration, generator: generator, clock: clock))
        let oneExpected = try #require(session.currentPrompt.expectedDestinations.first)
        let extra = try #require(SquareRecognitionPromptFactory.allSquares.first { square in
            square != session.currentPrompt.source && !session.currentPrompt.expectedDestinations.contains(square)
        })
        session.toggle(oneExpected)
        session.toggle(extra)

        let evaluation = try #require(session.submit(at: 1))
        #expect(!evaluation.submission.isExact)
        #expect(!evaluation.submission.missing.isEmpty)
        #expect(evaluation.submission.extra == [extra])
        #expect(PieceMovementFeedback.message(for: evaluation.submission).contains("missing"))
        #expect(PieceMovementFeedback.message(for: evaluation.submission).contains("not valid"))

        let result = session.result(reason: .userExited)
        #expect(result.partialCount == 1)
        #expect(result.missingSelectionCount == evaluation.submission.missing.count)
        #expect(result.extraSelectionCount == 1)
        #expect(result.finishReason == .userExited)
    }

    @Test
    func inputLocksAfterSubmitAndAdvanceClearsSelection() throws {
        let configuration = PieceMovementConfiguration(pieces: [.king], difficulty: .beginner, orientation: .white, promptLimit: 2)
        let generator = PieceMovementPromptGenerator(configuration: configuration, randomizer: SeededChallengeRandomizer(seed: 2))
        let session = try #require(PieceMovementSession(configuration: configuration, generator: generator, clock: TestMonotonicClock()))
        let selected = try #require(session.currentPrompt.expectedDestinations.first)
        session.toggle(selected)
        _ = session.submit(at: 1)
        session.toggle(try #require(ChessSquare("a1")))
        #expect(session.selected == [selected])

        #expect(session.advance())
        #expect(session.selected.isEmpty)
        #expect(!session.inputLocked)
    }

    @Test
    func thousandPromptGenerationIsBoundedAndValid() throws {
        let configuration = PieceMovementConfiguration(
            pieces: Set(TrainingPiece.allCases),
            difficulty: .advanced,
            orientation: .alternating,
            promptLimit: 1_000,
            allowPawnDoubleStep: true
        )
        let generator = PieceMovementPromptGenerator(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 999),
            maximumAttempts: 64
        )

        for _ in 0..<1_000 {
            let prompt = try #require(generator.next())
            #expect(prompt.occupancy.isValid)
            #expect(!prompt.expectedDestinations.isEmpty)
        }
    }
}
