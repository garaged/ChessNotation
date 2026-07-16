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
            ZStack(alignment: .topTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        hero
                        primaryTrainingMenu
                        miniGamesMenu
                        secondaryActions
                    }
                    .frame(maxWidth: HomeTileLayout.maximumContentWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
                .premiumScreenBackground()

                settingsButton
            }
            .sheet(isPresented: $isShowingAppearanceSettings) {
                AppearanceSettingsView()
                    .environment(appSettings)
            }
        }
    }

    private var settingsButton: some View {
        Button {
            isShowingAppearanceSettings = true
        } label: {
            Label("Settings", systemImage: "slider.horizontal.3")
                .labelStyle(.iconOnly)
                .font(.headline.weight(.semibold))
                .foregroundStyle(PremiumDesign.primaryText)
                .frame(width: 42, height: 42)
                .background(PremiumDesign.elevatedSurface)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(PremiumDesign.stroke, lineWidth: 1)
                }
        }
        .padding(.top, 30)
        .padding(.trailing, horizontalPadding + 12)
        .accessibilityIdentifier("home.appearanceButton")
    }

    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .regular ? 28 : 18
    }

    private var usesSingleColumn: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var usesRegularWidthLayout: Bool {
        horizontalSizeClass == .regular && !usesSingleColumn
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            PremiumArtworkView(assetName: PremiumAssetName.homeHero, fallbackIdentifier: "premiumAssetFallback.homeHero") {
                HomeMenuTexture(tint: PremiumDesign.Accent.brand.color, style: .board)
                    .overlay {
                        LinearGradient(
                            colors: [.clear, PremiumDesign.backgroundBottom.opacity(0.78)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("ChessNotation")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(PremiumDesign.primaryText)

                Text("Train faster, read better, play smarter.")
                    .font(.subheadline)
                    .foregroundStyle(PremiumDesign.secondaryText)
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, minHeight: usesRegularWidthLayout ? 250 : 210, alignment: .bottomLeading)
        .clipShape(RoundedRectangle(cornerRadius: PremiumDesign.Radius.large))
        .overlay {
            RoundedRectangle(cornerRadius: PremiumDesign.Radius.large)
                .stroke(PremiumDesign.Accent.brand.color.opacity(0.18), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var primaryTrainingMenu: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(title: "Training", subtitle: "Full-game notation practice from the bundled library.")

            LazyVGrid(columns: trainingColumns, spacing: HomeTileLayout.gridSpacing) {
                NavigationLink {
                    GameLibraryView(libraryService: libraryService, launchMode: .practice)
                        .environment(appSettings)
                } label: {
                    HomeMenuTile(
                        title: "Notation Training",
                        subtitle: "Sharpen SAN from real games.",
                        systemImage: "pencil.and.list.clipboard",
                        tint: PremiumDesign.Accent.practice.color,
                        texture: .board,
                        assetName: PremiumAssetName.notationTrainingTile,
                        layout: .vertical,
                        accessibilityIdentifier: "home.notationTrainingTile"
                    )
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.notationTrainingTile")

                NavigationLink {
                    GameLibraryView(libraryService: libraryService, launchMode: .timed)
                        .environment(appSettings)
                } label: {
                    HomeMenuTile(
                        title: "Timed Notation",
                        subtitle: "Race the clock and build speed.",
                        systemImage: "timer",
                        tint: PremiumDesign.Accent.timed.color,
                        texture: .speed,
                        assetName: PremiumAssetName.timedNotationTile,
                        layout: .vertical,
                        accessibilityIdentifier: "home.timedNotationTile"
                    )
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.timedNotationTile")
            }
        }
    }

    @ViewBuilder
    private var miniGamesMenu: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(title: "Mini-games", subtitle: "Short playable drills for coordinates, movement, and memory.")
                .accessibilityIdentifier("home.miniGamesHeader")

            if usesRegularWidthLayout {
                LazyVGrid(columns: miniGameColumns, spacing: HomeTileLayout.gridSpacing) {
                    miniGameLinks(layout: .vertical)
                }
            } else {
                VStack(spacing: HomeTileLayout.gridSpacing) {
                    miniGameLinks(layout: .horizontal)
                }
            }
        }
    }

    @ViewBuilder
    private func miniGameLinks(layout: HomeMenuTile.Layout) -> some View {
        NavigationLink {
            SquareRecognitionSetupView(historyStore: AppEnvironment.makeSquareRecognitionHistoryStore())
                .environment(appSettings)
        } label: {
            HomeMenuTile(
                title: "Square Recognition",
                subtitle: "Tap coordinates by sight.",
                systemImage: "scope",
                tint: PremiumDesign.Accent.square.color,
                texture: .target,
                assetName: PremiumAssetName.squareRecognitionTile,
                layout: layout,
                accessibilityIdentifier: "home.squareRecognitionLink"
            )
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.squareRecognitionLink")

        NavigationLink {
            PieceMovementLauncherView()
        } label: {
            HomeMenuTile(
                title: "Piece Movement",
                subtitle: "Select every geometric destination.",
                systemImage: "arrow.up.left.and.arrow.down.right",
                tint: PremiumDesign.Accent.learning.color,
                texture: .board,
                assetName: PremiumAssetName.pieceMovementTile,
                showsFallbackIcon: false,
                layout: layout,
                accessibilityIdentifier: "home.pieceMovementLink"
            )
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.pieceMovementLink")

        NavigationLink {
            PositionRecallLauncherView()
        } label: {
            HomeMenuTile(
                title: "Position Recall",
                subtitle: "Study, hide, and rebuild the board.",
                systemImage: "brain.head.profile",
                tint: PremiumDesign.Accent.timed.color,
                texture: .target,
                assetName: PremiumAssetName.positionRecallTile,
                showsFallbackIcon: false,
                layout: layout,
                accessibilityIdentifier: "home.positionRecallLink"
            )
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.positionRecallLink")
    }

    private var secondaryActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(title: "Help", subtitle: "Learn the modes, notation rules, and app controls.")

            NavigationLink {
                InstructionsView()
            } label: {
                HomeUtilityRow(
                    title: "Instructions",
                    subtitle: "Open the ChessNotation guide.",
                    systemImage: "book.pages"
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.instructionsLink")
        }
    }

    private var trainingColumns: [GridItem] {
        let count = usesSingleColumn ? 1 : 2
        return Array(
            repeating: GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: HomeTileLayout.gridSpacing, alignment: .top),
            count: count
        )
    }

    private var miniGameColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: HomeTileLayout.gridSpacing, alignment: .top),
            count: 3
        )
    }
}

private enum HomeTileLayout {
    static let gridSpacing: CGFloat = 16
    static let maximumContentWidth: CGFloat = 1080
    static let verticalArtworkHeight: CGFloat = 112
    static let horizontalArtworkWidth: CGFloat = 112
    static let horizontalArtworkHeight: CGFloat = 88
    static let verticalCardHeight: CGFloat = 224
    static let horizontalCardHeight: CGFloat = 116
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

private struct HomeUtilityRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.headline.weight(.semibold))
                .foregroundStyle(PremiumDesign.Accent.neutral.color)
                .frame(width: 42, height: 42)
                .background(PremiumDesign.Accent.neutral.color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PremiumDesign.primaryText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(PremiumDesign.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(PremiumDesign.secondaryText)
                .accessibilityHidden(true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(PremiumDesign.stroke, lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
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

    enum Layout {
        case vertical
        case horizontal
    }

    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let texture: Texture
    let assetName: String
    var showsFallbackIcon = true
    let layout: Layout
    let accessibilityIdentifier: String

    private var usesFlexibleHeight: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        Group {
            switch layout {
            case .vertical:
                verticalBody
            case .horizontal:
                horizontalBody
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(0.24), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .clipped()
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private var verticalBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            artwork
                .frame(maxWidth: .infinity)
                .frame(height: HomeTileLayout.verticalArtworkHeight)

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(PremiumDesign.primaryText)
                .lineLimit(usesFlexibleHeight ? nil : 2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(PremiumDesign.secondaryText)
                .lineLimit(usesFlexibleHeight ? nil : 3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            arrow
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .frame(height: usesFlexibleHeight ? nil : HomeTileLayout.verticalCardHeight, alignment: .topLeading)
    }

    private var horizontalBody: some View {
        HStack(spacing: 14) {
            artwork
                .frame(width: HomeTileLayout.horizontalArtworkWidth, height: HomeTileLayout.horizontalArtworkHeight)
                .layoutPriority(1)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PremiumDesign.primaryText)
                    .lineLimit(usesFlexibleHeight ? nil : 2)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(PremiumDesign.secondaryText)
                    .lineLimit(usesFlexibleHeight ? nil : 3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            arrow
        }
        .padding(14)
        .frame(height: usesFlexibleHeight ? nil : HomeTileLayout.horizontalCardHeight, alignment: .leading)
    }

    private var artwork: some View {
        ZStack(alignment: .bottomTrailing) {
            PremiumArtworkView(assetName: assetName, fallbackIdentifier: "premiumAssetFallback.\(assetName)") {
                HomeMenuTexture(tint: tint, style: texture)
            }

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.3)],
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
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var arrow: some View {
        Image(systemName: "arrow.right")
            .font(.caption.weight(.bold))
            .foregroundStyle(tint)
            .frame(width: 28, height: 28)
            .background(tint.opacity(0.14))
            .clipShape(Circle())
            .accessibilityHidden(true)
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
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 6), spacing: 0) {
                    ForEach(0..<18, id: \.self) { index in
                        Rectangle()
                            .fill((index + index / 6).isMultiple(of: 2) ? tint.opacity(0.17) : Color.primary.opacity(0.04))
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
