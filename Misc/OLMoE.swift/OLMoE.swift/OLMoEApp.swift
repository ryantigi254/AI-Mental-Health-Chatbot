import SwiftUI

@main
struct OLMoEApp: App {
    // Initialize Core Data stack
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
} 