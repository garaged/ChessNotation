import XCTest

final class BoardLegibilityUITests: ChessNotationUITestCase {
    func testNotationBoardIsCenteredReadableAndAddressable() throws {
        let app = makeApp()

        openPracticeLibrary(in: app)

        let operaGameButton = libraryGame(identifier: "opera-game-1858", in: app)
        XCTAssertTrue(operaGameButton.waitForExistence(timeout: 5))
        operaGameButton.tap()

        let board = app.otherElements["game.chessBoard"]
        XCTAssertTrue(board.waitForExistence(timeout: 5))
        XCTAssertTrue(board.isHittable)

        let boardFrame = board.frame
        XCTAssertGreaterThan(boardFrame.width, app.frame.width * 0.60)
        XCTAssertEqual(boardFrame.width, boardFrame.height, accuracy: 2)

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "notation-board-legibility"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
