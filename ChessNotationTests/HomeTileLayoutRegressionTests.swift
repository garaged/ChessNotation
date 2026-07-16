import Foundation
import Testing

struct HomeTileLayoutRegressionTests {
    @Test
    func homeUsesResponsivePhoneAndIPadLayouts() throws {
        let source = try homeSource()

        #expect(source.contains("@Environment(\\.horizontalSizeClass)"))
        #expect(source.contains("horizontalSizeClass == .regular"))
        #expect(source.contains("count: 3"))
        #expect(source.contains("let count = usesSingleColumn ? 1 : 2"))
        #expect(source.contains("maximumContentWidth"))
        #expect(!source.contains("GridItem(.adaptive(minimum:"))
    }

    @Test
    func compactMiniGamesUseNonCollidingHorizontalCards() throws {
        let source = try homeSource()

        #expect(source.contains("miniGameLinks(layout: .horizontal)"))
        #expect(source.contains("horizontalArtworkWidth"))
        #expect(source.contains("horizontalCardHeight"))
        #expect(source.contains(".frame(maxWidth: .infinity)"))
        #expect(source.contains(".clipped()"))
    }

    @Test
    func instructionsAreSecondaryInsteadOfMiniGameTile() throws {
        let source = try homeSource()
        let miniGamesStart = try #require(source.range(of: "private var miniGamesMenu"))
        let secondaryStart = try #require(source.range(of: "private var secondaryActions"))
        let miniGamesSource = source[miniGamesStart.lowerBound..<secondaryStart.lowerBound]

        #expect(!miniGamesSource.contains("InstructionsView"))
        #expect(source.contains("HomeSectionHeader(title: \"Help\""))
        #expect(source.contains("HomeUtilityRow("))
        #expect(source.contains("accessibilityIdentifier(\"home.instructionsLink\")"))
    }

    @Test
    func accessibilityTextDropsToOneColumnAndCanExpand() throws {
        let source = try homeSource()

        #expect(source.contains("dynamicTypeSize.isAccessibilitySize"))
        #expect(source.contains("usesSingleColumn"))
        #expect(source.contains("usesFlexibleHeight ? nil"))
        #expect(source.contains(".lineLimit(usesFlexibleHeight ? nil : 2)"))
        #expect(source.contains(".lineLimit(usesFlexibleHeight ? nil : 3)"))
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
