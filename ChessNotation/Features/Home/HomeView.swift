import SwiftUI

struct HomeView: View {
    @Environment(AppSettings.self) private var appSettings
    @State private var isShowingAppearanceSettings = false

    private let libraryService: GameLibraryProviding

    init(libraryService: GameLibraryProviding = BundledGameLibraryService()) {
        self.libraryService = libraryService
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        hero
                        modeTiles
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
                .premiumScreenBackground()

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
                .padding(.trailing, 30)
                .accessibilityIdentifier("home.appearanceButton")
            }
            .sheet(isPresented: $isShowingAppearanceSettings) {
                AppearanceSettingsView()
                    .environment(appSettings)
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            PremiumArtworkView(assetName: PremiumAssetName.homeHero, fallbackIdentifier: "premiumAssetFallback.homeHero") {
                BoardTexture(tint: PremiumDesign.Accent.brand.color)
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
        .frame(maxWidth: .infinity, minHeight: 210, alignment: .bottomLeading)
        .clipShape(RoundedRectangle(cornerRadius: PremiumDesign.Radius.large))
        .overlay {
            RoundedRectangle(cornerRadius: PremiumDesign.Radius.large)
                .stroke(PremiumDesign.Accent.brand.color.opacity(0.18), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var modeTiles: some View {
        LazyVGrid(columns: tileColumns, spacing: 14) {
            NavigationLink {
                GameLibraryView(libraryService: libraryService, launchMode: .practice)
                    .environment(appSettings)
            } label: {
                HomeModeTile(
                    title: "Notation Training",
                    subtitle: "Sharpen SAN from real games.",
                    systemImage: "pencil.and.list.clipboard",
                    tint: PremiumDesign.Accent.practice.color,
                    texture: .board,
                    assetName: PremiumAssetName.notationTrainingTile
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.notationTrainingTile")

            NavigationLink {
                GameLibraryView(libraryService: libraryService, launchMode: .timed)
                    .environment(appSettings)
            } label: {
                HomeModeTile(
                    title: "Timed Notation",
                    subtitle: "Race the clock and build speed.",
                    systemImage: "timer",
                    tint: PremiumDesign.Accent.timed.color,
                    texture: .speed,
                    assetName: PremiumAssetName.timedNotationTile
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.timedNotationTile")

            NavigationLink {
                SquareRecognitionSetupView(historyStore: AppEnvironment.makeSquareRecognitionHistoryStore())
                    .environment(appSettings)
            } label: {
                HomeModeTile(
                    title: "Square Recognition",
                    subtitle: "Tap coordinates by sight.",
                    systemImage: "scope",
                    tint: PremiumDesign.Accent.square.color,
                    texture: .target,
                    assetName: PremiumAssetName.squareRecognitionTile
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.squareRecognitionLink")

            NavigationLink {
                InstructionsView()
            } label: {
                HomeModeTile(
                    title: "Instructions",
                    subtitle: "Learn modes, notation, and settings.",
                    systemImage: "book.pages",
                    tint: PremiumDesign.Accent.learning.color,
                    texture: .book,
                    assetName: PremiumAssetName.instructionsTile
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.instructionsLink")
        }
    }

    private var tileColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 158), spacing: 14)]
    }

}

struct GameLibraryView: View {
    @Environment(AppSettings.self) private var appSettings
    @State private var games: [NotationGame] = []
    @State private var loadError: String?
    @State private var selectedRoute: GameTrainingRoute?
    @State private var timedGameSelection: NotationGame?
    @State private var hasLoadedGames = false
    @State private var filters = GameLibraryFilters()

    private let libraryService: GameLibraryProviding
    private let launchMode: GameLibraryLaunchMode

    init(libraryService: GameLibraryProviding, launchMode: GameLibraryLaunchMode) {
        self.libraryService = libraryService
        self.launchMode = launchMode
    }

    var body: some View {
        List {
            Section {
                Button {
                    launchRandomFilteredGame()
                } label: {
                    RandomFilteredGameRow(launchMode: launchMode)
                }
                .disabled(filteredGames.isEmpty)
                .accessibilityIdentifier("library.randomFilteredGameButton")
            }

            Section("Launch Mode") {
                LaunchModeSummary(launchMode: launchMode)
            }

            Section("Filters") {
                Picker("Level", selection: $filters.difficulty) {
                    ForEach(DifficultyFilter.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("home.levelFilter")
                .accessibilityIdentifier("library.levelFilter")

                if availableOpeningFilters.count > 1 {
                    Picker("Opening", selection: $filters.opening) {
                        ForEach(availableOpeningFilters) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                    .accessibilityIdentifier("library.openingFilter")
                }
            }

            Section("Library") {
                if isLoadingLibrary {
                    ProgressView("Loading games...")
                        .accessibilityIdentifier("library.loadingGames")
                }

                if filteredGames.isEmpty, !isLoadingLibrary {
                    ContentUnavailableView(
                        "No Matching Games",
                        systemImage: "magnifyingglass",
                        description: Text("Adjust the search or filters to broaden the library.")
                    )
                }

                ForEach(filteredGames) { game in
                    Button {
                        launch(game)
                    } label: {
                        GameLibraryRow(game: game)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("home.game.\(game.id)")
                    .accessibilityIdentifier("library.game.\(game.id)")
                }
            }

            if let loadError {
                Section("Load Error") {
                    Text(loadError)
                        .foregroundStyle(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
        .premiumScreenBackground()
        .navigationTitle("Game Library")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $filters.searchText, prompt: "Search title, players, opening")
        .accessibilityIdentifier("library.screen")
        .navigationDestination(item: $selectedRoute) { route in
            GameTrainingView(viewModel: GameViewModel(game: route.game, mode: route.mode))
        }
        .sheet(item: $timedGameSelection) { game in
            TimedGameConfigurationView(game: game) { duration in
                timedGameSelection = nil
                selectedRoute = GameTrainingRoute(game: game, mode: .timed(durationSeconds: duration.seconds))
            }
        }
        .task {
            await loadGamesOnce()
        }
    }

    private var isLoadingLibrary: Bool {
        !hasLoadedGames && games.isEmpty && loadError == nil
    }

    private var availableOpeningFilters: [OpeningFilter] {
        filters.availableOpeningFilters(from: games)
    }

    private var filteredGames: [NotationGame] {
        filters.apply(to: games)
    }

    private func launchRandomFilteredGame() {
        guard let game = filteredGames.randomElement() else { return }
        launch(game)
    }

    private func launch(_ game: NotationGame) {
        switch launchMode {
        case .practice:
            selectedRoute = GameTrainingRoute(game: game, mode: .untimed)
        case .timed:
            timedGameSelection = game
        }
    }

    @MainActor
    private func loadGamesOnce() async {
        guard !hasLoadedGames else { return }
        hasLoadedGames = true

        do {
            let loadedGames = try libraryService.loadGames()
            games = loadedGames
            loadError = nil
        } catch {
            games = []
            loadError = error.localizedDescription
        }
    }
}

enum GameLibraryLaunchMode: Hashable {
    case practice
    case timed

    var displayName: String {
        switch self {
        case .practice: return "Practice"
        case .timed: return "Timed"
        }
    }

    var subtitle: String {
        switch self {
        case .practice: return "Opening a game starts untimed notation training."
        case .timed: return "Opening a game asks for a timer before play."
        }
    }

    var systemImage: String {
        switch self {
        case .practice: return "scope"
        case .timed: return "timer"
        }
    }
}

private struct GameTrainingRoute: Identifiable, Hashable {
    let game: NotationGame
    let mode: GameSessionMode

    var id: String {
        switch mode {
        case .untimed:
            return "\(game.id)-untimed"
        case .timed(let durationSeconds):
            return "\(game.id)-timed-\(durationSeconds)"
        }
    }
}

private struct HomeModeTile: View {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                PremiumArtworkView(assetName: assetName, fallbackIdentifier: "premiumAssetFallback.\(assetName)") {
                    tileTexture
                }

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                if !PremiumAssetAvailability.hasImage(named: assetName) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 34, height: 34)
                        .background(tint.opacity(0.86))
                        .clipShape(Circle())
                        .shadow(color: tint.opacity(0.22), radius: 8, x: 0, y: 5)
                        .padding(10)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 104)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PremiumDesign.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .bottom, spacing: 8) {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(PremiumDesign.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(tint)
                        .frame(width: 26, height: 26)
                        .background(tint.opacity(0.14))
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                }
            }

        }
        .frame(maxWidth: .infinity, minHeight: 178, alignment: .topLeading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.2), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var tileTexture: some View {
        switch texture {
        case .board:
            BoardTexture(tint: tint)
        case .speed:
            SpeedTexture(tint: tint)
        case .target:
            TargetTexture(tint: tint)
        case .book:
            BookTexture(tint: tint)
        }
    }
}

private struct BoardTexture: View {
    let tint: Color

    var body: some View {
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
    }
}

private struct SpeedTexture: View {
    let tint: Color

    var body: some View {
        ZStack(alignment: .leading) {
            tint.opacity(0.1)
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(tint.opacity(0.12))
                    .frame(width: CGFloat(54 + index * 20), height: 8)
                    .offset(x: CGFloat(index * 8), y: CGFloat(index * 15 - 28))
            }
        }
    }
}

private struct TargetTexture: View {
    let tint: Color

    var body: some View {
        ZStack {
            tint.opacity(0.1)
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .stroke(tint.opacity(Double(4 - index) * 0.08), lineWidth: 2)
                    .padding(CGFloat(index * 14 + 10))
            }
        }
    }
}

private struct BookTexture: View {
    let tint: Color

    var body: some View {
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

private struct RandomFilteredGameRow: View {
    let launchMode: GameLibraryLaunchMode

    var body: some View {
        HStack(spacing: 12) {
            PremiumArtworkView(assetName: PremiumAssetName.libraryRandomGame, fallbackIdentifier: "premiumAssetFallback.\(PremiumAssetName.libraryRandomGame)") {
                ZStack {
                    BoardTexture(tint: PremiumDesign.Accent.brand.color)
                    Image(systemName: "die.face.5.fill")
                        .font(.title3)
                        .foregroundStyle(PremiumDesign.Accent.brand.color)
                }
            }
                .frame(width: 46, height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(PremiumDesign.Accent.brand.color.opacity(0.2), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text("Random filtered game")
                    .font(.headline)
                    .foregroundStyle(PremiumDesign.primaryText)
                Text("Start from the games matching current filters.")
                    .font(.caption)
                    .foregroundStyle(PremiumDesign.secondaryText)
            }

            Spacer(minLength: 8)

            Image(systemName: launchMode == .timed ? "timer" : "play.fill")
                .foregroundStyle(PremiumDesign.secondaryText)
        }
        .padding(.vertical, 4)
    }
}

private struct LaunchModeSummary: View {
    let launchMode: GameLibraryLaunchMode

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: launchMode.systemImage)
                .font(.headline)
                .foregroundStyle(launchMode == .timed ? .blue : .green)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(launchMode.displayName) mode")
                    .font(.headline)
                    .accessibilityIdentifier("library.launchModeText")
                Text(launchMode.subtitle)
                    .font(.caption)
                    .foregroundStyle(PremiumDesign.secondaryText)
            }
        }
        .padding(.vertical, 2)
    }
}

struct TimedGameConfigurationView: View {
    @Environment(\.dismiss) private var dismiss

    let game: NotationGame
    let start: (TimedGameDuration) -> Void
    @State private var selectedDuration: TimedGameDuration = .threeMinutes

    var body: some View {
        NavigationStack {
            List {
                Section("Game") {
                    GameLibraryRow(game: game)
                }

                Section("Time limit") {
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(TimedGameDuration.allCases) { duration in
                            Text(duration.displayName).tag(duration)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("timedGame.durationPicker")
                }

                Section {
                    Button {
                        start(selectedDuration)
                    } label: {
                        Label("Start timed game", systemImage: "play.fill")
                    }
                    .accessibilityIdentifier("timedGame.startButton")
                }
            }
            .navigationTitle("Timed Game")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

enum TimedGameDuration: Int, CaseIterable, Identifiable {
    case oneMinute = 60
    case threeMinutes = 180
    case fiveMinutes = 300

    var id: Int { rawValue }
    var seconds: Int { rawValue }

    var displayName: String {
        switch self {
        case .oneMinute: return "1 min"
        case .threeMinutes: return "3 min"
        case .fiveMinutes: return "5 min"
        }
    }
}

private struct GameLibraryRow: View {
    let game: NotationGame

    var body: some View {
        HStack(spacing: 12) {
            GameThumbnailView(game: game)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(game.title)
                        .font(.headline)
                        .foregroundStyle(PremiumDesign.primaryText)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    PremiumBadge(text: game.difficulty.rawValue.capitalized, accent: PremiumDesign.difficultyAccent(for: game.difficulty))
                }

                Text("\(game.white) vs \(game.black)")
                    .font(.caption)
                    .foregroundStyle(PremiumDesign.secondaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let year = game.year {
                        Label(String(year), systemImage: "calendar")
                    }
                    if let opening = game.opening {
                        Label(opening, systemImage: "book.closed")
                    }
                }
                .font(.caption2)
                .foregroundStyle(PremiumDesign.secondaryText)
                .lineLimit(1)
            }
        }
        .padding(.vertical, 5)
    }

}
