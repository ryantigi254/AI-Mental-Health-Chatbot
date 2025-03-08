import SwiftUI
import Foundation

@main
struct OLMoE_swiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.font, .manrope())
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .environmentObject(themeManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print("Background URL session: \(identifier)")
        completionHandler()
    }
}
