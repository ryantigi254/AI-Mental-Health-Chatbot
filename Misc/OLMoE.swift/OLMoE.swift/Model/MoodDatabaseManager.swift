import Foundation
import CoreData
import SwiftUI

class MoodDatabaseManager: ObservableObject {
    private let context: NSManagedObjectContext
    @Published private(set) var hasAnsweredToday: Bool = false
    @Published private(set) var moodEntries: [MoodEntryEntity] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadMoodEntries()
        checkIfAnsweredToday()
    }
    
    // MARK: - Public Methods
    
    func saveMood(_ mood: MoodType, note: String? = nil) {
        let newEntry = MoodEntryEntity(context: context)
        newEntry.id = UUID()
        newEntry.date = Date()
        newEntry.moodValue = Int16(mood.value)
        newEntry.moodEmoji = mood.rawValue
        newEntry.moodDescription = mood.description
        newEntry.note = note
        
        saveContext()
        loadMoodEntries()
        checkIfAnsweredToday()
    }
    
    func getMoodEntries(for period: TimePeriod) -> [MoodEntryEntity] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -period.days, to: Date()) ?? Date()
        return moodEntries.filter { entry in
            guard let date = entry.date else { return false }
            return date >= cutoffDate
        }.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    func clearAllEntries() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MoodEntryEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            moodEntries.removeAll()
            checkIfAnsweredToday()
        } catch {
            print("Error clearing entries: \(error)")
        }
    }
    
    func loadMoodEntries() {
        let request = NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryEntity.date, ascending: false)]
        
        do {
            moodEntries = try context.fetch(request)
        } catch {
            print("Error loading entries: \(error)")
            moodEntries = []
        }
    }
    
    func checkIfAnsweredToday() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        hasAnsweredToday = moodEntries.contains { entry in
            guard let date = entry.date else { return false }
            return calendar.isDate(date, inSameDayAs: today)
        }
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
            context.rollback()
        }
    }
    
    // MARK: - Preview Helper
    
    static var preview: MoodDatabaseManager {
        MoodDatabaseManager(context: PersistenceController.preview.container.viewContext)
    }
} 