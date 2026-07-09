import SwiftUI

@main
struct ChessNotationApp: App {
    @State private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RestoredHomeView(libraryService: AppEnvironment.makeLibraryService())
                .environment(appSettings)
        }
    }
}
