import SwiftUI

@main
struct OLMoEApp: App {
    // Initialize Core Data stack
    let persistenceController = PersistenceController.shared
    
    // Initialize mood database manager
    @StateObject private var moodDatabaseManager: MoodDatabaseManager
    
    init() {
        let context = persistenceController.container.viewContext
        _moodDatabaseManager = StateObject(wrappedValue: MoodDatabaseManager(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(moodDatabaseManager)
        }
    }
} 