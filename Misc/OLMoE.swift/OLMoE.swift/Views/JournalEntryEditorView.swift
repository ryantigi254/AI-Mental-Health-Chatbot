import SwiftUI
import Speech

struct JournalEntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var journalManager: JournalManager
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: String? = nil
    @State private var tagInput = ""
    @State private var tags: [String] = []
    
    // Voice recording state
    @StateObject private var voiceRecorder = VoiceRecorderManager()
    @State private var showingVoiceRecorder = false
    @State private var showingPermissionAlert = false
    
    var editingEntry: JournalEntry? = nil
    
    // Available mood emojis
    let moods = ["😊", "😌", "😐", "😟", "😢", "😡", "😴", "🤔", "🥳", "🤒"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Entry title", text: $title)
                }
                
                Section(header: Text("How are you feeling?")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = selectedMood == mood ? nil : mood
                                }) {
                                    Text(mood)
                                        .font(.system(size: 30))
                                        .padding(8)
                                        .background(
                                            Circle()
                                                .fill(selectedMood == mood ? Color.blue.opacity(0.2) : Color.clear)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: 
                    HStack {
                        Text("Journal Entry")
                        Spacer()
                        Button(action: {
                            voiceRecorder.requestPermissions { granted in
                                if granted {
                                    showingVoiceRecorder = true
                                } else {
                                    showingPermissionAlert = true
                                }
                            }
                        }) {
                            Label("Voice", systemImage: "mic.fill")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                ) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                
                Section(header: Text("Tags")) {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                            .autocapitalization(.none)
                        
                        Button(action: addTag) {
                            Text("Add")
                                .foregroundColor(.blue)
                        }
                        .disabled(tagInput.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text("#\(tag)")
                                            .padding(.leading, 8)
                                            .padding(.trailing, 0)
                                        
                                        Button(action: {
                                            tags.removeAll { $0 == tag }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 8)
                                    }
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(15)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle(editingEntry == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .onAppear {
                if let entry = editingEntry {
                    title = entry.title
                    content = entry.content
                    selectedMood = entry.mood
                    tags = entry.tags
                }
            }
            .sheet(isPresented: $showingVoiceRecorder) {
                VoiceRecorderView(voiceRecorder: voiceRecorder, onDone: { text in
                    if !text.isEmpty {
                        if content.isEmpty {
                            content = text
                        } else {
                            content += "\n\n" + text
                        }
                    }
                })
            }
            .alert("Microphone Access Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Voice recording requires microphone access. Please enable it in Settings.")
            }
        }
    }
    
    private func addTag() {
        let newTag = tagInput.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if !newTag.isEmpty && !tags.contains(newTag) {
            tags.append(newTag)
            tagInput = ""
        }
    }
    
    private func saveEntry() {
        if let entry = editingEntry {
            journalManager.updateJournalEntry(
                id: entry.id,
                title: title,
                content: content,
                mood: selectedMood,
                tags: tags
            )
        } else {
            journalManager.addJournalEntry(
                title: title,
                content: content,
                mood: selectedMood,
                tags: tags
            )
        }
    }
}

// Voice recorder view for capturing speech input
struct VoiceRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var voiceRecorder: VoiceRecorderManager
    var onDone: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Recording status and timer
                VStack(spacing: 15) {
                    if voiceRecorder.isRecording {
                        // Animated recording indicator
                        ZStack {
                            ForEach(0..<3) { i in
                                Circle()
                                    .stroke(Color.red, lineWidth: 2)
                                    .frame(width: 80 + CGFloat(i * 20), height: 80 + CGFloat(i * 20))
                                    .opacity(0.7)
                                    .scaleEffect(voiceRecorder.isRecording ? 1 : 0.5)
                                    .animation(
                                        Animation.easeInOut(duration: 1)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(i) * 0.2),
                                        value: voiceRecorder.isRecording
                                    )
                            }
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                        }
                        
                        Text("Recording... \(voiceRecorder.formatTime(voiceRecorder.recordingTime))")
                            .font(.title3)
                            .foregroundColor(.red)
                    } else {
                        // Static microphone icon when not recording
                        Image(systemName: "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .frame(width: 80, height: 80)
                            .background(Circle().stroke(Color.blue, lineWidth: 2))
                        
                        Text("Tap to start recording")
                            .font(.title3)
                    }
                }
                .padding()
                .onTapGesture {
                    if voiceRecorder.isRecording {
                        voiceRecorder.stopRecording()
                    } else {
                        voiceRecorder.startRecording()
                    }
                }
                
                // Transcription area
                VStack(alignment: .leading, spacing: 10) {
                    Text("Transcription")
                        .font(.headline)
                    
                    ScrollView {
                        Text(voiceRecorder.transcribedText.isEmpty ? "Your speech will appear here..." : voiceRecorder.transcribedText)
                            .padding()
                            .frame(minHeight: 200, maxHeight: .infinity, alignment: .topLeading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .frame(height: 200)
                }
                .padding(.horizontal)
                
                // Error message if any
                if let errorMessage = voiceRecorder.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: {
                        voiceRecorder.stopRecording()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        voiceRecorder.stopRecording()
                        onDone(voiceRecorder.transcribedText)
                        dismiss()
                    }) {
                        Text("Use Text")
                            .fontWeight(.medium)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(voiceRecorder.transcribedText.isEmpty)
                }
                .padding(.bottom, 30)
            }
            .padding()
            .navigationTitle("Voice to Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        voiceRecorder.stopRecording()
                        onDone(voiceRecorder.transcribedText)
                        dismiss()
                    }) {
                        Text("Done")
                    }
                    .disabled(voiceRecorder.transcribedText.isEmpty)
                }
            }
        }
    }
}

#Preview {
    JournalEntryEditorView(journalManager: JournalManager.preview)
} 