import SwiftUI

enum TabSelection: String, CaseIterable {
    case home = "Home"
    case moodTracker = "Mood Tracker"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .home:
            return "bubble.left.fill"
        case .moodTracker:
            return "heart.fill"
        case .settings:
            return "gear"
        }
    }
}

struct HamburgerMenuView: View {
    @Binding var selectedTab: TabSelection
    @Binding var isMenuOpen: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(TabSelection.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                    withAnimation {
                        isMenuOpen = false
                    }
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: tab.icon)
                            .font(.title2)
                        
                        Text(tab.rawValue)
                            .font(.headline)
                    }
                    .foregroundColor(selectedTab == tab ? .blue : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                }
            }
            
            Spacer()
        }
        .padding(.top, 80)
        .padding(.horizontal, 24)
        .frame(width: UIScreen.main.bounds.width * 0.7)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.vertical)
    }
}

#Preview {
    HamburgerMenuView(selectedTab: .constant(.home), isMenuOpen: .constant(true))
} 