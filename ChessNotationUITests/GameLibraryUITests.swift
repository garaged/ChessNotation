import XCTest

final class GameLibraryUITests: ChessNotationUITestCase {
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

    func testNonEvaluatedGameDoesNotShowEvaluationBar() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        openPracticeLibrary(in: app)

        let beginnerGame = app.buttons["library.game.mini-opera"]
        XCTAssertTrue(beginnerGame.waitForExistence(timeout: 5))
        beginnerGame.tap()

        XCTAssertFalse(app.otherElements["game.positionEvaluation"].exists)
    }
}
