import XCTest

final class ChessNotationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testHomeTilesNavigateToLibraryAndSquareRecognition() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        XCTAssertTrue(app.buttons["home.notationTrainingTile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["home.timedNotationTile"].exists)
        XCTAssertTrue(app.buttons["home.squareRecognitionLink"].exists)
        XCTAssertTrue(app.buttons["home.instructionsLink"].exists)
        XCTAssertFalse(app.segmentedControls["library.levelFilter"].exists)

        app.buttons["home.squareRecognitionLink"].tap()
        XCTAssertTrue(app.buttons["squareRecognition.startButton"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsShowsAppVersion() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let settingsButton = app.buttons["home.appearanceButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let versionText = app.staticTexts["settings.versionText"]
        if !versionText.exists {
            app.swipeUp()
        }
        XCTAssertTrue(versionText.waitForExistence(timeout: 5))
        XCTAssertTrue(versionText.label.hasPrefix("Version "))
    }

    @MainActor
    func testInstructionsTileOpensInstructions() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let instructionsTile = app.buttons["home.instructionsLink"]
        XCTAssertTrue(instructionsTile.waitForExistence(timeout: 5))
        instructionsTile.tap()

        XCTAssertTrue(app.navigationBars["Instructions"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Choose A Mode"].exists)
    }

    @MainActor
    func testLaunchAndPlayFirstMove() throws {
        let app = makeApp()

        openPracticeLibrary(in: app)

        let operaGameButton = app.buttons["library.game.opera-game-1858"]
        XCTAssertTrue(operaGameButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["library.thumbnail.opera-game-1858"].exists)
        operaGameButton.tap()

        enterMove("e4", in: app)

        app.buttons["ChessNotationKeyboard.Submit"].tap()

        XCTAssertTrue(app.staticTexts["game.progressText"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["game.progressText"].label, "Move 2 of 23")
        XCTAssertFalse(app.staticTexts["game.timerText"].exists)
    }

    @MainActor
    func testLibraryFiltersByLevel() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        openPracticeLibrary(in: app)

        let beginnerGame = app.buttons["library.game.mini-opera"]
        let advancedGame = app.buttons["library.game.mini-evergreen"]
        XCTAssertTrue(beginnerGame.waitForExistence(timeout: 5))
        if !advancedGame.exists {
            app.swipeUp()
        }
        XCTAssertTrue(advancedGame.waitForExistence(timeout: 5))

        if !app.segmentedControls["library.levelFilter"].exists {
            app.swipeDown()
        }
        app.segmentedControls["library.levelFilter"].buttons["Advanced"].tap()

        if !advancedGame.exists {
            app.swipeUp()
        }
        XCTAssertTrue(advancedGame.waitForExistence(timeout: 5))
        XCTAssertTrue(beginnerGame.waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testResultsRestartFlow() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        openPracticeLibrary(in: app)

        let beginnerGame = app.buttons["library.game.mini-opera"]
        XCTAssertTrue(beginnerGame.waitForExistence(timeout: 5))
        beginnerGame.tap()

        enterMove("e4", in: app)

        app.buttons["ChessNotationKeyboard.Submit"].tap()

        let restartButton = app.buttons["results.restartButton"]
        XCTAssertTrue(restartButton.waitForExistence(timeout: 5))
        restartButton.tap()

        let progressText = app.staticTexts["game.progressText"]
        XCTAssertTrue(progressText.waitForExistence(timeout: 5))
        XCTAssertEqual(progressText.label, "Move 1 of 1")
    }

    @MainActor
    func testTimedGameLaunchShowsTimerAndTimedResults() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        openTimedLibrary(in: app)

        XCTAssertTrue(app.staticTexts["library.launchModeText"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["library.launchModeText"].label, "Timed mode")

        let timedGameButton = app.buttons["library.game.mini-opera"]
        XCTAssertTrue(timedGameButton.waitForExistence(timeout: 5))
        timedGameButton.tap()

        let durationPicker = app.segmentedControls["timedGame.durationPicker"]
        XCTAssertTrue(durationPicker.waitForExistence(timeout: 5))
        XCTAssertTrue(durationPicker.buttons["1 min"].exists)
        XCTAssertTrue(durationPicker.buttons["3 min"].exists)
        XCTAssertTrue(durationPicker.buttons["5 min"].exists)

        app.buttons["timedGame.startButton"].tap()

        let timerText = app.staticTexts["game.timerText"]
        XCTAssertTrue(timerText.waitForExistence(timeout: 5))
        XCTAssertTrue(timerText.label.range(of: #"Timed mode, 2:5[0-9] remaining|Timed mode, 3:00 remaining"#, options: .regularExpression) != nil)

        enterMove("e4", in: app)
        app.buttons["ChessNotationKeyboard.Submit"].tap()

        XCTAssertTrue(app.staticTexts["Finish reason"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Completed"].exists)
        XCTAssertTrue(app.staticTexts["Selected duration"].exists)
        XCTAssertTrue(app.staticTexts["3:00"].exists)
    }

    @MainActor
    func testSquareRecognitionSetupAndCorrectTapFlow() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let squareRecognitionLink = app.buttons["home.squareRecognitionLink"]
        XCTAssertTrue(squareRecognitionLink.waitForExistence(timeout: 5))
        squareRecognitionLink.tap()

        XCTAssertTrue(app.buttons["squareRecognition.startButton"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.segmentedControls["squareRecognition.variantPicker"].buttons["Bonus"].exists)
        XCTAssertTrue(app.segmentedControls["squareRecognition.variantPicker"].buttons["Strict"].exists)

        app.buttons["squareRecognition.startButton"].tap()

        let prompt = app.staticTexts["squareRecognition.promptText"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["squareRecognition.whiteSideLabel"].exists)
        let promptedSquare = prompt.label
        XCTAssertTrue(promptedSquare.range(of: #"^[a-h][1-8]$"#, options: .regularExpression) != nil)

        let squareButton = app.buttons["squareRecognition.square.\(promptedSquare)"]
        XCTAssertTrue(squareButton.waitForExistence(timeout: 5))
        squareButton.tap()

        let scoreValue = app.staticTexts["squareRecognition.scoreValue"]
        XCTAssertTrue(scoreValue.waitForExistence(timeout: 5))
        XCTAssertEqual(scoreValue.label, "1")
    }

    @MainActor
    private func openPracticeLibrary(in app: XCUIApplication) {
        let tile = app.buttons["home.notationTrainingTile"]
        XCTAssertTrue(tile.waitForExistence(timeout: 5))
        tile.tap()
        XCTAssertTrue(app.collectionViews["library.screen"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func openTimedLibrary(in app: XCUIApplication) {
        let tile = app.buttons["home.timedNotationTile"]
        XCTAssertTrue(tile.waitForExistence(timeout: 5))
        tile.tap()
        XCTAssertTrue(app.collectionViews["library.screen"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func enterMove(_ move: String, in app: XCUIApplication) {
        XCTAssertTrue(app.otherElements["ChessNotationKeyboard.Root"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.keyboards.element.exists)

        for character in move {
            let key = app.buttons[keyIdentifier(for: character)]
            XCTAssertTrue(key.waitForExistence(timeout: 5), "Missing notation key \(character)")
            key.tap()
        }
    }

    @MainActor
    private func makeApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        return app
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
