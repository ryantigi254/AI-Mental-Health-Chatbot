import SwiftUI

// Extension to add Journal tab to HamburgerMenuView
extension HamburgerMenuView {
    // This function should be called in the ForEach loop in HamburgerMenuView
    // that displays the tab options
    static var allTabs: [TabSelection] {
        [.home, .moodTracker, .journal, .settings]
    }
} 