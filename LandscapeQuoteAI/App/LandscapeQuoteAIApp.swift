import SwiftData
import SwiftUI

@main
struct LandscapeQuoteAIApp: App {
    @State private var settings = AppSettings()
    @State private var storeKitManager = StoreKitManager()
    private let modelContainer: ModelContainer?
    private let startupError: String?

    init() {
        do {
            modelContainer = try PersistenceController.makeModelContainer()
            startupError = nil
        } catch {
            modelContainer = nil
            startupError = "LandscapeQuote AI could not prepare local quote storage. Restart the app or reinstall if the issue continues."
        }
    }

    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                RootView()
                    .environment(settings)
                    .environment(storeKitManager)
                    .modelContainer(modelContainer)
                    .task {
                        await storeKitManager.loadProducts()
                    }
            } else {
                StartupErrorView(message: startupError ?? "Local storage is unavailable.")
            }
        }
    }
}
