import Foundation
import Testing

struct HomeTileLayoutRegressionTests {
    @Test
    func homeUsesExactlyFourSymmetricFamilyTiles() throws {
        let source = try homeSource()
        let trainingStart = try #require(source.range(of: "private var trainingFamilies"))
        let familyTileHelperStart = try #require(source.range(of: "private func familyTile"))
        let trainingSource = source[trainingStart.lowerBound..<familyTileHelperStart.lowerBound]

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
    func familyCardsUseCompactExactGeometryAndUntruncatedCopy() throws {
        let source = try homeSource()

        #expect(source.contains("static let gridSpacing: CGFloat = 20"))
        #expect(source.contains("static let artworkHeight: CGFloat = 100"))
        #expect(source.contains("static let titleRegionHeight: CGFloat = 22"))
        #expect(source.contains("static let subtitleRegionHeight: CGFloat = 36"))
        #expect(source.contains("static let cardHeight: CGFloat = 188"))
        #expect(source.contains("minHeight: usesFlexibleHeight ? nil : HomeLayout.cardHeight"))
        #expect(source.contains("maxHeight: usesFlexibleHeight ? nil : HomeLayout.cardHeight"))
        #expect(source.contains(".lineLimit(usesFlexibleHeight ? nil : 1)"))
        #expect(source.contains(".lineLimit(usesFlexibleHeight ? nil : 2)"))
        #expect(source.contains(".fixedSize(horizontal: false, vertical: true)"))
        #expect(source.contains("Practice SAN from real games."))
        #expect(source.contains("Build speed under a clock."))
        #expect(source.contains("Learn squares and movement."))
        #expect(source.contains("Rebuild positions from memory."))
    }

    @Test
    func familyArtworkUsesSharedEightByFiveViewportWithoutPerCardScale() throws {
        let source = try homeSource()

        #expect(source.contains("static let artworkAspectRatio: CGFloat = 8.0 / 5.0"))
        #expect(source.contains("HomeLayout.artworkHeight * HomeLayout.artworkAspectRatio"))
        #expect(source.contains("let artworkHeight = artworkWidth / HomeLayout.artworkAspectRatio"))
        #expect(!source.contains("positionRecallArtworkScale"))
        #expect(!source.contains("artworkScale:"))
        #expect(!source.contains(".scaleEffect(artworkScale)"))
    }

    @Test
    func heroRespectsSafeAreaAndSettingsUsesOpaqueToolbar() throws {
        let source = try homeSource()

        #expect(source.contains("ToolbarItem(placement: .topBarTrailing)"))
        #expect(source.contains(".toolbarBackground(PremiumDesign.backgroundTop, for: .navigationBar)"))
        #expect(source.contains(".toolbarBackground(.visible, for: .navigationBar)"))
        #expect(source.contains("static let topPadding: CGFloat = 12"))
        #expect(source.contains("static let compactHeroHeight: CGFloat = 156"))
        #expect(source.contains("Color.black.opacity(0.82)"))
        #expect(!source.contains("ZStack(alignment: .topTrailing)"))
        #expect(!source.contains(".padding(.top, 30)"))
    }

    @Test
    func boardSkillsUsesPremiumQuickStartAndCompactEqualRows() throws {
        let source = try homeSource()
        let boardSkillsStart = try #require(source.range(of: "private struct BoardSkillsFamilyView"))
        let pieceMovementStart = try #require(source.range(of: "private struct PieceMovementLauncherView"))
        let boardSkillsSource = source[boardSkillsStart.lowerBound..<pieceMovementStart.lowerBound]

        #expect(boardSkillsSource.contains("FamilyQuickStartCard("))
        #expect(boardSkillsSource.components(separatedBy: "FamilyGameRow(").count - 1 == 2)
        #expect(source.contains("static let drillRowHeight: CGFloat = 100"))
        #expect(source.contains("static let quickStartHeight: CGFloat = 132"))
        #expect(boardSkillsSource.contains("Choose a drill"))
        #expect(boardSkillsSource.contains("boardSkills.quickStart"))
        #expect(boardSkillsSource.contains("home.squareRecognitionLink"))
        #expect(boardSkillsSource.contains("home.pieceMovementLink"))
        #expect(!boardSkillsSource.contains("LazyVGrid"))
        #expect(!boardSkillsSource.contains("HomeMenuTile("))
        #expect(!boardSkillsSource.contains("InstructionsView"))
    }

    @Test
    func instructionsUseCenteredSingleColumnFamilyCardGeometry() throws {
        let source = try homeSource()
        let trainingStart = try #require(source.range(of: "private var trainingFamilies"))
        let helpStart = try #require(source.range(of: "private var helpSection"))
        let trainingSource = source[trainingStart.lowerBound..<helpStart.lowerBound]

        #expect(!trainingSource.contains("InstructionsView"))
        #expect(source.contains("private var instructionsLink"))
        #expect(source.contains("title: \"Instructions\""))
        #expect(source.contains("assetName: PremiumAssetName.instructionsTile"))
        #expect(source.contains("let cardWidth = max(0, (proxy.size.width - HomeLayout.gridSpacing) / 2)"))
        #expect(source.contains("instructionsLink\n                            .frame(width: cardWidth)"))
        #expect(source.contains(".frame(height: HomeLayout.cardHeight)"))
        #expect(!source.contains("PremiumInstructionsTile"))
        #expect(!source.contains("instructionsHeight"))
        #expect(source.contains("accessibilityIdentifier(\"home.instructionsLink\")"))
    }

    @Test
    func accessibilityTextUsesOneColumnAndUnboundedVerticalGrowth() throws {
        let source = try homeSource()

        #expect(source.contains("dynamicTypeSize.isAccessibilitySize ? 1 : 2"))
        #expect(source.contains("if dynamicTypeSize.isAccessibilitySize"))
        #expect(source.contains("usesFlexibleHeight ? nil : 1"))
        #expect(source.contains("usesFlexibleHeight ? nil : 2"))
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
