import SwiftUI
import Foundation

@main
struct OLMoE_swiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager()
    
    // Initialize Core Data stack
    let persistenceController = PersistenceController.shared
    
    // Initialize mood database manager for the app
    @StateObject private var moodDatabaseManager = MoodDatabaseManager(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.font, .manrope())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .environmentObject(themeManager)
                .environmentObject(moodDatabaseManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print("Background URL session: \(identifier)")
        completionHandler()
    }
}
