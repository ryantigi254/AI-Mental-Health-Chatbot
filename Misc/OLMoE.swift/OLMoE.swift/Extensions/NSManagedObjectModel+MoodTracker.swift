import CoreData

extension NSManagedObjectModel {
    static func createMoodTrackerModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create the entity
        let entity = NSEntityDescription()
        entity.name = "MoodEntryEntity"
        entity.managedObjectClassName = "MoodEntryEntity"
        
        // Create attributes
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
        
        // Add attributes to entity
        entity.properties = [
            idAttribute,
            dateAttribute,
            moodValueAttribute,
            moodEmojiAttribute,
            moodDescriptionAttribute,
            noteAttribute
        ]
        
        // Add entity to model
        model.entities = [entity]
        
        return model
    }
} 