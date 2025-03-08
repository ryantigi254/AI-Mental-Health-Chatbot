import SwiftUI

struct MainView: View {
    @State private var selectedTab: TabSelection = .home
    @State private var isMenuOpen = false
    @StateObject private var disclaimerState = DisclaimerState()
    @State private var bot: Bot?
    @State private var hasAcceptedDisclaimer = false
    @EnvironmentObject private var moodDatabaseManager: MoodDatabaseManager
    @EnvironmentObject private var themeManager: ThemeManager
    
    // Fallback database manager as a backup
    @StateObject private var localMoodDatabaseManager = MoodDatabaseManager(context: PersistenceController.shared.container.viewContext)
    
    // Safely access mood database manager
    private var dbManager: MoodDatabaseManager {
        // Use the environment object if it's available, otherwise fall back to the local instance
        return localMoodDatabaseManager
    }
    
    var body: some View {
        ZStack {
            // Main content based on selected tab
            VStack(spacing: 0) {
                // Top navigation bar
                HStack {
                    Button(action: {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(width: 50) // Fixed width for hamburger menu button
                    
                    Spacer()
                    
                    Text(selectedTab.rawValue)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Crisis button in the top bar - only show after disclaimer is accepted
                    if hasAcceptedDisclaimer {
                        CrisisButtonView(isHeaderStyle: true)
                            .padding(.trailing, 8)
                            .frame(width: 50) // Fixed width for crisis button
                    } else {
                        // Empty spacer for balance when crisis button is not shown
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.clear)
                            .padding()
                            .frame(width: 50) // Fixed width to match hamburger menu
                    }
                }
                .background(Color(.systemBackground))
                .shadow(radius: 1)
                
                // Tab content
                ZStack {
                    switch selectedTab {
                    case .home:
                        if let bot = bot {
                            if hasAcceptedDisclaimer {
                                // Only show BotView with full functionality if disclaimer is accepted
                                BotView(bot, disclaimerHandlers: DisclaimerHandlers(
                                    setActiveDisclaimer: { disclaimerState.activeDisclaimer = $0 },
                                    setAllowOutsideTapDismiss: { disclaimerState.allowOutsideTapDismiss = $0 },
                                    setCancelAction: { disclaimerState.onCancel = $0 },
                                    setConfirmAction: { disclaimerState.onConfirm = $0 },
                                    setShowDisclaimerPage: { disclaimerState.showDisclaimerPage = $0 }
                                ))
                            } else {
                                // Show empty view until terms are accepted
                                Color(.systemBackground)
                            }
                        } else {
                            // Check if model file exists
                            if FileManager.default.fileExists(atPath: Bot.modelFileURL.path) {
                                ProgressView("Loading model...")
                            } else {
                                ModelDownloadView()
                            }
                        }
                    case .moodTracker:
                        MoodTrackerView()
                            .environmentObject(localMoodDatabaseManager)
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Hamburger menu
            if isMenuOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }
                
                HStack {
                    HamburgerMenuView(selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                    
                    Spacer()
                }
            }
            
            // Disclaimer overlay
            if disclaimerState.showDisclaimerPage {
                DisclaimerPageView(
                    disclaimer: disclaimerState.activeDisclaimer!,
                    allowOutsideTapDismiss: disclaimerState.allowOutsideTapDismiss,
                    onCancel: disclaimerState.onCancel,
                    onConfirm: {
                        // When disclaimer is confirmed/accepted, set our flag
                        hasAcceptedDisclaimer = true
                        if let onConfirm = disclaimerState.onConfirm {
                            onConfirm()
                        }
                    }
                )
            }
        }
        .onAppear {
            disclaimerState.showInitialDisclaimer()
            
            // Check if model file exists before trying to initialize bot
            if FileManager.default.fileExists(atPath: Bot.modelFileURL.path) {
                print("Model file exists at: \(Bot.modelFileURL.path)")
                do {
                    bot = try Bot()
                    print("Bot initialized successfully")
                } catch {
                    print("Failed to initialize bot: \(error.localizedDescription)")
                }
            } else {
                print("Model file does not exist at: \(Bot.modelFileURL.path)")
                // Don't try to initialize bot if model file doesn't exist
            }
            
            // Check if disclaimer has been previously accepted
            #if DEBUG
            // For debug, we can set this to true for easier testing
            hasAcceptedDisclaimer = false 
            #else
            hasAcceptedDisclaimer = UserDefaults.standard.bool(forKey: "hasSeenDisclaimer")
            #endif
        }
        // Monitor when the model download is complete
        .environmentObject(BackgroundDownloadManager.shared)
        .onChange(of: BackgroundDownloadManager.shared.isModelReady) { oldValue, newValue in
            if newValue && bot == nil {
                // Model download is complete, try to initialize the bot
                do {
                    bot = try Bot()
                    print("Bot initialized after model download")
                } catch {
                    print("Failed to initialize bot after model download: \(error.localizedDescription)")
                }
            }
        }
        .onChange(of: themeManager.currentTheme) { oldValue, newValue in
            // This will trigger UI updates when the theme changes
            print("Theme changed from \(oldValue.rawValue) to \(newValue.rawValue)")
        }
    }
}

#Preview {
    let previewContext = PersistenceController.preview.container.viewContext
    let previewMoodManager = MoodDatabaseManager(context: previewContext)
    
    return MainView()
        .environment(\.managedObjectContext, previewContext)
        .environmentObject(previewMoodManager)
        .environmentObject(ThemeManager())
} 