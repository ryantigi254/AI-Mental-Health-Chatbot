import SwiftUI
import Charts

struct JournalView: View {
    @StateObject private var journalManager = JournalManager(context: PersistenceController.shared.container.viewContext)
    @State private var showingNewEntrySheet = false
    @State private var showingEntryDetail: JournalEntry? = nil
    @State private var searchText = ""
    @State private var selectedFilter: JournalFilter = .all
    
    enum JournalFilter: Equatable {
        case all
        case today
        case week
        case month
        case byMood(String)
        case byTag(String)
        
        static func == (lhs: JournalFilter, rhs: JournalFilter) -> Bool {
            switch (lhs, rhs) {
            case (.all, .all), (.today, .today), (.week, .week), (.month, .month):
                return true
            case (.byMood(let lhsMood), .byMood(let rhsMood)):
                return lhsMood == rhsMood
            case (.byTag(let lhsTag), .byTag(let rhsTag)):
                return lhsTag == rhsTag
            default:
                return false
            }
        }
    }
    
    var filteredEntries: [JournalEntry] {
        let entries = journalManager.journalEntries
        
        // First apply search filter if any
        let searchFiltered = searchText.isEmpty ? entries : entries.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Then apply category filter
        switch selectedFilter {
        case .all:
            return searchFiltered
        case .today:
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            return searchFiltered.filter {
                calendar.isDate($0.date, inSameDayAs: today)
            }
        case .week:
            let calendar = Calendar.current
            let today = Date()
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
                return searchFiltered
            }
            return journalManager.getEntriesByDate(startDate: weekAgo, endDate: today)
                .filter { entry in
                    searchText.isEmpty ||
                    entry.title.localizedCaseInsensitiveContains(searchText) ||
                    entry.content.localizedCaseInsensitiveContains(searchText)
                }
        case .month:
            let calendar = Calendar.current
            let today = Date()
            guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) else {
                return searchFiltered
            }
            return journalManager.getEntriesByDate(startDate: monthAgo, endDate: today)
                .filter { entry in
                    searchText.isEmpty ||
                    entry.title.localizedCaseInsensitiveContains(searchText) ||
                    entry.content.localizedCaseInsensitiveContains(searchText)
                }
        case .byMood(let mood):
            return journalManager.getEntriesByMood(mood: mood)
                .filter { entry in
                    searchText.isEmpty ||
                    entry.title.localizedCaseInsensitiveContains(searchText) ||
                    entry.content.localizedCaseInsensitiveContains(searchText)
                }
        case .byTag(let tag):
            return journalManager.getEntriesByTag(tag: tag)
                .filter { entry in
                    searchText.isEmpty ||
                    entry.title.localizedCaseInsensitiveContains(searchText) ||
                    entry.content.localizedCaseInsensitiveContains(searchText)
                }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter options
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "All", isSelected: selectedFilter == .all) {
                            selectedFilter = .all
                        }
                        
                        FilterButton(title: "Today", isSelected: selectedFilter == .today) {
                            selectedFilter = .today
                        }
                        
                        FilterButton(title: "This Week", isSelected: selectedFilter == .week) {
                            selectedFilter = .week
                        }
                        
                        FilterButton(title: "This Month", isSelected: selectedFilter == .month) {
                            selectedFilter = .month
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Journal entries list
                if filteredEntries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No journal entries yet")
                            .font(.headline)
                        
                        Text("Start writing about your thoughts and feelings")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingNewEntrySheet = true
                        }) {
                            Text("Create First Entry")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredEntries) { entry in
                            JournalEntryRow(entry: entry)
                                .onTapGesture {
                                    showingEntryDetail = entry
                                }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                journalManager.deleteJournalEntry(id: filteredEntries[index].id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewEntrySheet = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search journal entries")
            .sheet(isPresented: $showingNewEntrySheet) {
                JournalEntryEditorView(journalManager: journalManager)
            }
            .sheet(item: $showingEntryDetail) { entry in
                JournalEntryDetailView(entry: entry, journalManager: journalManager)
            }
            .onAppear {
                journalManager.loadJournalEntries()
            }
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .blue : .primary)
                .cornerRadius(16)
        }
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(.headline)
                
                Spacer()
                
                if let mood = entry.mood {
                    Text(mood)
                        .font(.title3)
                }
            }
            
            Text(entry.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(maxWidth: 200)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview("Journal View") {
    JournalView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 