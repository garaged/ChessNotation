import SwiftUI

struct RestoredHomeView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isShowingAppearanceSettings = false

    private let libraryService: GameLibraryProviding

    init(libraryService: GameLibraryProviding = BundledGameLibraryService()) {
        self.libraryService = libraryService
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HomeLayout.sectionSpacing) {
                    hero
                    trainingFamilies
                    helpSection
                }
                .frame(maxWidth: HomeLayout.maximumContentWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, HomeLayout.topPadding)
                .padding(.bottom, HomeLayout.bottomPadding)
            }
            .premiumScreenBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAppearanceSettings = true
                    } label: {
                        Label("Settings", systemImage: "slider.horizontal.3")
                    }
                    .accessibilityIdentifier("home.appearanceButton")
                }
            }
            .toolbarBackground(PremiumDesign.backgroundTop, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $isShowingAppearanceSettings) {
                AppearanceSettingsView()
                    .environment(appSettings)
            }
        }
    }

    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .regular
            ? HomeLayout.regularHorizontalPadding
            : HomeLayout.compactHorizontalPadding
    }

    private var familyColumnCount: Int {
        dynamicTypeSize.isAccessibilitySize ? 1 : 2
    }

    private var familyColumns: [GridItem] {
        Array(
            repeating: GridItem(
                .flexible(minimum: 0, maximum: .infinity),
                spacing: HomeLayout.gridSpacing,
                alignment: .top
            ),
            count: familyColumnCount
        )
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            PremiumArtworkView(
                assetName: PremiumAssetName.homeHero,
                fallbackIdentifier: "premiumAssetFallback.homeHero"
            ) {
                HomeMenuTexture(tint: PremiumDesign.Accent.brand.color, style: .board)
            }

            LinearGradient(
                colors: [Color.black.opacity(0.05), Color.black.opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 5) {
                Text("ChessNotation")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.62 : 1)
                Text("Train faster, read better, play smarter.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HomeLayout.heroPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight)
        .clipShape(RoundedRectangle(cornerRadius: PremiumDesign.Radius.large))
        .overlay {
            RoundedRectangle(cornerRadius: PremiumDesign.Radius.large)
                .stroke(PremiumDesign.Accent.brand.color.opacity(0.24), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var heroHeight: CGFloat {
        if dynamicTypeSize.isAccessibilitySize {
            return horizontalSizeClass == .regular
                ? HomeLayout.accessibilityRegularHeroHeight
                : HomeLayout.accessibilityCompactHeroHeight
        }

        return horizontalSizeClass == .regular
            ? HomeLayout.regularHeroHeight
            : HomeLayout.compactHeroHeight
    }

    private var trainingFamilies: some View {
        VStack(alignment: .leading, spacing: HomeLayout.headerToContentSpacing) {
            HomeSectionHeader(
                title: "Training",
                subtitle: "Choose a focused family and continue from there."
            )

            LazyVGrid(columns: familyColumns, spacing: HomeLayout.gridSpacing) {
                ForEach(GameFamilyCatalog.productionFamilies, id: \.id) { family in
                    NavigationLink {
                        familyDestination(for: family)
                    } label: {
                        let visual = familyVisuals(for: family.id)
                        familyTile(
                            title: family.title,
                            subtitle: family.purpose,
                            systemImage: visual.systemImage,
                            tint: visual.tint,
                            texture: visual.texture,
                            assetName: visual.assetName,
                            showsFallbackIcon: family.id != .positionRecall,
                            accessibilityIdentifier: visual.accessibilityIdentifier
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(familyVisuals(for: family.id).accessibilityIdentifier)
                }
            }
        }
    }

    @ViewBuilder
    private func familyDestination(for family: TrainingFamily) -> some View {
        switch family.id {
        case .notationTraining:
            NotationTrainingFamilyView(
                family: family,
                libraryService: libraryService,
                historyStore: AppEnvironment.makeNotationTrainingHistoryStore()
            )
            .environment(appSettings)
        case .timedTraining:
            TimedTrainingFamilyView(
                family: family,
                libraryService: libraryService,
                historyStore: AppEnvironment.makeNotationTrainingHistoryStore()
            )
            .environment(appSettings)
        case .boardSkills:
            BoardSkillsFamilyView(family: family)
                .environment(appSettings)
        case .positionRecall:
            PositionRecallFamilyView(family: family)
        }
    }

    private func familyVisuals(
        for id: TrainingFamilyID
    ) -> (
        systemImage: String,
        tint: Color,
        texture: HomeMenuTile.Texture,
        assetName: String,
        accessibilityIdentifier: String
    ) {
        switch id {
        case .notationTraining:
            return (
                "pencil.and.list.clipboard",
                PremiumDesign.Accent.practice.color,
                .board,
                PremiumAssetName.notationTrainingTile,
                "home.notationTrainingTile"
            )
        case .timedTraining:
            return (
                "timer",
                PremiumDesign.Accent.timed.color,
                .speed,
                PremiumAssetName.timedNotationTile,
                "home.timedNotationTile"
            )
        case .boardSkills:
            return (
                "checkerboard.rectangle",
                PremiumDesign.Accent.square.color,
                .target,
                PremiumAssetName.squareRecognitionTile,
                "home.boardSkillsLink"
            )
        case .positionRecall:
            return (
                "brain.head.profile",
                PremiumDesign.Accent.learning.color,
                .board,
                PremiumAssetName.positionRecallTile,
                "home.positionRecallLink"
            )
        }
    }

    private func familyTile(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        texture: HomeMenuTile.Texture,
        assetName: String,
        showsFallbackIcon: Bool = true,
        accessibilityIdentifier: String
    ) -> some View {
        HomeMenuTile(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            tint: tint,
            texture: texture,
            assetName: assetName,
            showsFallbackIcon: showsFallbackIcon,
            accessibilityIdentifier: accessibilityIdentifier
        )
        .frame(maxWidth: .infinity)
    }

    private var helpSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.headerToContentSpacing) {
            HomeSectionHeader(
                title: "Help",
                subtitle: "Learn notation rules, modes, and app controls."
            )

            if dynamicTypeSize.isAccessibilitySize {
                instructionsLink
            } else {
                GeometryReader { proxy in
                    let cardWidth = max(0, (proxy.size.width - HomeLayout.gridSpacing) / 2)
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)
                        instructionsLink
                            .frame(width: cardWidth)
                        Spacer(minLength: 0)
                    }
                }
                .frame(height: HomeLayout.cardHeight)
            }
        }
    }

    private var instructionsLink: some View {
        NavigationLink {
            InstructionsView()
        } label: {
            HomeMenuTile(
                title: "Instructions",
                subtitle: "Learn notation rules and controls.",
                systemImage: "book.pages",
                tint: PremiumDesign.Accent.neutral.color,
                texture: .book,
                assetName: PremiumAssetName.instructionsTile,
                accessibilityIdentifier: "home.instructionsLink"
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.instructionsLink")
    }
}

private enum HomeLayout {
    static let gridSpacing: CGFloat = 20
    static let sectionSpacing: CGFloat = 28
    static let headerToContentSpacing: CGFloat = 12
    static let compactHorizontalPadding: CGFloat = 20
    static let regularHorizontalPadding: CGFloat = 32
    static let topPadding: CGFloat = 12
    static let bottomPadding: CGFloat = 36
    static let maximumContentWidth: CGFloat = 740
    static let compactHeroHeight: CGFloat = 156
    static let regularHeroHeight: CGFloat = 204
    static let accessibilityCompactHeroHeight: CGFloat = 176
    static let accessibilityRegularHeroHeight: CGFloat = 224
    static let heroPadding: CGFloat = 18
    static let artworkHeight: CGFloat = 100
    static let artworkAspectRatio: CGFloat = 9.0 / 7.0
    static let titleRegionHeight: CGFloat = 22
    static let subtitleRegionHeight: CGFloat = 36
    static let cardHeight: CGFloat = 188
    static let cardRadius: CGFloat = 16
}

private enum FamilyScreenLayout {
    static let maximumContentWidth: CGFloat = 640
    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 22
    static let cardRadius: CGFloat = 16
    static let artworkSize: CGFloat = 72
    static let drillRowHeight: CGFloat = 100
    static let accessibilityDrillRowHeight: CGFloat = 348
    static let quickStartHeight: CGFloat = 132
}

private struct NotationTrainingFamilyView: View {
    @Environment(AppSettings.self) private var appSettings

    let family: TrainingFamily
    let libraryService: GameLibraryProviding
    let historyStore: NotationTrainingHistoryStoring

    var body: some View {
        FamilyScreenScaffold(title: family.title) {
            FamilySummaryView(title: "Read and write SAN", subtitle: family.purpose)

            NavigationLink {
                GameLibraryView(
                    libraryService: libraryService,
                    launchMode: .practice,
                    historyStore: historyStore
                )
                .environment(appSettings)
            } label: {
                FamilyQuickStartCard(
                    title: "Quick Start",
                    subtitle: "Open the full-game library and start untimed notation training.",
                    assetName: PremiumAssetName.notationTrainingTile,
                    systemImage: "play.fill",
                    tint: PremiumDesign.Accent.practice.color
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("notationFamily.quickStart")

            VStack(alignment: .leading, spacing: 12) {
                FamilySectionTitle("Choose a notation drill")

                ForEach(family.entries, id: \.id) { entry in
                    if entry.id == .fullGame {
                        NavigationLink {
                            GameLibraryView(
                                libraryService: libraryService,
                                launchMode: .practice,
                                historyStore: historyStore
                            )
                            .environment(appSettings)
                        } label: {
                            FamilyGameRow(
                                title: entry.title,
                                subtitle: entry.purpose,
                                assetName: PremiumAssetName.notationTrainingTile,
                                systemImage: "pencil.and.list.clipboard",
                                tint: PremiumDesign.Accent.practice.color
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("notationFamily.fullGame")
                    } else {
                        FamilyUnavailableRow(entry: entry, tint: PremiumDesign.Accent.practice.color)
                    }
                }
            }

            FamilySecondaryActions {
                NavigationLink {
                    NotationTrainingHistoryView(launchMode: .practice, historyStore: historyStore)
                } label: {
                    Label("Notation history", systemImage: "chart.xyaxis.line")
                }
                .accessibilityIdentifier("notationFamily.history")
            }
        }
    }
}

private struct TimedTrainingFamilyView: View {
    @Environment(AppSettings.self) private var appSettings

    let family: TrainingFamily
    let libraryService: GameLibraryProviding
    let historyStore: NotationTrainingHistoryStoring

    var body: some View {
        FamilyScreenScaffold(title: family.title) {
            FamilySummaryView(title: "Clocked notation practice", subtitle: family.purpose)

            NavigationLink {
                GameLibraryView(
                    libraryService: libraryService,
                    launchMode: .timed,
                    historyStore: historyStore
                )
                .environment(appSettings)
            } label: {
                FamilyQuickStartCard(
                    title: "Quick Start",
                    subtitle: "Open the timed library and choose a classic duration.",
                    assetName: PremiumAssetName.timedNotationTile,
                    systemImage: "timer",
                    tint: PremiumDesign.Accent.timed.color
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("timedFamily.quickStart")

            VStack(alignment: .leading, spacing: 12) {
                FamilySectionTitle("Choose timed training")

                ForEach(family.entries, id: \.id) { entry in
                    if entry.id == .classicTimed {
                        NavigationLink {
                            GameLibraryView(
                                libraryService: libraryService,
                                launchMode: .timed,
                                historyStore: historyStore
                            )
                            .environment(appSettings)
                        } label: {
                            FamilyGameRow(
                                title: entry.title,
                                subtitle: entry.purpose,
                                assetName: PremiumAssetName.timedNotationTile,
                                systemImage: "timer",
                                tint: PremiumDesign.Accent.timed.color
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("timedFamily.classicTimed")
                    } else {
                        FamilyUnavailableRow(entry: entry, tint: PremiumDesign.Accent.timed.color)
                    }
                }
            }

            FamilySecondaryActions {
                NavigationLink {
                    NotationTrainingHistoryView(launchMode: .timed, historyStore: historyStore)
                } label: {
                    Label("Timed history", systemImage: "chart.xyaxis.line")
                }
                .accessibilityIdentifier("timedFamily.history")
            }
        }
    }
}

private struct BoardSkillsFamilyView: View {
    @Environment(AppSettings.self) private var appSettings

    let family: TrainingFamily

    var body: some View {
        FamilyScreenScaffold(title: family.title) {
            familySummary
            quickStart
            drillChoices
            FamilySecondaryActions {
                NavigationLink {
                    SquareRecognitionHistoryView(historyStore: AppEnvironment.makeSquareRecognitionHistoryStore())
                } label: {
                    Label("Square Recognition history", systemImage: "chart.xyaxis.line")
                }
                .accessibilityIdentifier("boardSkills.squareRecognitionHistory")
            }
        }
    }

    private var familySummary: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Coordinate and movement drills")
                .font(.title3.weight(.bold))
                .foregroundStyle(PremiumDesign.primaryText)
            Text("Build board fluency with short, focused exercises.")
                .font(.subheadline)
                .foregroundStyle(PremiumDesign.secondaryText)
        }
        .accessibilityElement(children: .combine)
    }

    private var quickStart: some View {
        NavigationLink {
            SquareRecognitionSetupView(historyStore: AppEnvironment.makeSquareRecognitionHistoryStore())
                .environment(appSettings)
        } label: {
            FamilyQuickStartCard(
                title: "Quick Start",
                subtitle: "Start the recommended Square Recognition drill.",
                assetName: PremiumAssetName.squareRecognitionTile,
                systemImage: "scope",
                tint: PremiumDesign.Accent.square.color
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("boardSkills.quickStart")
    }

    private var drillChoices: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a drill")
                .font(.title3.weight(.bold))
                .foregroundStyle(PremiumDesign.primaryText)

            NavigationLink {
                SquareRecognitionSetupView(historyStore: AppEnvironment.makeSquareRecognitionHistoryStore())
                    .environment(appSettings)
            } label: {
                FamilyGameRow(
                    title: "Square Recognition",
                    subtitle: "Find coordinates quickly and accurately.",
                    assetName: PremiumAssetName.squareRecognitionTile,
                    systemImage: "scope",
                    tint: PremiumDesign.Accent.square.color
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.squareRecognitionLink")

            NavigationLink {
                PieceMovementLauncherView()
            } label: {
                FamilyGameRow(
                    title: "Piece Movement",
                    subtitle: "Identify every geometric destination.",
                    assetName: PremiumAssetName.pieceMovementTile,
                    systemImage: "arrow.up.left.and.arrow.down.right",
                    tint: PremiumDesign.Accent.learning.color
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.pieceMovementLink")
        }
    }
}

private struct PositionRecallFamilyView: View {
    let family: TrainingFamily

    var body: some View {
        FamilyScreenScaffold(title: family.title) {
            FamilySummaryView(title: "Memory reconstruction", subtitle: family.purpose)

            NavigationLink {
                PositionRecallLauncherView()
            } label: {
                FamilyQuickStartCard(
                    title: "Quick Start",
                    subtitle: "Study a beginner position, then rebuild every piece.",
                    assetName: PremiumAssetName.positionRecallTile,
                    systemImage: "brain.head.profile",
                    tint: PremiumDesign.Accent.learning.color
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("positionRecallFamily.quickStart")

            VStack(alignment: .leading, spacing: 12) {
                FamilySectionTitle("Choose a recall drill")

                ForEach(family.entries, id: \.id) { entry in
                    if entry.id == .reconstruction {
                        NavigationLink {
                            PositionRecallLauncherView()
                        } label: {
                            FamilyGameRow(
                                title: entry.title,
                                subtitle: entry.purpose,
                                assetName: PremiumAssetName.positionRecallTile,
                                systemImage: "square.grid.3x3",
                                tint: PremiumDesign.Accent.learning.color
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("positionRecallFamily.reconstruction")
                    } else {
                        FamilyUnavailableRow(entry: entry, tint: PremiumDesign.Accent.learning.color)
                    }
                }
            }

            FamilySecondaryActions {
                NavigationLink {
                    PositionRecallHistoryView(historyStore: PositionRecallReconstructionHistoryStore())
                } label: {
                    Label("Position Recall history", systemImage: "chart.xyaxis.line")
                }
                .accessibilityIdentifier("positionRecallFamily.history")
            }
        }
    }
}

private struct FamilyScreenScaffold<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FamilyScreenLayout.sectionSpacing) {
                content
            }
            .frame(maxWidth: FamilyScreenLayout.maximumContentWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, FamilyScreenLayout.horizontalPadding)
            .padding(.vertical, 20)
        }
        .premiumScreenBackground()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FamilySummaryView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(PremiumDesign.primaryText)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(PremiumDesign.secondaryText)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct FamilySectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(PremiumDesign.primaryText)
    }
}

private struct FamilySecondaryActions<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FamilySectionTitle("History")
            VStack(spacing: 10) {
                content
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FamilyQuickStartCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let subtitle: String
    let assetName: String
    let systemImage: String
    let tint: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            PremiumArtworkView(
                assetName: assetName,
                fallbackIdentifier: "premiumAssetFallback.\(assetName)"
            ) {
                ZStack {
                    tint.opacity(0.18)
                    Image(systemName: systemImage)
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(tint)
                }
            }

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "play.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.9))
                    .clipShape(Circle())
                    .accessibilityHidden(true)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(
            minHeight: FamilyScreenLayout.quickStartHeight,
            maxHeight: dynamicTypeSize.isAccessibilitySize ? nil : FamilyScreenLayout.quickStartHeight
        )
        .clipShape(RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius)
                .stroke(tint.opacity(0.4), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius))
    }
}

private struct FamilyGameRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let subtitle: String
    let assetName: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            PremiumArtworkView(
                assetName: assetName,
                fallbackIdentifier: "premiumAssetFallback.\(assetName)"
            ) {
                ZStack {
                    tint.opacity(0.14)
                    Image(systemName: systemImage)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(tint)
                }
            }
            .frame(width: FamilyScreenLayout.artworkSize, height: FamilyScreenLayout.artworkSize)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PremiumDesign.primaryText)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(PremiumDesign.secondaryText)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 14 : 0)
        .frame(maxWidth: .infinity)
        .frame(
            minHeight: dynamicTypeSize.isAccessibilitySize
                ? FamilyScreenLayout.accessibilityDrillRowHeight
                : FamilyScreenLayout.drillRowHeight,
            maxHeight: dynamicTypeSize.isAccessibilitySize ? nil : FamilyScreenLayout.drillRowHeight
        )
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius))
    }
}

private struct FamilyUnavailableRow: View {
    let entry: TrainingGameEntry
    let tint: Color

    private var unavailableText: (reason: String, recoveryAction: String) {
        if case let .unavailable(reason, recoveryAction) = entry.availability {
            return (reason, recoveryAction)
        }
        return ("Unavailable in this release.", "Choose another game in this family.")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "clock.badge")
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: FamilyScreenLayout.artworkSize, height: FamilyScreenLayout.artworkSize)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PremiumDesign.primaryText)
                Text(entry.purpose)
                    .font(.subheadline)
                    .foregroundStyle(PremiumDesign.secondaryText)
                Text("\(unavailableText.reason) \(unavailableText.recoveryAction)")
                    .font(.caption)
                    .foregroundStyle(PremiumDesign.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground).opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius)
                .stroke(tint.opacity(0.14), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.title), unavailable")
        .accessibilityHint(unavailableText.recoveryAction)
        .accessibilityIdentifier("family.unavailable.\(entry.id.rawValue)")
    }
}

private struct PieceMovementLauncherView: View {
    var body: some View {
        if let viewModel = PieceMovementViewModel(
            configuration: PieceMovementConfiguration(
                pieces: Set(TrainingPiece.allCases),
                difficulty: .beginner,
                orientation: .white,
                promptLimit: 8
            ),
            historyStore: PieceMovementHistoryStore()
        ) {
            PieceMovementGameView(viewModel: viewModel)
        } else {
            ContentUnavailableView(
                "Piece Movement Unavailable",
                systemImage: "exclamationmark.triangle",
                description: Text("No movement prompts could be generated.")
            )
        }
    }
}

private struct PositionRecallHistoryView: View {
    let historyStore: PositionRecallReconstructionHistoryStoring

    @State private var results: [PositionRecallSessionResult] = []
    @State private var loadError: String?

    var body: some View {
        List {
            if results.isEmpty, loadError == nil {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Completed reconstruction drills will appear here.")
                )
            } else {
                Section("Summary") {
                    metricRow("Sessions", "\(results.count)")
                    metricRow("Average accuracy", averageAccuracy.formatted(.percent.precision(.fractionLength(0))))
                    metricRow("Best streak", "\(results.map(\.bestStreak).max() ?? 0)")
                }

                Section("Sessions") {
                    ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Reconstruction \(index + 1)")
                                    .font(.headline)
                                Spacer()
                                Text(accuracy(for: result).formatted(.percent.precision(.fractionLength(0))))
                                    .font(.headline.monospacedDigit())
                            }
                            HStack {
                                Label("\(result.exactCount)/\(result.promptCount)", systemImage: "checklist")
                                Label("Best \(result.bestStreak)", systemImage: "flame")
                            }
                            .font(.caption)
                            .foregroundStyle(PremiumDesign.secondaryText)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            if let loadError {
                Text(loadError)
                    .foregroundStyle(PremiumDesign.Accent.danger.color)
            }
        }
        .listStyle(.insetGrouped)
        .premiumScreenBackground()
        .navigationTitle("Position Recall History")
        .task {
            loadHistory()
        }
    }

    private var averageAccuracy: Double {
        guard !results.isEmpty else { return 0 }
        return results.map(accuracy(for:)).reduce(0, +) / Double(results.count)
    }

    private func accuracy(for result: PositionRecallSessionResult) -> Double {
        guard result.promptCount > 0 else { return 0 }
        return Double(result.exactCount) / Double(result.promptCount)
    }

    private func loadHistory() {
        do {
            results = try historyStore.loadResults()
            loadError = nil
        } catch {
            results = []
            loadError = error.localizedDescription
        }
    }

    private func metricRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(PremiumDesign.primaryText)
            Spacer()
            Text(value)
                .foregroundStyle(PremiumDesign.secondaryText)
        }
    }
}

private struct PositionRecallLauncherView: View {
    var body: some View {
        if let viewModel = PositionRecallReconstructionViewModel(
            configuration: PositionRecallReconstructionConfiguration(
                difficulty: .beginner,
                orientation: .white,
                promptLimit: 5,
                studyDuration: 3
            ),
            snapshots: Self.snapshots,
            historyStore: PositionRecallReconstructionHistoryStore()
        ) {
            PositionRecallReconstructionView(viewModel: viewModel)
        } else {
            ContentUnavailableView(
                "Position Recall Unavailable",
                systemImage: "exclamationmark.triangle",
                description: Text("No recall prompts could be generated.")
            )
        }
    }

    private static var snapshots: [PositionRecallSnapshot] {
        [
            snapshot([
                placed(file: 4, rank: 3, piece: .king, side: .white),
                placed(file: 3, rank: 0, piece: .queen, side: .white),
                placed(file: 6, rank: 5, piece: .knight, side: .white),
                placed(file: 4, rank: 7, piece: .king, side: .black),
                placed(file: 0, rank: 7, piece: .rook, side: .black),
                placed(file: 2, rank: 4, piece: .bishop, side: .black)
            ]),
            snapshot([
                placed(file: 6, rank: 0, piece: .king, side: .white),
                placed(file: 5, rank: 2, piece: .bishop, side: .white),
                placed(file: 1, rank: 1, piece: .pawn, side: .white),
                placed(file: 6, rank: 7, piece: .king, side: .black),
                placed(file: 5, rank: 6, piece: .pawn, side: .black),
                placed(file: 7, rank: 5, piece: .rook, side: .black)
            ])
        ]
    }

    private static func snapshot(_ pieces: [PositionRecallPlacedPiece?]) -> PositionRecallSnapshot {
        PositionRecallSnapshot(pieces: pieces.compactMap { $0 })
    }

    private static func placed(
        file: Int,
        rank: Int,
        piece: TrainingPiece,
        side: TrainingSide
    ) -> PositionRecallPlacedPiece? {
        guard let square = ChessSquare(file: file, rank: rank) else { return nil }
        return PositionRecallPlacedPiece(
            square: square,
            piece: PositionRecallPiece(piece: piece, side: side)
        )
    }
}

private struct HomeSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(PremiumDesign.primaryText)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(PremiumDesign.secondaryText)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct HomeMenuTile: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    enum Texture {
        case board
        case speed
        case target
        case book
    }

    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let texture: Texture
    let assetName: String
    var showsFallbackIcon = true
    let accessibilityIdentifier: String

    private var usesFlexibleHeight: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            artworkRegion

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(PremiumDesign.primaryText)
                .lineLimit(usesFlexibleHeight ? nil : 1)
                .frame(
                    maxWidth: .infinity,
                    minHeight: usesFlexibleHeight ? nil : HomeLayout.titleRegionHeight,
                    alignment: .topLeading
                )

            HStack(alignment: .bottom, spacing: 8) {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(PremiumDesign.secondaryText)
                    .lineLimit(usesFlexibleHeight ? nil : 2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: usesFlexibleHeight ? nil : HomeLayout.subtitleRegionHeight,
                        alignment: .topLeading
                    )

                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)
                    .frame(width: 28, height: 28)
                    .background(tint.opacity(0.16))
                    .clipShape(Circle())
                    .accessibilityHidden(true)
            }
        }
        .padding(12)
        .frame(
            maxWidth: .infinity,
            minHeight: usesFlexibleHeight ? nil : HomeLayout.cardHeight,
            maxHeight: usesFlexibleHeight ? nil : HomeLayout.cardHeight,
            alignment: .topLeading
        )
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: HomeLayout.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HomeLayout.cardRadius)
                .stroke(tint.opacity(0.26), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: HomeLayout.cardRadius))
        .clipped()
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private var artworkRegion: some View {
        GeometryReader { proxy in
            let artworkWidth = min(
                proxy.size.width,
                HomeLayout.artworkHeight * HomeLayout.artworkAspectRatio
            )
            let artworkHeight = artworkWidth / HomeLayout.artworkAspectRatio

            artwork
                .frame(width: artworkWidth, height: artworkHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: HomeLayout.artworkHeight)
    }

    private var artwork: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.opacity(0.16)

            PremiumArtworkView(
                assetName: assetName,
                fallbackIdentifier: "premiumAssetFallback.\(assetName)"
            ) {
                HomeMenuTexture(tint: tint, style: texture)
            }

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.28)],
                startPoint: .top,
                endPoint: .bottom
            )

            if showsFallbackIcon && !PremiumAssetAvailability.hasImage(named: assetName) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.86))
                    .clipShape(Circle())
                    .padding(10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 11))
    }
}

private struct HomeMenuTexture: View {
    let tint: Color
    let style: HomeMenuTile.Texture

    var body: some View {
        switch style {
        case .board:
            GeometryReader { proxy in
                let squareSize = proxy.size.width / 6
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 6),
                    spacing: 0
                ) {
                    ForEach(0..<18, id: \.self) { index in
                        Rectangle()
                            .fill(
                                (index + index / 6).isMultiple(of: 2)
                                    ? tint.opacity(0.17)
                                    : Color.primary.opacity(0.04)
                            )
                            .frame(height: squareSize)
                    }
                }
                .background(tint.opacity(0.08))
            }
        case .speed:
            ZStack(alignment: .leading) {
                tint.opacity(0.1)
                ForEach(0..<5, id: \.self) { index in
                    Capsule()
                        .fill(tint.opacity(0.12))
                        .frame(width: CGFloat(54 + index * 20), height: 8)
                        .offset(x: CGFloat(index * 8), y: CGFloat(index * 15 - 28))
                }
            }
        case .target:
            ZStack {
                tint.opacity(0.1)
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(tint.opacity(Double(4 - index) * 0.08), lineWidth: 2)
                        .padding(CGFloat(index * 14 + 10))
                }
            }
        case .book:
            ZStack {
                tint.opacity(0.1)
                RoundedRectangle(cornerRadius: 8)
                    .fill(tint.opacity(0.12))
                    .frame(width: 82, height: 56)
                    .rotationEffect(.degrees(-7))
                RoundedRectangle(cornerRadius: 8)
                    .stroke(tint.opacity(0.35), lineWidth: 2)
                    .frame(width: 82, height: 56)
                    .rotationEffect(.degrees(-7))
            }
        }
    }
}
