# GemNote - iOS Audio Note Taking App

A production-quality iOS application for capturing, organizing, and enhancing notes with AI-powered summaries and tag suggestions.

## Overview

GemNote is a native iOS app built with SwiftUI and Core Data that allows users to:
- Create text and audio notes
- Record audio with built-in recorder
- Generate AI summaries using Google's Gemini API
- Get automatic tag suggestions
- Organize notes with tags
- Play back audio recordings
- Work completely offline (except AI features)

## Requirements

- **iOS:** 18.0 or later
- **Devices:** iPhone only
- **Developer Account:** Free Apple Developer account (no paid account required)
- **Xcode:** 15.0 or later
- **Optional:** Google Gemini API key (for AI features)

## Features

### Core Features
- ✅ Text note creation and editing
- ✅ Audio recording with AVFoundation
- ✅ Audio playback with controls
- ✅ Core Data persistence
- ✅ Offline-first architecture
- ✅ Secure API key storage in Keychain

### AI Features (Optional)
- ✅ AI-powered note summaries via Gemini API
- ✅ Automatic tag suggestions
- ✅ Multiple AI model support (Gemini Pro, Gemini 1.5 Flash)
- ✅ Dry-run mode for testing without API calls
- ✅ Manual AI execution (user-initiated only)

### UI/UX
- ✅ SwiftUI-based modern interface
- ✅ NavigationStack for navigation
- ✅ Dark mode support
- ✅ Responsive design
- ✅ Intuitive gestures and animations

## Project Structure

```
GemNote/
├── App/
│   └── GemNoteApp.swift           # App entry point
│
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift         # Main timeline view
│   │   └── HomeViewModel.swift    # Home screen logic
│   │
│   ├── Recorder/
│   │   ├── RecorderView.swift     # Audio recording UI
│   │   └── RecorderViewModel.swift # Recording logic
│   │
│   ├── Notes/
│   │   ├── NoteDetailView.swift   # Note detail and editing
│   │   └── NoteDetailViewModel.swift # Note management logic
│   │
│   └── Settings/
│       ├── SettingsView.swift     # App settings
│       └── SettingsViewModel.swift # Settings management
│
├── AI/
│   ├── GeminiClient.swift         # Gemini API client
│   ├── GeminiModels.swift         # API models and enums
│   └── PromptBuilder.swift        # AI prompt templates
│
├── Data/
│   ├── PersistenceController.swift # Core Data stack
│   └── GemNote.xcdatamodeld       # Core Data model
│
├── Security/
│   └── KeychainManager.swift      # Secure storage
│
├── Models/
│   └── SharedTypes.swift          # Shared types and enums
│
└── UI/
    ├── Components/
    │   ├── NoteCardView.swift     # Note card component
    │   ├── ToggleRowView.swift    # Toggle row component
    │   └── PrimaryButton.swift    # Primary button component
    └── Theme/
        └── GemNoteTheme.swift     # App theme and styling
```

## Core Data Model

### Entities

#### Note
- `id`: UUID (primary key)
- `createdAt`: Date
- `updatedAt`: Date
- `rawText`: String
- `aiSummary`: String? (optional)
- `aiModel`: String? (optional)
- `audioPath`: String? (optional)
- `isAISummaryEnabled`: Bool
- `isTagSuggestionEnabled`: Bool

#### Tag
- `id`: UUID
- `name`: String

#### Attachment (future-ready)
- `id`: UUID
- `type`: String
- `localPath`: String
- `createdAt`: Date

### Relationships
- Note ↔ Tag (many-to-many)
- Note → Attachment (one-to-many)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Rashoooodi/GemNote-iOS.git
cd GemNote-iOS
```

### 2. Open in Xcode

```bash
open GemNote.xcodeproj
```

### 3. Configure Signing

1. Select the **GemNote** target in Xcode
2. Go to **Signing & Capabilities**
3. Select your development team (Personal Team is fine)
4. Xcode will automatically generate a bundle identifier

### 4. Build and Run

1. Select an iPhone simulator or your physical device
2. Press **⌘R** to build and run
3. Grant microphone permissions when prompted

### 5. (Optional) Configure Gemini API

1. Get a free API key from [Google AI Studio](https://ai.google.dev/)
2. Open the app and navigate to Settings
3. Enter your API key in the secure field
4. Select your preferred AI model
5. Enable AI features as desired

## Usage

### Creating Notes

#### Text Notes
1. Tap **"New Note"** on the home screen
2. Type your note content
3. Tap **"Save"**

#### Audio Notes
1. Tap **"Record"** on the home screen
2. Configure AI options if desired
3. Tap the record button to start
4. Tap stop when finished
5. Optionally add text description
6. Tap **"Save Recording"**

### Using AI Features

1. Open any note in detail view
2. Tap the menu (⋯) in the top right
3. Select **"Run AI Processing"**
4. Choose between:
   - **Run with API**: Uses your Gemini API key
   - **Run Dry-Run Mode**: Simulates AI without API calls

### Managing Tags

- Tags are displayed below note content
- Tap **"Add tag"** field in note detail view
- Type tag name and press return
- Tap ✕ on a tag to remove it
- AI can suggest tags automatically if enabled

### Playing Audio

1. Open a note with audio recording
2. Scroll to the **"Audio Recording"** section
3. Tap ▶ to play, ⏸ to pause, ⏹ to stop

## Settings

### API Configuration
- **Gemini API Key**: Securely stored in Keychain
- **AI Model**: Choose between Gemini Pro or Gemini 1.5 Flash

### Default Options
- **Enable AI by Default**: Auto-enable AI features for new notes
- **Enable Dry Run by Default**: Use simulation mode by default

### Data Management
- **Clear All AI Summaries**: Remove AI-generated content (keeps note text)

## Security & Privacy

- ✅ No hardcoded secrets
- ✅ API keys stored in iOS Keychain
- ✅ No analytics or tracking
- ✅ No background data transmission
- ✅ All AI requests are user-initiated
- ✅ HTTPS-only communication
- ✅ Offline-first architecture

## Technical Details

### Architecture
- **Pattern**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI
- **Persistence**: Core Data
- **Networking**: URLSession with async/await
- **Security**: Keychain Services

### Dependencies
- **None** - Pure iOS SDK implementation

### Build Settings
- **Minimum Deployment**: iOS 18.0
- **Swift Version**: 5.0
- **Supported Devices**: iPhone only
- **Bundle Identifier**: com.gemnote.app (customizable)

## Known Limitations

### By Design
- No iPad-specific UI (iPhone layout only)
- No iCloud sync
- No background tasks
- No widgets
- No push notifications
- No Apple Intelligence APIs
- No speech-to-text conversion

### Current Implementation
- Audio files stored locally only
- No audio file compression
- Tags are simple strings (no hierarchies)
- No note search functionality (future enhancement)
- No note export (future enhancement)

## Troubleshooting

### Microphone Permission Denied
1. Go to Settings → Privacy & Security → Microphone
2. Enable access for GemNote

### AI Not Working
1. Verify API key is entered in Settings
2. Check internet connection
3. Try Dry-Run mode to test without API
4. Ensure API key is valid (at least 20 characters)

### Build Errors
1. Ensure Xcode 15+ is installed
2. Clean build folder (⇧⌘K)
3. Verify signing team is selected
4. Check minimum iOS version is 18.0

## Future Enhancements (TODO)

- [ ] Note search functionality
- [ ] Export notes to various formats
- [ ] Rich text editing
- [ ] Image attachments
- [ ] Note categories/folders
- [ ] Sharing notes
- [ ] Note templates
- [ ] Backup/restore functionality
- [ ] Audio file compression
- [ ] Voice-to-text transcription
- [ ] Multiple audio recordings per note

## Contributing

This is a personal project, but suggestions and feedback are welcome! Please open an issue for bugs or feature requests.

## License

This project is provided as-is for educational and personal use.

## Credits

- Built with ❤️ using SwiftUI and Core Data
- AI powered by Google Gemini API
- Icons from SF Symbols

## Support

For issues or questions:
1. Check this README first
2. Review the code documentation
3. Open a GitHub issue

---

**Note**: This app requires iOS 18.0 or later and is designed for iPhone only. AI features are optional and require a free Google Gemini API key.