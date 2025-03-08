import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var icon: String {
        switch self {
        case .system:
            return "iphone"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme
    
    private let themeKey = "app_theme"
    
    init() {
        // Load saved theme or use system default
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = theme
        }
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
    }
    
    func toggleTheme() {
        switch currentTheme {
        case .system:
            setTheme(.light)
        case .light:
            setTheme(.dark)
        case .dark:
            setTheme(.system)
        }
    }
} 