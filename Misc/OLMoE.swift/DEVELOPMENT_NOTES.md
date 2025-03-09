# Development Notes

## Recent Changes

### Fix JournalFilter Equality and Integrate Persistent Storage (Current)

- Fixed JournalFilter enum to conform to Equatable protocol
- Added proper equality comparison for JournalFilter cases with associated values
- Updated Preview macros with names in JournalView, HamburgerMenuView, and MainView
- Removed unnecessary MoodDatabaseManager environment object from MainView preview
- Fixed VoiceRecorderManager to use the correct static method for requesting microphone permissions

### Fix Mood Database Error by Revising Environment Object Management (Previous)

- Removed global moodDatabaseManager environment object from app and main view
- Added local StateObject in MoodTrackerView with fallback mechanism
- Changed variable naming from moodDatabase to moodDatabaseManager for consistency
- Added safety checks to prevent crashes when accessing environment objects
- Simplified environment object propagation throughout the app

## TODOs

### High Priority

1. **Persistent Memory for Journals**
   - Implement persistent storage for journal entries
   - Link journal database to the same database that manages chats and mood recordings
   - Ensure data consistency across different features

2. **Voice Input Implementation**
   - Complete the voice input feature with transcription option for journal entries
   - Integrate with the existing VoiceRecorderManager
   - Add UI controls for recording and transcribing voice input

### Medium Priority

1. **UI/UX Improvements**
   - Ensure consistent styling across all views
   - Improve accessibility features
   - Add animations for smoother transitions

2. **Performance Optimization**
   - Optimize database queries
   - Implement caching for frequently accessed data
   - Reduce memory usage for large datasets

### Low Priority

1. **Additional Features**
   - Export functionality for journal entries and mood data
   - Data visualization improvements
   - Theme customization options

## Known Issues

1. Binary operator '==' cannot be applied to operands of type 'JournalView.JournalFilter' and 'TableColumnCustomizationBehavior' (Fixed)
2. PreviewDisplayName is ignored in #Preview macros (Fixed)
3. Static member 'requestRecordPermission' cannot be used on instance of type 'AVAudioApplication' (Fixed) 