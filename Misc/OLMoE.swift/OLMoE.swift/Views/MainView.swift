import SwiftUI

struct MainView: View {
    @State private var selectedTab: TabSelection = .home
    @State private var isMenuOpen = false
    @StateObject private var disclaimerState = DisclaimerState()
    @State private var bot: Bot?
    
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
                    
                    Spacer()
                    
                    Text(selectedTab.rawValue)
                        .font(.headline)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                        .foregroundColor(.clear)
                        .padding()
                }
                .background(Color(.systemBackground))
                .shadow(radius: 1)
                
                // Tab content
                ZStack {
                    switch selectedTab {
                    case .home:
                        if let bot = bot {
                            BotView(bot, disclaimerHandlers: DisclaimerHandlers(
                                setActiveDisclaimer: { disclaimerState.activeDisclaimer = $0 },
                                setAllowOutsideTapDismiss: { disclaimerState.allowOutsideTapDismiss = $0 },
                                setCancelAction: { disclaimerState.onCancel = $0 },
                                setConfirmAction: { disclaimerState.onConfirm = $0 },
                                setShowDisclaimerPage: { disclaimerState.showDisclaimerPage = $0 }
                            ))
                        } else {
                            ProgressView("Loading model...")
                        }
                    case .moodTracker:
                        MoodTrackerView()
                    case .settings:
                        Text("Settings")
                            .font(.largeTitle)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Crisis button overlay
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CrisisButtonView()
                        .padding()
                }
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
                    onConfirm: disclaimerState.onConfirm
                )
            }
        }
        .onAppear {
            disclaimerState.showInitialDisclaimer()
            bot = Bot()
        }
    }
}

#Preview {
    MainView()
} 