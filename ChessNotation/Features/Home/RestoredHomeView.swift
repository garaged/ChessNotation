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
                Text("Train faster, read better, play smarter.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(1)
            }
            .padding(HomeLayout.heroPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(
            height: horizontalSizeClass == .regular
                ? HomeLayout.regularHeroHeight
                : HomeLayout.compactHeroHeight
        )
        .clipShape(RoundedRectangle(cornerRadius: PremiumDesign.Radius.large))
        .overlay {
            RoundedRectangle(cornerRadius: PremiumDesign.Radius.large)
                .stroke(PremiumDesign.Accent.brand.color.opacity(0.24), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var trainingFamilies: some View {
        VStack(alignment: .leading, spacing: HomeLayout.headerToContentSpacing) {
            HomeSectionHeader(
                title: "Training",
                subtitle: "Choose a focused family and continue from there."
            )

            LazyVGrid(columns: familyColumns, spacing: HomeLayout.gridSpacing) {
                NavigationLink {
                    GameLibraryView(libraryService: libraryService, launchMode: .practice)
                        .environment(appSettings)
                } label: {
                    familyTile(
                        title: "Notation Training",
                        subtitle: "Practice SAN from real games.",
                        systemImage: "pencil.and.list.clipboard",
                        tint: PremiumDesign.Accent.practice.color,
                        texture: .board,
                        assetName: PremiumAssetName.notationTrainingTile,
                        accessibilityIdentifier: "home.notationTrainingTile"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.notationTrainingTile")

                NavigationLink {
                    GameLibraryView(libraryService: libraryService, launchMode: .timed)
                        .environment(appSettings)
                } label: {
                    familyTile(
                        title: "Timed Training",
                        subtitle: "Build speed under a clock.",
                        systemImage: "timer",
                        tint: PremiumDesign.Accent.timed.color,
                        texture: .speed,
                        assetName: PremiumAssetName.timedNotationTile,
                        accessibilityIdentifier: "home.timedNotationTile"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.timedNotationTile")

                NavigationLink {
                    BoardSkillsFamilyView()
                        .environment(appSettings)
                } label: {
                    familyTile(
                        title: "Board Skills",
                        subtitle: "Learn squares and movement.",
                        systemImage: "checkerboard.rectangle",
                        tint: PremiumDesign.Accent.square.color,
                        texture: .target,
                        assetName: PremiumAssetName.squareRecognitionTile,
                        accessibilityIdentifier: "home.boardSkillsLink"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.boardSkillsLink")

                NavigationLink {
                    PositionRecallLauncherView()
                } label: {
                    familyTile(
                        title: "Position Recall",
                        subtitle: "Rebuild positions from memory.",
                        systemImage: "brain.head.profile",
                        tint: PremiumDesign.Accent.learning.color,
                        texture: .board,
                        assetName: PremiumAssetName.positionRecallTile,
                        showsFallbackIcon: false,
                        artworkScale: HomeLayout.positionRecallArtworkScale,
                        accessibilityIdentifier: "home.positionRecallLink"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.positionRecallLink")
            }
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
        artworkScale: CGFloat = 1,
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
            artworkScale: artworkScale,
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
    static let heroPadding: CGFloat = 18
    static let artworkHeight: CGFloat = 100
    static let titleRegionHeight: CGFloat = 22
    static let subtitleRegionHeight: CGFloat = 36
    static let cardHeight: CGFloat = 188
    static let cardRadius: CGFloat = 16
    static let positionRecallArtworkScale: CGFloat = 0.9
}

private enum FamilyScreenLayout {
    static let maximumContentWidth: CGFloat = 640
    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 22
    static let cardRadius: CGFloat = 16
    static let artworkSize: CGFloat = 72
    static let drillRowHeight: CGFloat = 100
    static let quickStartHeight: CGFloat = 132
}

private struct BoardSkillsFamilyView: View {
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FamilyScreenLayout.sectionSpacing) {
                familySummary
                quickStart
                drillChoices
            }
            .frame(maxWidth: FamilyScreenLayout.maximumContentWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, FamilyScreenLayout.horizontalPadding)
            .padding(.vertical, 20)
        }
        .premiumScreenBackground()
        .navigationTitle("Board Skills")
        .navigationBarTitleDisplayMode(.inline)
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

private struct FamilyQuickStartCard: View {
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
                        .lineLimit(2)
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
        .frame(height: FamilyScreenLayout.quickStartHeight)
        .clipShape(RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius)
                .stroke(tint.opacity(0.4), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius))
    }
}

private struct FamilyGameRow: View {
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
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(PremiumDesign.secondaryText)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: FamilyScreenLayout.drillRowHeight)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: FamilyScreenLayout.cardRadius))
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
    var artworkScale: CGFloat = 1
    let accessibilityIdentifier: String

    private var usesFlexibleHeight: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            artwork
                .frame(maxWidth: .infinity)
                .frame(height: HomeLayout.artworkHeight)

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

    private var artwork: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.opacity(0.16)

            PremiumArtworkView(
                assetName: assetName,
                fallbackIdentifier: "premiumAssetFallback.\(assetName)"
            ) {
                HomeMenuTexture(tint: tint, style: texture)
            }
            .scaleEffect(artworkScale)

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
