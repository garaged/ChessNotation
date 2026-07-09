import XCTest

final class SquareRecognitionUITests: ChessNotationUITestCase {
    func testSquareRecognitionSetupAndCorrectTapFlow() throws {
        let app = makeApp(arguments: ["UITEST_SAMPLE_LIBRARY"])

        let squareRecognitionLink = scrollToHomeTile(identifier: "home.squareRecognitionLink", title: "Square Recognition", in: app)
        XCTAssertTrue(squareRecognitionLink.waitForExistence(timeout: 5))
        XCTAssertTrue(squareRecognitionLink.isHittable)
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
}
