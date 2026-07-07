import Foundation
import Testing
@testable import ChessNotation

struct SquareRecognitionIntegrationTests {
    @Test
    func legacyResultMigratesToFindSquareDefaults() {
        let legacy = SquareRecognitionResult(
            initialTime: 10,
            variant: .bonus,
            answers: [
                SquareRecognitionAnswer(target: "e4", selected: "e4", isCorrect: true, latency: 1.5),
                SquareRecognitionAnswer(target: "d5", selected: "d4", isCorrect: false, latency: 2.5)
            ]
        )

        let migrated = SquareRecognitionLegacyCompatibility.migrate(legacy)

        #expect(migrated.configuration.drill == .findSquare)
        #expect(migrated.configuration.orientation == .white)
        #expect(migrated.configuration.zone == .all)
        #expect(migrated.configuration.difficulty == .beginner)
        #expect(migrated.totalPrompts == 2)
        #expect(migrated.correctPrompts == 1)
        #expect(migrated.averageLatency == 2)
    }

    @Test
    func accessibilitySummaryIncludesTaskOrientationProgressAndFeedback() throws {
        let square = try #require(ChessSquare("e4"))
        let configuration = SquareRecognitionDrillConfiguration(
            drill: .squareColor,
            orientation: .black,
            zone: .all,
            difficulty: .beginner,
            variant: .bonus
        )
        let presentation = SquareRecognitionPresentation.make(
            configuration: configuration,
            prompt: SquareRecognitionPrompt(target: square, orientation: .black, route: []),
            completed: 2,
            total: 10,
            feedback: "Correct"
        )

        #expect(presentation.accessibilitySummary.contains("light or dark"))
        #expect(presentation.accessibilitySummary.contains("Black orientation"))
        #expect(presentation.accessibilitySummary.contains("Prompt 3 of 10"))
        #expect(presentation.accessibilitySummary.contains("Correct"))
    }

    @Test
    func accessibilityFeedbackDoesNotDependOnColorAlone() throws {
        let square = try #require(ChessSquare("a1"))
        let configuration = SquareRecognitionDrillConfiguration(
            drill: .findSquare,
            orientation: .white,
            zone: .all,
            difficulty: .beginner,
            variant: .strict
        )
        let presentation = SquareRecognitionPresentation.make(
            configuration: configuration,
            prompt: SquareRecognitionPrompt(target: square, orientation: .white, route: []),
            completed: 0,
            total: nil,
            feedback: "Incorrect"
        )

        #expect(presentation.feedback == "Incorrect")
        #expect(presentation.accessibilitySummary.contains("Incorrect"))
    }

    @Test
    func promptChangesReuseBoardResources() throws {
        let first = try #require(ChessSquare("a1"))
        let second = try #require(ChessSquare("h8"))
        let configuration = SquareRecognitionDrillConfiguration(
            drill: .findSquare,
            orientation: .white,
            zone: .all,
            difficulty: .beginner,
            variant: .bonus
        )
        let clock = TestMonotonicClock()
        let domainSession = SquareRecognitionSession(
            configuration: configuration,
            prompt: SquareRecognitionPrompt(target: first, orientation: .white, route: []),
            clock: clock
        )
        var integrated = SquareRecognitionIntegratedSession(session: domainSession)
        let resourceID = integrated.boardResources.resourceID

        for _ in 0..<1_000 {
            integrated.advance(to: SquareRecognitionPrompt(target: second, orientation: .white, route: []))
            integrated.advance(to: SquareRecognitionPrompt(target: first, orientation: .white, route: []))
        }

        #expect(integrated.boardResources.resourceID == resourceID)
        #expect(integrated.boardResources.promptUpdateCount == 2_000)
    }
}
