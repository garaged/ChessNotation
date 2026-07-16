import XCTest

final class HomeUITests: ChessNotationUITestCase {
    func testHomeShowsFourFamiliesAndBoardSkillsOpensSquareRecognition() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        XCTAssertTrue(homeTile(identifier: "home.notationTrainingTile", title: "Notation Training", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(homeTile(identifier: "home.timedNotationTile", title: "Timed Training", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(homeTile(identifier: "home.boardSkillsLink", title: "Board Skills", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(homeTile(identifier: "home.positionRecallLink", title: "Position Recall", in: app).waitForExistence(timeout: 5))
        XCTAssertFalse(app.segmentedControls["library.levelFilter"].exists)

        let boardSkillsTile = scrollToHomeTile(identifier: "home.boardSkillsLink", title: "Board Skills", in: app)
        XCTAssertTrue(boardSkillsTile.isHittable)
        boardSkillsTile.tap()

        XCTAssertTrue(app.navigationBars["Board Skills"].waitForExistence(timeout: 5))

        let squareRecognitionLink = app.buttons["home.squareRecognitionLink"]
        XCTAssertTrue(squareRecognitionLink.waitForExistence(timeout: 5))
        XCTAssertTrue(squareRecognitionLink.isHittable)

        let pieceMovementLink = app.buttons["home.pieceMovementLink"]
        XCTAssertTrue(pieceMovementLink.waitForExistence(timeout: 5))
        XCTAssertTrue(pieceMovementLink.isHittable)

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

    func testInstructionsSecondaryActionOpensInstructions() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let instructionsLink = scrollToHomeTile(identifier: "home.instructionsLink", title: "Instructions", in: app)
        XCTAssertTrue(instructionsLink.waitForExistence(timeout: 5))
        XCTAssertTrue(instructionsLink.isHittable)
        instructionsLink.tap()

        XCTAssertTrue(app.navigationBars["Instructions"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Choose A Mode"].exists)
    }

    func testPieceMovementOpensFromBoardSkills() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let boardSkillsTile = scrollToHomeTile(identifier: "home.boardSkillsLink", title: "Board Skills", in: app)
        XCTAssertTrue(boardSkillsTile.waitForExistence(timeout: 5))
        boardSkillsTile.tap()

        let pieceMovementTile = app.buttons["home.pieceMovementLink"]
        XCTAssertTrue(pieceMovementTile.waitForExistence(timeout: 5))
        XCTAssertTrue(pieceMovementTile.isHittable)
        pieceMovementTile.tap()

        XCTAssertTrue(app.navigationBars["Piece Movement"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["pieceMovement.task"].waitForExistence(timeout: 5))
    }

    func testPositionRecallTileOpensGame() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let positionRecallTile = scrollToHomeTile(identifier: "home.positionRecallLink", title: "Position Recall", in: app)
        XCTAssertTrue(positionRecallTile.waitForExistence(timeout: 5))
        XCTAssertTrue(positionRecallTile.isHittable)
        positionRecallTile.tap()

        XCTAssertTrue(app.navigationBars["Position Recall"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["positionRecall.task"].waitForExistence(timeout: 5))
    }
}
