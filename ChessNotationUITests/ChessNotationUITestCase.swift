import XCTest

@MainActor
class ChessNotationUITestCase: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func makeApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        return app
    }

    func openPracticeLibrary(in app: XCUIApplication) {
        let tile = homeTile(identifier: "home.notationTrainingTile", title: "Notation Training", in: app)
        XCTAssertTrue(tile.waitForExistence(timeout: 5))
        tile.tap()
        XCTAssertTrue(app.collectionViews["library.screen"].waitForExistence(timeout: 5))
    }

    func openTimedLibrary(in app: XCUIApplication) {
        let tile = homeTile(identifier: "home.timedNotationTile", title: "Timed Notation", in: app)
        XCTAssertTrue(tile.waitForExistence(timeout: 5))
        tile.tap()
        XCTAssertTrue(app.collectionViews["library.screen"].waitForExistence(timeout: 5))
    }

    func scrollToHomeTile(identifier: String, title: String, in app: XCUIApplication) -> XCUIElement {
        for _ in 0..<8 {
            let candidate = homeTile(identifier: identifier, title: title, in: app)
            if candidate.waitForExistence(timeout: 1), candidate.isHittable {
                return candidate
            }
            app.scrollViews.firstMatch.swipeUp()
        }
        return homeTile(identifier: identifier, title: title, in: app)
    }

    func homeTile(identifier: String, title: String, in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.buttons[identifier],
            app.otherElements[identifier],
            app.buttons[title],
            app.otherElements[title],
            app.staticTexts[title]
        ]

        if let hittable = candidates.first(where: { $0.exists && $0.isHittable }) {
            return hittable
        }
        if let existing = candidates.first(where: { $0.exists }) {
            return existing
        }
        return app.buttons[identifier]
    }

    func enterMove(_ move: String, in app: XCUIApplication) {
        XCTAssertTrue(app.otherElements["ChessNotationKeyboard.Root"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.keyboards.element.exists)

        for character in move {
            let key = app.buttons[keyIdentifier(for: character)]
            XCTAssertTrue(key.waitForExistence(timeout: 5), "Missing notation key \(character)")
            key.tap()
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
