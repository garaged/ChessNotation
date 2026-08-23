import Foundation
import Testing
@testable import ChessNotation

struct BundledGameValidationTests {
    @Test
    func rejectsDuplicateStableGameIDs() throws {
        let data = try #require(
            """
            [
              \(validGameJSON(id: "duplicate", title: "First")),
              \(validGameJSON(id: "duplicate", title: "Second"))
            ]
            """.data(using: .utf8)
        )

        let issues = try validationIssues(from: data)

        #expect(issues.contains { $0.code == .duplicateGameID && $0.gameID == "duplicate" })
    }

    @Test
    func rejectsEmptyRequiredStringsAndEmptyMoveLists() throws {
        let data = try #require(
            """
            {
              "id": "",
              "title": "   ",
              "white": "White",
              "black": "Black",
              "year": 2024,
              "opening": null,
              "difficulty": "beginner",
              "moves": []
            }
            """.data(using: .utf8)
        )

        let issues = try validationIssues(from: data)

        #expect(issues.contains { $0.code == .emptyRequiredString && $0.field == "id" })
        #expect(issues.contains { $0.code == .emptyRequiredString && $0.field == "title" })
        #expect(issues.contains { $0.code == .emptyMoves })
    }

    @Test
    func rejectsMalformedSquaresAndInconsistentCoordinate() throws {
        let data = try #require(
            validGameJSON(
                id: "bad-coordinate",
                from: "i2",
                to: "e9",
                coordinate: "a1a2"
            ).data(using: .utf8)
        )

        let issues = try validationIssues(from: data)

        #expect(issues.contains { $0.code == .invalidSquare && $0.field == "from" })
        #expect(issues.contains { $0.code == .invalidSquare && $0.field == "to" })
        #expect(issues.contains { $0.code == .inconsistentCoordinate })
    }

    @Test
    func rejectsMalformedFENWithoutUnsafeBoardIndexing() throws {
        let data = try #require(
            validGameJSON(
                id: "bad-fen",
                fenBefore: "8/8/8/8/8/8/8/9 w - - 0 1"
            ).data(using: .utf8)
        )

        let issues = try validationIssues(from: data)

        #expect(issues.contains { $0.code == .invalidFEN && $0.gameID == "bad-fen" })
    }

    @Test
    func acceptsPromotionCoordinateSuffixAndValidFEN() throws {
        let data = try #require(
            validGameJSON(
                id: "promotion",
                fenBefore: "4k3/4P3/8/8/8/8/8/4K3 w - - 0 1",
                from: "e7",
                to: "e8",
                san: "e8=Q+",
                coordinate: "e7e8q"
            ).data(using: .utf8)
        )

        let games = try BundledGameLibraryService.decodeGames(from: data)

        #expect(games.map(\.id) == ["promotion"])
    }

    @Test
    func reportsInvalidRecordLocationWithoutIncludingPayload() throws {
        let secretTitle = "private-answer-payload"
        let data = try #require(
            validGameJSON(
                id: "safe-diagnostic",
                title: secretTitle,
                from: "z9"
            ).data(using: .utf8)
        )

        do {
            _ = try BundledGameLibraryService.decodeGames(from: data)
            Issue.record("Expected invalid content")
        } catch let error as GameLibraryError {
            let description = error.localizedDescription
            #expect(description.contains("safe-diagnostic"))
            #expect(description.contains("from"))
            #expect(!description.contains(secretTitle))
        }
    }

    private func validationIssues(from data: Data) throws -> [GameLibraryValidationIssue] {
        do {
            _ = try BundledGameLibraryService.decodeGames(from: data)
            Issue.record("Expected bundled game validation failure")
            return []
        } catch GameLibraryError.invalidContent(let issues) {
            return issues
        }
    }

    private func validGameJSON(
        id: String,
        title: String = "Valid Game",
        fenBefore: String = "startpos",
        from: String = "e2",
        to: String = "e4",
        san: String = "e4",
        coordinate: String = "e2e4"
    ) -> String {
        """
        {
          "id": "\(id)",
          "title": "\(title)",
          "white": "White",
          "black": "Black",
          "year": 2024,
          "opening": "Test Opening",
          "difficulty": "beginner",
          "moves": [
            {
              "moveNumber": 1,
              "side": "white",
              "fenBefore": "\(fenBefore)",
              "from": "\(from)",
              "to": "\(to)",
              "san": "\(san)",
              "coordinate": "\(coordinate)",
              "tags": ["pawnMove"]
            }
          ]
        }
        """
    }
}
