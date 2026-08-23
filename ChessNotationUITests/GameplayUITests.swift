import XCTest

final class GameplayUITests: ChessNotationUITestCase {
    func testLaunchAndPlayFirstMove() throws {
        let app = makeApp()

        openPracticeLibrary(in: app)

        let operaGameButton = libraryGame(identifier: "opera-game-1858", in: app)
        XCTAssertTrue(operaGameButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["library.thumbnail.opera-game-1858"].exists)
        operaGameButton.tap()

        enterMove("e4", in: app)
        app.buttons["ChessNotationKeyboard.Submit"].tap()

        XCTAssertTrue(app.staticTexts["game.progressText"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["game.progressText"].label, "Move 2 of 23")
        XCTAssertFalse(app.staticTexts["game.timerText"].exists)
    }

    func testEvaluatedGameShowsNeutralEvaluationBarAtLaunch() throws {
        let app = makeApp()

        openPracticeLibrary(in: app)

        let operaGameButton = libraryGame(identifier: "opera-game-1858", in: app)
        XCTAssertTrue(operaGameButton.waitForExistence(timeout: 5))
        operaGameButton.tap()

        let evaluationBar = app.otherElements["game.positionEvaluation"]
        XCTAssertTrue(evaluationBar.waitForExistence(timeout: 5))
        XCTAssertEqual(evaluationBar.value as? String, "Neutral placeholder until a stored position evaluation is available")
    }

    func testResultsRestartFlow() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        openPracticeLibrary(in: app)

        let beginnerGame = libraryGame(identifier: "mini-opera", in: app)
        XCTAssertTrue(beginnerGame.waitForExistence(timeout: 5))
        beginnerGame.tap()

        enterMove("e4", in: app)
        app.buttons["ChessNotationKeyboard.Submit"].tap()

        let restartButton = app.buttons["results.restartButton"]
        for _ in 0..<4 where !restartButton.exists {
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(restartButton.waitForExistence(timeout: 5))
        restartButton.tap()

        let progressText = app.staticTexts["game.progressText"]
        XCTAssertTrue(progressText.waitForExistence(timeout: 5))
        XCTAssertEqual(progressText.label, "Move 1 of 1")
    }
}
