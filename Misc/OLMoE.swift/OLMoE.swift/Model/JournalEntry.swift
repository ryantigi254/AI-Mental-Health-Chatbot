import Foundation
import CoreData

struct JournalEntry: Identifiable {
    let id: UUID
    var date: Date
    var title: String
    var content: String
    var mood: String?
    var tags: [String]
    
    init(id: UUID = UUID(), date: Date = Date(), title: String, content: String, mood: String? = nil, tags: [String] = []) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.mood = mood
        self.tags = tags
    }
}

// Core Data entity
@objc(JournalEntryEntity)
class JournalEntryEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var title: String
    @NSManaged var content: String
    @NSManaged var mood: String?
    @NSManaged var tagsArray: [String]?
    
    var tags: [String] {
        get { return tagsArray ?? [] }
        set { tagsArray = newValue }
    }
    
    var journalEntry: JournalEntry {
        JournalEntry(
            id: id,
            date: date,
            title: title,
            content: content,
            mood: mood,
            tags: tags
        )
    }
    
    static func fetchRequest() -> NSFetchRequest<JournalEntryEntity> {
        return NSFetchRequest<JournalEntryEntity>(entityName: "JournalEntryEntity")
    }
} 