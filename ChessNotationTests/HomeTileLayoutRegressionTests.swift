import Foundation
import Testing

struct HomeTileLayoutRegressionTests {
    @Test
    func homeUsesExactlyFourSymmetricFamilyTiles() throws {
        let source = try homeSource()
        let trainingStart = try #require(source.range(of: "private var trainingFamilies"))
        let helpStart = try #require(source.range(of: "private var helpSection"))
        let trainingSource = source[trainingStart.lowerBound..<helpStart.lowerBound]

        #expect(trainingSource.contains("title: \"Notation Training\""))
        #expect(trainingSource.contains("title: \"Timed Training\""))
        #expect(trainingSource.contains("title: \"Board Skills\""))
        #expect(trainingSource.contains("title: \"Position Recall\""))
        #expect(trainingSource.components(separatedBy: "familyTile(").count - 1 == 4)
        #expect(source.contains("count: familyColumnCount"))
        #expect(source.contains("dynamicTypeSize.isAccessibilitySize ? 1 : 2"))
        #expect(!source.contains("case horizontal"))
        #expect(!source.contains("horizontalCardHeight"))
        #expect(!source.contains("horizontalArtworkWidth"))
    }

    @Test
    func familyCardsUseOneSharedGeometryAndTypographyHierarchy() throws {
        let source = try homeSource()

        #expect(source.contains("static let artworkHeight"))
        #expect(source.contains("static let titleRegionHeight"))
        #expect(source.contains("static let subtitleRegionHeight"))
        #expect(source.contains("static let cardHeight"))
        #expect(source.contains("minHeight: usesFlexibleHeight ? nil : HomeTileLayout.cardHeight"))
        #expect(source.contains("maxHeight: usesFlexibleHeight ? nil : HomeTileLayout.cardHeight"))
        #expect(source.contains(".font(.headline.weight(.semibold))"))
        #expect(source.contains(".font(.caption)"))
        #expect(source.contains(".clipped()"))
    }

    @Test
    func boardSkillsOwnsOnlyPlayableCoordinateAndMovementGames() throws {
        let source = try homeSource()
        let boardSkillsStart = try #require(source.range(of: "private struct BoardSkillsFamilyView"))
        let pieceMovementStart = try #require(source.range(of: "private struct PieceMovementLauncherView"))
        let boardSkillsSource = source[boardSkillsStart.lowerBound..<pieceMovementStart.lowerBound]

        #expect(boardSkillsSource.contains("Square Recognition"))
        #expect(boardSkillsSource.contains("Piece Movement"))
        #expect(boardSkillsSource.contains("home.squareRecognitionLink"))
        #expect(boardSkillsSource.contains("home.pieceMovementLink"))
        #expect(!boardSkillsSource.contains("InstructionsView"))
    }

    @Test
    func instructionsRemainSecondaryToGameplayFamilies() throws {
        let source = try homeSource()
        let trainingStart = try #require(source.range(of: "private var trainingFamilies"))
        let helpStart = try #require(source.range(of: "private var helpSection"))
        let trainingSource = source[trainingStart.lowerBound..<helpStart.lowerBound]

        #expect(!trainingSource.contains("InstructionsView"))
        #expect(source.contains("HomeUtilityRow("))
        #expect(source.contains("accessibilityIdentifier(\"home.instructionsLink\")"))
    }

    @Test
    func accessibilityTextUsesOneColumnAndUnboundedVerticalGrowth() throws {
        let source = try homeSource()

        #expect(source.contains("dynamicTypeSize.isAccessibilitySize ? 1 : 2"))
        #expect(source.contains("usesFlexibleHeight ? nil : 2"))
        #expect(source.contains("usesFlexibleHeight ? nil : 3"))
        #expect(source.contains("minHeight: usesFlexibleHeight ? nil"))
        #expect(source.contains("maxHeight: usesFlexibleHeight ? nil"))
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
