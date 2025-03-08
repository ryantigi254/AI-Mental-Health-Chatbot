import SwiftUI

struct OLMoEApp: App {
    // Initialize Core Data stack
    let persistenceController = PersistenceController.shared
    
    // Initialize mood database manager for the app
    @StateObject private var moodDatabaseManager = MoodDatabaseManager(context: PersistenceController.shared.container.viewContext)
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(moodDatabaseManager)
        }
    }
} 