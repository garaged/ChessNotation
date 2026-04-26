import XCTest
@testable import ChessNotation

final class ChessNotationKeyAvailabilityTests: XCTestCase {
    func testEmptyInputIncludesOpeningKeys() {
        let keys = ChessNotationKeyAvailability.availableKeys(for: "")

        XCTAssertTrue(keys.isSuperset(of: ["K", "Q", "R", "B", "N"]))
        XCTAssertTrue(keys.isSuperset(of: ["a", "b", "c", "d", "e", "f", "g", "h"]))
        XCTAssertTrue(keys.isSuperset(of: ["O-O", "O-O-O"]))
    }

    func testPromotionInputEnablesPromotionPieces() {
        let keys = ChessNotationKeyAvailability.availableKeys(for: "e8=")

        XCTAssertTrue(keys.isSuperset(of: ["Q", "R", "B", "N"]))
        XCTAssertFalse(keys.contains("K"))
        XCTAssertFalse(keys.contains("a"))
    }

    func testCastlingInputRestrictsToCompletionKeys() {
        let keys = ChessNotationKeyAvailability.availableKeys(for: "O-O")

        XCTAssertTrue(keys.isSuperset(of: ["+", "#", "Submit", "Backspace", "Clear"]))
        XCTAssertFalse(keys.contains("K"))
        XCTAssertFalse(keys.contains("a"))
        XCTAssertFalse(keys.contains("1"))
    }

    func testCheckSuffixRestrictsToActions() {
        let keys = ChessNotationKeyAvailability.availableKeys(for: "Qh5+")

        XCTAssertTrue(keys.isSuperset(of: ["Submit", "Backspace", "Clear"]))
        XCTAssertFalse(keys.contains("Q"))
        XCTAssertFalse(keys.contains("h"))
        XCTAssertFalse(keys.contains("5"))
    }

    func testEmptyInputDoesNotEnableSubmit() {
        let keys = ChessNotationKeyAvailability.availableKeys(for: "")

        XCTAssertFalse(keys.contains("Submit"))
    }

    func testNonEmptyInputEnablesActions() {
        let keys = ChessNotationKeyAvailability.availableKeys(for: "e4")

        XCTAssertTrue(keys.isSuperset(of: ["Submit", "Backspace", "Clear"]))
    }
}
