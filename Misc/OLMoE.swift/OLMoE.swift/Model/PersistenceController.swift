import Foundation
import CoreData

/**
 PersistenceController is responsible for initializing the Core Data stack
 and providing a central point of access to the persistent container.
 */
struct PersistenceController {
    // Shared instance for app-wide access
    static let shared = PersistenceController()
    
    // Storage for Core Data
    let container: NSPersistentContainer
    
    // Initialize the Core Data stack
    init(inMemory: Bool = false) {
        // Create custom model with entities
        let managedObjectModel = Self.createCoreDataModel()
        container = NSPersistentContainer(name: "MentalHealthApp", managedObjectModel: managedObjectModel)
        
        // Configure persistence with security options
        let description = inMemory 
            ? NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
            : NSPersistentStoreDescription()
        
        if !inMemory {
            // Enable data protection - complete protection means the data is encrypted when device is locked
            description.setOption(FileProtectionType.complete as NSObject, 
                                  forKey: NSPersistentStoreFileProtectionKey)
            
            // Set storage type to SQLite
            description.type = NSSQLiteStoreType
            
            // Configure SQLite optimization options
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            
            // Additional SQLite configurations for optimized performance 
            let pragmaOptions: [String: String] = [
                "journal_mode": "WAL",      // Write-Ahead Logging for better concurrency
                "synchronous": "NORMAL",    // Balance between safety and performance
                "auto_vacuum": "FULL",      // Keep database file size optimized
                "foreign_keys": "ON"        // Enforce referential integrity
            ]
            
            description.setOption(pragmaOptions as NSDictionary, forKey: NSSQLitePragmasOption)
        }
        
        container.persistentStoreDescriptions = [description]
        
        // Load the persistent store
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Configure the context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // Create the Core Data model programmatically
    static func createCoreDataModel() -> NSManagedObjectModel {
        // Create a new model
        let model = NSManagedObjectModel()
        
        // Create the MoodEntryEntity
        let moodEntryEntity = NSEntityDescription()
        moodEntryEntity.name = "MoodEntryEntity"
        moodEntryEntity.managedObjectClassName = "MoodEntryEntity"
        
        // Define attributes for MoodEntryEntity
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = true
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = true
        
        let moodValueAttribute = NSAttributeDescription()
        moodValueAttribute.name = "moodValue"
        moodValueAttribute.attributeType = .integer16AttributeType
        moodValueAttribute.isOptional = false
        moodValueAttribute.defaultValue = 3
        
        let moodEmojiAttribute = NSAttributeDescription()
        moodEmojiAttribute.name = "moodEmoji"
        moodEmojiAttribute.attributeType = .stringAttributeType
        moodEmojiAttribute.isOptional = true
        
        let moodDescriptionAttribute = NSAttributeDescription()
        moodDescriptionAttribute.name = "moodDescription"
        moodDescriptionAttribute.attributeType = .stringAttributeType
        moodDescriptionAttribute.isOptional = true
        
        let noteAttribute = NSAttributeDescription()
        noteAttribute.name = "note"
        noteAttribute.attributeType = .stringAttributeType
        noteAttribute.isOptional = true
        
        // Add attributes to MoodEntryEntity
        moodEntryEntity.properties = [
            idAttribute,
            dateAttribute,
            moodValueAttribute,
            moodEmojiAttribute,
            moodDescriptionAttribute,
            noteAttribute
        ]
        
        // Create the JournalEntryEntity
        let journalEntryEntity = NSEntityDescription()
        journalEntryEntity.name = "JournalEntryEntity"
        journalEntryEntity.managedObjectClassName = NSStringFromClass(JournalEntryEntity.self)
        
        // Define attributes for JournalEntryEntity
        let journalIdAttribute = NSAttributeDescription()
        journalIdAttribute.name = "id"
        journalIdAttribute.attributeType = .UUIDAttributeType
        journalIdAttribute.isOptional = false
        
        let journalDateAttribute = NSAttributeDescription()
        journalDateAttribute.name = "date"
        journalDateAttribute.attributeType = .dateAttributeType
        journalDateAttribute.isOptional = false
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = false
        
        let contentAttribute = NSAttributeDescription()
        contentAttribute.name = "content"
        contentAttribute.attributeType = .stringAttributeType
        contentAttribute.isOptional = false
        
        let moodAttribute = NSAttributeDescription()
        moodAttribute.name = "mood"
        moodAttribute.attributeType = .stringAttributeType
        moodAttribute.isOptional = true
        
        let tagsArrayAttribute = NSAttributeDescription()
        tagsArrayAttribute.name = "tagsArray"
        tagsArrayAttribute.attributeType = .transformableAttributeType
        tagsArrayAttribute.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue
        tagsArrayAttribute.isOptional = true
        
        // Add attributes to JournalEntryEntity
        journalEntryEntity.properties = [
            journalIdAttribute,
            journalDateAttribute,
            titleAttribute,
            contentAttribute,
            moodAttribute,
            tagsArrayAttribute
        ]
        
        // Add entities to model
        model.entities = [moodEntryEntity, journalEntryEntity]
        
        return model
    }
    
    // MARK: - Test Support
    
    // A test store for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create 5 example mood entries
        let viewContext = controller.container.viewContext
        let previewEntries: [(moodValue: Int16, emoji: String, description: String, note: String?, daysAgo: Int)] = [
            (5, "😄", "Very Happy", "Had a great day at work!", 0),
            (4, "🙂", "Happy", nil, 1),
            (3, "😐", "Neutral", "Feeling just okay today", 2),
            (2, "😔", "Sad", "Stressed about deadlines", 4),
            (1, "😢", "Very Sad", nil, 6)
        ]
        
        for (index, entry) in previewEntries.enumerated() {
            let newEntry = MoodEntryEntity(context: viewContext)
            newEntry.id = UUID()
            newEntry.date = Calendar.current.date(byAdding: .day, value: -entry.daysAgo, to: Date())
            newEntry.moodValue = entry.moodValue
            newEntry.moodEmoji = entry.emoji
            newEntry.moodDescription = entry.description
            newEntry.note = entry.note
        }
        
        // Create sample journal entries
        let journalEntry1 = JournalEntryEntity(context: viewContext)
        journalEntry1.id = UUID()
        journalEntry1.date = Date().addingTimeInterval(-86400) // Yesterday
        journalEntry1.title = "First day of therapy"
        journalEntry1.content = "Today I had my first therapy session. It went better than expected, and I feel hopeful about the process."
        journalEntry1.mood = "😊"
        journalEntry1.tags = ["therapy", "hope"]
        
        let journalEntry2 = JournalEntryEntity(context: viewContext)
        journalEntry2.id = UUID()
        journalEntry2.date = Date().addingTimeInterval(-172800) // 2 days ago
        journalEntry2.title = "Feeling anxious"
        journalEntry2.content = "Work has been stressful lately. I need to practice more mindfulness techniques to manage my anxiety."
        journalEntry2.mood = "😟"
        journalEntry2.tags = ["work", "anxiety", "mindfulness"]
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
} 