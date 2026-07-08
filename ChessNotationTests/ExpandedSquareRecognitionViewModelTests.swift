import Foundation
import Testing
@testable import ChessNotation

struct ExpandedSquareRecognitionViewModelTests {
    @Test
    func nameSquareSubmissionUsesCoordinateEntryAndLocksAfterResolution() throws {
        let clock = TestMonotonicClock(now: 10)
        let configuration = SquareRecognitionDrillConfiguration(
            drill: .nameSquare,
            orientation: .white,
            zone: .corners,
            difficulty: .beginner,
            variant: .bonus
        )
        let viewModel = ExpandedSquareRecognitionViewModel(
            configuration: configuration,
            randomizer: ScriptedChallengeRandomizer(values: [0]),
            clock: clock
        )
        viewModel.coordinateEntry = viewModel.prompt.target.description
        clock.advance(by: 1)
        viewModel.submitCoordinate()

        #expect(viewModel.result.totalPrompts == 1)
        #expect(viewModel.result.correctPrompts == 1)
        #expect(viewModel.presentation.feedback == "Correct")
        #expect(viewModel.inputLocked)
    }

    @Test
    func squareColorSubmissionUsesGeometry() {
        let clock = TestMonotonicClock(now: 2)
        let configuration = SquareRecognitionDrillConfiguration(
            drill: .squareColor,
            orientation: .black,
            zone: .all,
            difficulty: .beginner,
            variant: .strict
        )
        let viewModel = ExpandedSquareRecognitionViewModel(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 3),
            clock: clock
        )

        viewModel.submitColor(viewModel.prompt.target.color)

        #expect(viewModel.result.correctPrompts == 1)
        #expect(viewModel.presentation.orientation == "Black orientation")
    }

    @Test
    func routeDifficultyControlsRequiredSelectionCount() {
        let configuration = SquareRecognitionDrillConfiguration(
            drill: .route,
            orientation: .white,
            zone: .center,
            difficulty: .advanced,
            variant: .bonus
        )
        let viewModel = ExpandedSquareRecognitionViewModel(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 9),
            clock: TestMonotonicClock()
        )

        #expect(viewModel.prompt.route.count == 4)
        for square in viewModel.prompt.route {
            viewModel.submitSquare(square)
        }
        #expect(viewModel.result.routeCount == 1)
        #expect(viewModel.result.correctRoutes == 1)
    }

    @Test
    func advanceProducesNewUnlockedPromptAndClearsInput() {
        let configuration = SquareRecognitionDrillConfiguration(
            drill: .nameSquare,
            orientation: .alternating,
            zone: .all,
            difficulty: .intermediate,
            variant: .bonus
        )
        let viewModel = ExpandedSquareRecognitionViewModel(
            configuration: configuration,
            randomizer: SeededChallengeRandomizer(seed: 8),
            clock: TestMonotonicClock()
        )
        let firstOrientation = viewModel.prompt.orientation
        viewModel.coordinateEntry = viewModel.prompt.target.description
        viewModel.submitCoordinate()
        viewModel.advance()

        #expect(!viewModel.inputLocked)
        #expect(viewModel.coordinateEntry.isEmpty)
        #expect(viewModel.presentation.feedback == nil)
        #expect(viewModel.prompt.orientation != firstOrientation)
    }
}
