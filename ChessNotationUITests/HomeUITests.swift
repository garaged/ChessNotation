import XCTest

final class HomeUITests: ChessNotationUITestCase {
    func testHomeTilesNavigateToLibraryAndSquareRecognition() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        XCTAssertTrue(homeTile(identifier: "home.notationTrainingTile", title: "Notation Training", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(homeTile(identifier: "home.timedNotationTile", title: "Timed Notation", in: app).waitForExistence(timeout: 5))
        XCTAssertFalse(app.segmentedControls["library.levelFilter"].exists)

        let squareRecognitionLink = scrollToHomeTile(identifier: "home.squareRecognitionLink", title: "Square Recognition", in: app)
        XCTAssertTrue(squareRecognitionLink.waitForExistence(timeout: 5))
        XCTAssertTrue(squareRecognitionLink.isHittable)

        XCTAssertTrue(scrollToHomeTile(identifier: "home.pieceMovementLink", title: "Piece Movement", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToHomeTile(identifier: "home.positionRecallLink", title: "Position Recall", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToHomeTile(identifier: "home.instructionsLink", title: "Instructions", in: app).waitForExistence(timeout: 5))

        squareRecognitionLink.tap()
        XCTAssertTrue(app.buttons["squareRecognition.startButton"].waitForExistence(timeout: 5))
    }

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

    func testInstructionsTileOpensInstructions() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let instructionsTile = scrollToHomeTile(identifier: "home.instructionsLink", title: "Instructions", in: app)
        XCTAssertTrue(instructionsTile.waitForExistence(timeout: 5))
        XCTAssertTrue(instructionsTile.isHittable)
        instructionsTile.tap()

        XCTAssertTrue(app.navigationBars["Instructions"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Choose A Mode"].exists)
    }
}
