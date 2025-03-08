import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isThemePickerExpanded = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    DisclosureGroup(
                        isExpanded: $isThemePickerExpanded,
                        content: {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Button(action: {
                                    themeManager.setTheme(theme)
                                    withAnimation {
                                        isThemePickerExpanded = false
                                    }
                                }) {
                                    HStack {
                                        Label {
                                            Text(theme.rawValue)
                                        } icon: {
                                            Image(systemName: theme.icon)
                                        }
                                        
                                        Spacer()
                                        
                                        if themeManager.currentTheme == theme {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.vertical, 8)
                            }
                        },
                        label: {
                            HStack {
                                Label("Theme", systemImage: "paintbrush.fill")
                                
                                Spacer()
                                
                                Text(themeManager.currentTheme.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        }
                    )
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    Group {
        SettingsView()
            .environmentObject(ThemeManager())
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        
        SettingsView()
            .environmentObject(ThemeManager())
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
} 