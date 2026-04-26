import XCTest

final class ChessNotationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchAndPlayFirstMove() throws {
        let app = makeApp()

        let operaGameButton = app.buttons["home.game.opera-game-1858"]
        XCTAssertTrue(operaGameButton.waitForExistence(timeout: 5))
        operaGameButton.tap()

        let answerField = app.staticTexts["game.answerField"]
        XCTAssertTrue(answerField.waitForExistence(timeout: 5))
        enterMove("e4", in: app)

        app.buttons["ChessNotationKeyboard.Submit"].tap()

        XCTAssertTrue(app.staticTexts["game.progressText"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["game.progressText"].label, "Move 2 of 23 (attempt 1/3)")
    }

    @MainActor
    func testLibraryFiltersByLevel() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let beginnerGame = app.buttons["home.game.mini-opera"]
        let advancedGame = app.buttons["home.game.mini-evergreen"]
        XCTAssertTrue(beginnerGame.waitForExistence(timeout: 5))
        XCTAssertTrue(advancedGame.exists)

        app.segmentedControls["home.levelFilter"].buttons["Advanced"].tap()

        XCTAssertTrue(advancedGame.waitForExistence(timeout: 5))
        XCTAssertTrue(beginnerGame.waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testResultsRestartFlow() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let beginnerGame = app.buttons["home.game.mini-opera"]
        XCTAssertTrue(beginnerGame.waitForExistence(timeout: 5))
        beginnerGame.tap()

        let answerField = app.staticTexts["game.answerField"]
        XCTAssertTrue(answerField.waitForExistence(timeout: 5))
        enterMove("e4", in: app)

        app.buttons["ChessNotationKeyboard.Submit"].tap()

        let restartButton = app.buttons["results.restartButton"]
        XCTAssertTrue(restartButton.waitForExistence(timeout: 5))
        restartButton.tap()

        let progressText = app.staticTexts["game.progressText"]
        XCTAssertTrue(progressText.waitForExistence(timeout: 5))
        XCTAssertEqual(progressText.label, "Move 1 of 1 (attempt 1/3)")
    }

    @MainActor
    private func makeApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        return app
    }

    @MainActor
    private func enterMove(_ move: String, in app: XCUIApplication) {
        for character in move {
            app.buttons[keyIdentifier(for: character)].tap()
        }
    }

    private func keyIdentifier(for character: Character) -> String {
        switch character {
        case "+":
            return "ChessNotationKeyboard.Key.+"
        case "#":
            return "ChessNotationKeyboard.Key.#"
        case "=":
            return "ChessNotationKeyboard.Key.="
        case "x":
            return "ChessNotationKeyboard.Key.x"
        default:
            return "ChessNotationKeyboard.Key.\(character)"
        }
    }
}
