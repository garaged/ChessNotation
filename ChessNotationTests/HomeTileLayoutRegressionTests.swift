import Foundation
import Testing

struct HomeTileLayoutRegressionTests {
    @Test
    func homeUsesStableSymmetricTileColumns() throws {
        let source = try homeSource()

        #expect(source.contains("static let columnCount = 2"))
        #expect(source.contains("GridItem(.flexible(minimum: 0)"))
        #expect(!source.contains("GridItem(.adaptive(minimum:"))
    }

    @Test
    func homeTilesReserveConsistentTypographyRegions() throws {
        let source = try homeSource()

        #expect(source.contains("regularTitleHeight"))
        #expect(source.contains("regularSubtitleHeight"))
        #expect(source.contains("regularCardHeight"))
        #expect(source.contains(".font(.headline.weight(.semibold))"))
        #expect(source.contains(".font(.caption)"))
    }

    @Test
    func accessibilityTextCanExpandBeyondRegularTileHeight() throws {
        let source = try homeSource()

        #expect(source.contains("dynamicTypeSize.isAccessibilitySize"))
        #expect(source.contains("usesFlexibleTextHeight ? nil : 2"))
        #expect(source.contains("usesFlexibleTextHeight ? nil : 3"))
        #expect(source.contains("usesFlexibleTextHeight ? nil : HomeTileLayout.regularCardHeight"))
    }

    private func homeSource() throws -> String {
        let root = try repositoryRoot()
        return try String(
            contentsOf: root.appendingPathComponent("ChessNotation/Features/Home/RestoredHomeView.swift"),
            encoding: .utf8
        )
    }

    private func repositoryRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

        while candidate.path != "/" {
            let project = candidate.appendingPathComponent("ChessNotation.xcodeproj/project.pbxproj")
            if FileManager.default.fileExists(atPath: project.path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }

        throw HomeTileLayoutAuditError.repositoryRootNotFound
    }
}

private enum HomeTileLayoutAuditError: Error {
    case repositoryRootNotFound
}
