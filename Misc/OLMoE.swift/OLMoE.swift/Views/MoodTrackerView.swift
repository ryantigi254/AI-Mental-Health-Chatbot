import SwiftUI
import Charts

// Mood data model
struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var mood: MoodType
    var note: String?
    
    enum CodingKeys: String, CodingKey {
        case id, date, mood, note
    }
}

// Mood types with emoji representation
enum MoodType: String, CaseIterable, Codable {
    case veryHappy = "😄"
    case happy = "🙂"
    case neutral = "😐"
    case sad = "😔"
    case verySad = "😢"
    
    var description: String {
        switch self {
        case .veryHappy: return "Very Happy"
        case .happy: return "Happy"
        case .neutral: return "Neutral"
        case .sad: return "Sad"
        case .verySad: return "Very Sad"
        }
    }
    
    var value: Int {
        switch self {
        case .veryHappy: return 5
        case .happy: return 4
        case .neutral: return 3
        case .sad: return 2
        case .verySad: return 1
        }
    }
    
    var color: Color {
        switch self {
        case .veryHappy: return .green
        case .happy: return .mint
        case .neutral: return .yellow
        case .sad: return .orange
        case .verySad: return .red
        }
    }
}

// Time period for chart display
enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"
    case year = "Year"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 180
        case .year: return 365
        }
    }
}

// Mood data manager
class MoodDataManager: ObservableObject {
    @Published var moodEntries: [MoodEntry] = []
    @Published var hasAnsweredToday = false
    
    private let saveKey = "moodEntries"
    
    init() {
        loadMoodEntries()
        checkIfAnsweredToday()
    }
    
    func saveMood(_ mood: MoodType, note: String? = nil) {
        let newEntry = MoodEntry(date: Date(), mood: mood, note: note)
        moodEntries.append(newEntry)
        hasAnsweredToday = true
        saveMoodEntries()
    }
    
    func getMoodEntries(for period: TimePeriod) -> [MoodEntry] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -period.days, to: Date()) ?? Date()
        
        return moodEntries.filter { $0.date >= startDate }
    }
    
    private func checkIfAnsweredToday() {
        let calendar = Calendar.current
        hasAnsweredToday = moodEntries.contains { entry in
            calendar.isDateInToday(entry.date)
        }
    }
    
    private func saveMoodEntries() {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadMoodEntries() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
                moodEntries = decoded
                return
            }
        }
        
        moodEntries = []
    }
}

struct MoodTrackerView: View {
    @StateObject private var dataManager = MoodDataManager()
    @State private var selectedMood: MoodType?
    @State private var showingMetrics = false
    @State private var selectedPeriod: TimePeriod = .week
    @State private var moodNote: String = ""
    
    var body: some View {
        VStack {
            if !dataManager.hasAnsweredToday {
                moodQuestionView
            } else if !showingMetrics {
                moodConfirmationView
            } else {
                moodMetricsView
            }
        }
        .padding()
        .navigationTitle("Mood Tracker")
    }
    
    // View that asks for today's mood
    private var moodQuestionView: some View {
        VStack(spacing: 20) {
            Text("How are you feeling today?")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 15) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        Text(mood.rawValue)
                            .font(.system(size: 40))
                            .padding()
                            .background(
                                Circle()
                                    .fill(selectedMood == mood ? mood.color.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.vertical)
            
            if selectedMood != nil {
                TextField("Add a note (optional)", text: $moodNote)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.bottom)
                
                Button(action: {
                    if let mood = selectedMood {
                        dataManager.saveMood(mood, note: moodNote.isEmpty ? nil : moodNote)
                    }
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    // View shown after recording mood
    private var moodConfirmationView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Thank you for sharing your mood today!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Taking a moment to check in with yourself is an important step for mental wellbeing.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                showingMetrics = true
            }) {
                Text("View Your Mood Metrics")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    // View for displaying mood metrics
    private var moodMetricsView: some View {
        VStack {
            // Period selector
            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom)
            
            // Mood chart
            moodChart
                .frame(height: 250)
                .padding()
            
            // Mood distribution
            moodDistribution
                .padding()
            
            Button(action: {
                showingMetrics = false
            }) {
                Text("Back")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
    }
    
    // Chart showing mood over time
    private var moodChart: some View {
        let entries = dataManager.getMoodEntries(for: selectedPeriod)
        
        return Chart {
            ForEach(entries) { entry in
                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Mood", entry.mood.value)
                )
                .foregroundStyle(entry.mood.color)
                .symbolSize(CGSize(width: 15, height: 15))
            }
            
            if !entries.isEmpty {
                LineMark(
                    x: .value("Date", entries.map { $0.date }),
                    y: .value("Mood", entries.map { $0.mood.value })
                )
                .foregroundStyle(.gray.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
            }
        }
        .chartYScale(domain: 1...5)
        .chartYAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        let moodTypes = MoodType.allCases
                        if intValue >= 1 && intValue <= moodTypes.count {
                            Text(moodTypes[moodTypes.count - intValue].rawValue)
                        }
                    }
                }
            }
        }
    }
    
    // Mood distribution visualization
    private var moodDistribution: some View {
        let entries = dataManager.getMoodEntries(for: selectedPeriod)
        let moodCounts = Dictionary(grouping: entries, by: { $0.mood })
            .mapValues { $0.count }
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Mood Distribution")
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(MoodType.allCases, id: \.self) { mood in
                HStack {
                    Text(mood.rawValue)
                        .font(.title3)
                    
                    Text(mood.description)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(moodCounts[mood] ?? 0)")
                        .fontWeight(.bold)
                }
                .padding(.vertical, 5)
            }
        }
    }
}

#Preview {
    MoodTrackerView()
} 