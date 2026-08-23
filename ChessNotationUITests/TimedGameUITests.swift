import XCTest

final class TimedGameUITests: ChessNotationUITestCase {
    func testTimedGameLaunchShowsTimerAndTimedResults() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        openTimedLibrary(in: app)

        XCTAssertTrue(app.staticTexts["library.launchModeText"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["library.launchModeText"].label, "Timed mode")

        let timedGameButton = libraryGame(identifier: "mini-opera", in: app)
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
        for _ in 0..<4 where !app.staticTexts["Selected duration"].exists {
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(app.staticTexts["Selected duration"].exists)
        XCTAssertTrue(app.staticTexts["3:00"].exists)

        let changeSetup = app.buttons["results.changeSetupButton"]
        for _ in 0..<4 where !changeSetup.exists {
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(changeSetup.waitForExistence(timeout: 5))
        changeSetup.tap()

        XCTAssertTrue(durationPicker.waitForExistence(timeout: 5))
        XCTAssertTrue(durationPicker.buttons["3 min"].isSelected)
    }
}
