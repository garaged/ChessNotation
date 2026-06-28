import Testing
@testable import ChessNotation

struct ChessNotationKeyboardTests {
    @Test
    func emptyInputOffersNotationKeysButNoActions() {
        let keys = ChessNotationKeyAvailability.availableKeys(for: "")

        #expect(keys.isSuperset(of: ["K", "Q", "R", "B", "N", "a", "h", "1", "8", "O-O", "O-O-O"]))
        #expect(!keys.contains("Submit"))
        #expect(!keys.contains("Backspace"))
        #expect(!keys.contains("Clear"))
    }

    @Test
    func startedInputOffersEditingAndSubmitKeys() {
        let keys = ChessNotationKeyAvailability.availableKeys(for: "Nf")

        #expect(keys.contains("Submit"))
        #expect(keys.contains("Backspace"))
        #expect(keys.contains("Clear"))
        #expect(keys.contains("x"))
        #expect(!keys.contains("O-O"))
        #expect(!keys.contains("O-O-O"))
    }

    @Test
    func promotionInputOnlyAllowsPromotionPiecesThenCheckSuffixes() {
        let promotionKeys = ChessNotationKeyAvailability.availableKeys(for: "e8=")
        #expect(promotionKeys.isSuperset(of: ["Q", "R", "B", "N", "Backspace", "Clear", "Submit"]))
        #expect(!promotionKeys.contains("K"))
        #expect(!promotionKeys.contains("a"))

        let suffixKeys = ChessNotationKeyAvailability.availableKeys(for: "e8=Q")
        #expect(suffixKeys.isSuperset(of: ["+", "#", "Backspace", "Clear", "Submit"]))
        #expect(!suffixKeys.contains("="))
        #expect(!suffixKeys.contains("a"))
    }
}
