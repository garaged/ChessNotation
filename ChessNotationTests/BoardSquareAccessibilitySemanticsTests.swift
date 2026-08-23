import Testing
@testable import ChessNotation

struct BoardSquareAccessibilitySemanticsTests {
    @Test
    func everyCoordinateProducesStableLabelAndIdentifier() throws {
        var identifiers: Set<String> = []

        for rank in 0..<8 {
            for file in 0..<8 {
                let square = try #require(ChessSquare(file: file, rank: rank))
                let semantics = BoardSquareAccessibilitySemantics(square: square)

                #expect(semantics.label == square.description)
                #expect(semantics.identifier == "board.square.\(square.description)")
                identifiers.insert(semantics.identifier)
            }
        }

        #expect(identifiers.count == 64)
    }

    @Test
    func optionalDetailAddsMeaningWithoutChangingSquareIdentity() throws {
        let square = try #require(ChessSquare(file: 4, rank: 3))
        let plain = BoardSquareAccessibilitySemantics(square: square)
        let occupied = BoardSquareAccessibilitySemantics(square: square, detail: "white knight, selected")

        #expect(plain.label == "e4")
        #expect(occupied.label == "e4, white knight, selected")
        #expect(plain.identifier == occupied.identifier)
    }

    @Test
    func blankDetailDoesNotProduceTrailingPunctuation() throws {
        let square = try #require(ChessSquare(file: 0, rank: 0))

        #expect(BoardSquareAccessibilitySemantics(square: square, detail: "").label == "a1")
        #expect(BoardSquareAccessibilitySemantics(square: square, detail: "   ").label == "a1")
    }

    @Test
    func displayOrientationChangesOrderButNotCoordinateSemantics() throws {
        for orientation in BoardOrientationPolicy.allCases {
            var coordinates: Set<String> = []

            for index in 0..<64 {
                guard let square = SquareBoardMapping.square(forDisplayIndex: index, orientation: orientation) else {
                    Issue.record("Missing square for display index \(index) and orientation \(orientation)")
                    return
                }
                coordinates.insert(BoardSquareAccessibilitySemantics(square: square).coordinate)
            }

            #expect(coordinates.count == 64)
            #expect(coordinates.contains("a1"))
            #expect(coordinates.contains("h8"))
        }
    }
}
