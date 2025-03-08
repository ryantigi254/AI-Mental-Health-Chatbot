import Foundation
import CoreData
import SwiftUI
import Combine

class JournalManager: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var journalEntries: [JournalEntry] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadJournalEntries()
    }
    
    // MARK: - CRUD Operations
    
    func loadJournalEntries() {
        let request: NSFetchRequest<JournalEntryEntity> = JournalEntryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntryEntity.date, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            journalEntries = entities.map { $0.journalEntry }
        } catch {
            print("Error loading journal entries: \(error.localizedDescription)")
        }
    }
    
    func addJournalEntry(title: String, content: String, mood: String? = nil, tags: [String] = []) {
        let newEntry = JournalEntryEntity(context: context)
        newEntry.id = UUID()
        newEntry.date = Date()
        newEntry.title = title
        newEntry.content = content
        newEntry.mood = mood
        newEntry.tags = tags
        
        saveContext()
        loadJournalEntries()
    }
    
    func updateJournalEntry(id: UUID, title: String, content: String, mood: String?, tags: [String]) {
        let request: NSFetchRequest<JournalEntryEntity> = JournalEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let entry = try context.fetch(request).first {
                entry.title = title
                entry.content = content
                entry.mood = mood
                entry.tags = tags
                
                saveContext()
                loadJournalEntries()
            }
        } catch {
            print("Error updating journal entry: \(error.localizedDescription)")
        }
    }
    
    func deleteJournalEntry(id: UUID) {
        let request: NSFetchRequest<JournalEntryEntity> = JournalEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let entry = try context.fetch(request).first {
                context.delete(entry)
                saveContext()
                loadJournalEntries()
            }
        } catch {
            print("Error deleting journal entry: \(error.localizedDescription)")
        }
    }
    
    func getJournalEntry(id: UUID) -> JournalEntry? {
        return journalEntries.first { $0.id == id }
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Filtering and Sorting
    
    func getEntriesByDate(startDate: Date, endDate: Date) -> [JournalEntry] {
        return journalEntries.filter { entry in
            let calendar = Calendar.current
            let entryDate = calendar.startOfDay(for: entry.date)
            let start = calendar.startOfDay(for: startDate)
            let end = calendar.startOfDay(for: endDate)
            return entryDate >= start && entryDate <= end
        }
    }
    
    func getEntriesByMood(mood: String) -> [JournalEntry] {
        return journalEntries.filter { $0.mood == mood }
    }
    
    func getEntriesByTag(tag: String) -> [JournalEntry] {
        return journalEntries.filter { $0.tags.contains(tag) }
    }
}

// MARK: - Preview Helper
extension JournalManager {
    static var preview: JournalManager {
        let manager = JournalManager(context: PersistenceController.preview.container.viewContext)
        
        // Add sample entries for preview
        let previewContext = PersistenceController.preview.container.viewContext
        
        // Clear any existing entries first
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = JournalEntryEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? previewContext.execute(batchDeleteRequest)
        
        // Create sample entry 1
        let entry1 = JournalEntryEntity(context: previewContext)
        entry1.id = UUID()
        entry1.date = Date().addingTimeInterval(-86400) // Yesterday
        entry1.title = "First day of therapy"
        entry1.content = "Today I had my first therapy session. It went better than expected, and I feel hopeful about the process."
        entry1.mood = "😊"
        entry1.tags = ["therapy", "hope"]
        
        // Create sample entry 2
        let entry2 = JournalEntryEntity(context: previewContext)
        entry2.id = UUID()
        entry2.date = Date().addingTimeInterval(-172800) // 2 days ago
        entry2.title = "Feeling anxious"
        entry2.content = "Work has been stressful lately. I need to practice more mindfulness techniques to manage my anxiety."
        entry2.mood = "😟"
        entry2.tags = ["work", "anxiety", "mindfulness"]
        
        try? previewContext.save()
        
        return manager
    }
} 