import SwiftUI

struct HomeView: View {
    @Environment(AppSettings.self) private var appSettings
    @State private var games: [NotationGame] = []
    @State private var loadError: String?
    @State private var selectedGame: NotationGame?
    @State private var hasLoadedGames = false
    @State private var filters = GameLibraryFilters()
    @State private var isShowingAppearanceSettings = false

    private let libraryService: GameLibraryProviding

    init(libraryService: GameLibraryProviding = BundledGameLibraryService()) {
        self.libraryService = libraryService
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Start") {
                    Button("Random Game") {
                        selectedGame = filteredGames.randomElement()
                    }
                    .disabled(filteredGames.isEmpty)
                    .accessibilityIdentifier("home.randomGameButton")

                    NavigationLink("Instructions") {
                        InstructionsView()
                    }
                    .accessibilityIdentifier("home.instructionsLink")
                }

                Section("Filters") {
                    Picker("Level", selection: $filters.difficulty) {
                        ForEach(DifficultyFilter.allCases) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("home.levelFilter")

                    if availableOpeningFilters.count > 1 {
                        Picker("Opening", selection: $filters.opening) {
                            ForEach(availableOpeningFilters) { filter in
                                Text(filter.displayName).tag(filter)
                            }
                        }
                        .accessibilityIdentifier("home.openingFilter")
                    }
                }

                Section("Library") {
                    if isLoadingLibrary {
                        ProgressView("Loading games…")
                            .accessibilityIdentifier("home.loadingGames")
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
                            selectedGame = game
                        } label: {
                            GameLibraryRow(game: game)
                        }
                        .accessibilityIdentifier("home.game.\(game.id)")
                    }
                }

                if let loadError {
                    Section("Load Error") {
                        Text(loadError)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("ChessNotation")
            .searchable(text: $filters.searchText, prompt: "Search title, players, opening")
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
            .navigationDestination(item: $selectedGame) { game in
                GameTrainingView(viewModel: GameViewModel(game: game))
            }
            .sheet(isPresented: $isShowingAppearanceSettings) {
                AppearanceSettingsView()
                    .environment(appSettings)
            }
            .task {
                await loadGamesOnce()
            }
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

private struct GameLibraryRow: View {
    let game: NotationGame

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(game.title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text("\(game.white) vs \(game.black)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                if let year = game.year {
                    Label(String(year), systemImage: "calendar")
                }
                if let opening = game.opening {
                    Label(opening, systemImage: "book.closed")
                }
                Label(game.difficulty.rawValue.capitalized, systemImage: "gauge.medium")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
