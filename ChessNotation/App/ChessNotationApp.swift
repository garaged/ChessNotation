import SwiftUI

@main
struct ChessNotationApp: App {
    @State private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            HomeView(libraryService: AppEnvironment.makeLibraryService())
                .environment(appSettings)
        }
    }
}
