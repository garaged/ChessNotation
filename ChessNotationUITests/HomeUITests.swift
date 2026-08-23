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
        XCTAssertTrue(app.buttons["boardSkills.quickStart"].waitForExistence(timeout: 5))

        let squareRecognitionLink = app.buttons["home.squareRecognitionLink"]
        XCTAssertTrue(squareRecognitionLink.waitForExistence(timeout: 5))
        XCTAssertTrue(squareRecognitionLink.isHittable)

        let pieceMovementLink = app.buttons["home.pieceMovementLink"]
        XCTAssertTrue(pieceMovementLink.waitForExistence(timeout: 5))
        XCTAssertTrue(pieceMovementLink.isHittable)

        squareRecognitionLink.tap()
        XCTAssertTrue(app.buttons["squareRecognition.startButton"].waitForExistence(timeout: 5))
    }

    func testHomeFamilyCardsHaveEqualRenderedFramesAndPositiveGaps() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])
        let tiles = [
            app.buttons["home.notationTrainingTile"],
            app.buttons["home.timedNotationTile"],
            app.buttons["home.boardSkillsLink"],
            app.buttons["home.positionRecallLink"]
        ]

        for tile in tiles {
            XCTAssertTrue(tile.waitForExistence(timeout: 5))
        }

        let frames = tiles.map(\.frame)
        let reference = try XCTUnwrap(frames.first)
        for frame in frames.dropFirst() {
            XCTAssertEqual(frame.width, reference.width, accuracy: 1, "Family-card widths must match")
            XCTAssertEqual(frame.height, reference.height, accuracy: 1, "Family-card heights must match")
        }

        XCTAssertGreaterThan(frames[1].minX - frames[0].maxX, 0, "First-row cards must preserve a positive horizontal gap")
        XCTAssertGreaterThan(frames[3].minX - frames[2].maxX, 0, "Second-row cards must preserve a positive horizontal gap")
        XCTAssertGreaterThan(frames[2].minY - frames[0].maxY, 0, "Left-column cards must preserve a positive vertical gap")
        XCTAssertGreaterThan(frames[3].minY - frames[1].maxY, 0, "Right-column cards must preserve a positive vertical gap")

        for firstIndex in frames.indices {
            for secondIndex in frames.indices where secondIndex > firstIndex {
                XCTAssertFalse(
                    frames[firstIndex].intersects(frames[secondIndex]),
                    "Family cards \(firstIndex) and \(secondIndex) must never overlap"
                )
            }
        }
    }

    func testInstructionsMatchesFamilyCardGeometryAndIsCentered() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let positionRecall = scrollToHomeTile(
            identifier: "home.positionRecallLink",
            title: "Position Recall",
            in: app
        )
        XCTAssertTrue(positionRecall.waitForExistence(timeout: 5))

        let instructions = scrollToHomeTile(
            identifier: "home.instructionsLink",
            title: "Instructions",
            in: app
        )
        XCTAssertTrue(instructions.waitForExistence(timeout: 5))

        XCTAssertEqual(
            instructions.frame.width,
            positionRecall.frame.width,
            accuracy: 1,
            "Instructions must use one family-card column width"
        )
        XCTAssertEqual(
            instructions.frame.height,
            positionRecall.frame.height,
            accuracy: 1,
            "Instructions must use the same card height as family cards"
        )

        let window = app.windows.element(boundBy: 0)
        XCTAssertTrue(window.exists)
        XCTAssertEqual(
            instructions.frame.midX,
            window.frame.midX,
            accuracy: 1,
            "Instructions must be centered in its own single-card row"
        )
        XCTAssertGreaterThan(
            instructions.frame.minY,
            positionRecall.frame.maxY,
            "Instructions must remain below and outside the primary 2x2 gameplay grid"
        )
    }

    func testBoardSkillsUsesQuickStartAndTwoAlignedCompactRows() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])
        let boardSkillsTile = scrollToHomeTile(identifier: "home.boardSkillsLink", title: "Board Skills", in: app)
        XCTAssertTrue(boardSkillsTile.waitForExistence(timeout: 5))
        boardSkillsTile.tap()

        let quickStart = app.buttons["boardSkills.quickStart"]
        let squareRecognition = app.buttons["home.squareRecognitionLink"]
        let pieceMovement = app.buttons["home.pieceMovementLink"]

        XCTAssertTrue(quickStart.waitForExistence(timeout: 5))
        XCTAssertTrue(squareRecognition.waitForExistence(timeout: 5))
        XCTAssertTrue(pieceMovement.waitForExistence(timeout: 5))

        XCTAssertGreaterThan(squareRecognition.frame.minY, quickStart.frame.maxY)
        XCTAssertGreaterThan(pieceMovement.frame.minY, squareRecognition.frame.maxY)
        XCTAssertEqual(squareRecognition.frame.width, pieceMovement.frame.width, accuracy: 1)
        XCTAssertEqual(squareRecognition.frame.height, pieceMovement.frame.height, accuracy: 1)
        XCTAssertEqual(squareRecognition.frame.minX, pieceMovement.frame.minX, accuracy: 1)
        XCTAssertFalse(squareRecognition.frame.intersects(pieceMovement.frame))
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
