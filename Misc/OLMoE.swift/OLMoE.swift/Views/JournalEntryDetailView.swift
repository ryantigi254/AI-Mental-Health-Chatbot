import SwiftUI

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntry
    @ObservedObject var journalManager: JournalManager
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text(entry.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let mood = entry.mood {
                            Text(mood)
                                .font(.title)
                        }
                    }
                    .padding(.bottom, 5)
                    
                    Text(entry.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(entry.content)
                        .font(.body)
                    
                    if !entry.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tags")
                                .font(.headline)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Label("Delete", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                JournalEntryEditorView(
                    journalManager: journalManager,
                    editingEntry: entry
                )
            }
            .alert("Delete Entry", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    journalManager.deleteJournalEntry(id: entry.id)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this journal entry? This action cannot be undone.")
            }
        }
    }
}

// A layout that flows items into rows
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for size in sizes {
            if currentRowWidth + size.width > proposal.width ?? .infinity {
                // Start a new row
                width = max(width, currentRowWidth - spacing)
                height += currentRowHeight + spacing
                currentRowWidth = size.width + spacing
                currentRowHeight = size.height
            } else {
                // Add to current row
                currentRowWidth += size.width + spacing
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }
        
        // Add the last row
        width = max(width, currentRowWidth - spacing)
        height += currentRowHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            
            if x + size.width > bounds.maxX {
                // Start a new row
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    let previewEntry = JournalEntry(
        title: "A good day",
        content: "Today was a really good day. I went for a walk in the park and enjoyed the sunshine. I also had a productive meeting at work and made progress on my project.",
        mood: "😊",
        tags: ["good day", "productive", "sunshine"]
    )
    
    return JournalEntryDetailView(
        entry: previewEntry,
        journalManager: JournalManager.preview
    )
} 