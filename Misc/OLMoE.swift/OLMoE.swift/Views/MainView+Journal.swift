import SwiftUI

// Extension to add Journal tab to MainView
// The journal case is already defined in the TabSelection enum
// No need to extend it here

extension MainView {
    // This function should be called in the body of MainView
    // inside the switch statement for selectedTab
    func journalTabView() -> some View {
        JournalView()
    }
} 