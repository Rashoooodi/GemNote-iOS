# GemNote

A production-quality iOS note-taking app with optional AI-powered summaries and tag suggestions using Google's Gemini API.

## Features

- 📝 **Text Notes**: Quick text note creation and editing
- 🎙️ **Audio Recording**: Record audio notes with AVFoundation
- 🤖 **AI Summaries**: Optional Gemini-powered note summaries
- 🏷️ **Smart Tags**: AI-suggested tags for better organization
- 🔒 **Secure Storage**: API keys stored in iOS Keychain
- 💾 **Offline-First**: Core Data for local persistence
- 🎨 **Apple-Style UI**: Clean SwiftUI interface following HIG

## Requirements

- **iOS**: 18.0+
- **Device**: iPhone only
- **Xcode**: 15.4+
- **Swift**: 5.9+
- **Apple ID**: Free personal account compatible

## Tech Stack

- **UI Framework**: SwiftUI (iOS 18+)
- **Navigation**: NavigationStack
- **Persistence**: Core Data
- **Networking**: URLSession with async/await
- **Audio**: AVFoundation (AVAudioRecorder/Player)
- **Security**: Keychain Services
- **Settings**: UserDefaults (non-sensitive data only)

## Project Structure

```
GemNote/
├── App/
│   └── GemNoteApp.swift          # App entry point
│
├── Features/
│   ├── Home/                     # Main timeline
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Recorder/                 # Audio recording
│   │   ├── RecorderView.swift
│   │   └── RecorderViewModel.swift
│   ├── Notes/                    # Note detail & editing
│   │   ├── NoteDetailView.swift
│   │   └── NoteDetailViewModel.swift
│   └── Settings/                 # App configuration
│       ├── SettingsView.swift
│       └── SettingsViewModel.swift
│
├── AI/
│   ├── GeminiClient.swift        # API client
│   ├── GeminiModels.swift        # Request/response models
│   └── PromptBuilder.swift       # Prompt templates
│
├── Data/
│   ├── PersistenceController.swift
│   └── GemNote.xcdatamodeld      # Core Data model
│
├── Security/
│   └── KeychainManager.swift     # Secure key storage
│
├── Models/
│   └── SharedTypes.swift         # Shared types & enums
│
└── UI/
    ├── Components/               # Reusable UI components
    │   ├── NoteCardView.swift
    │   ├── ToggleRowView.swift
    │   └── PrimaryButton.swift
    └── Theme/
        └── GemNoteTheme.swift    # Design system
```

## Core Data Schema

### Note Entity
- `id`: UUID
- `createdAt`: Date
- `updatedAt`: Date
- `rawText`: String
- `aiSummary`: String? (optional)
- `aiModel`: String? (optional)
- `audioPath`: String? (optional)
- `isAISummaryEnabled`: Bool
- `isTagSuggestionEnabled`: Bool
- `tags`: Relationship to Tag (many-to-many)
- `attachments`: Relationship to Attachment (one-to-many)

### Tag Entity
- `id`: UUID
- `name`: String
- `notes`: Relationship to Note (many-to-many)

### Attachment Entity (future expansion)
- `id`: UUID
- `type`: String
- `localPath`: String
- `createdAt`: Date

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

### 3. Configure Code Signing

1. Select the **GemNote** target
2. Go to **Signing & Capabilities**
3. Select your Apple ID team
4. Xcode will automatically provision the app

### 4. Build and Run

- Select an iPhone simulator or connected device
- Press **⌘R** to build and run

## AI Setup (Optional)

1. Get a free API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Open the app and navigate to **Settings**
3. Enter your API key in the secure field
4. Tap **Save API Key**
5. Test the connection with **Test Connection**

## Usage

### Creating Notes

**Text Note:**
1. Tap "Text Note" on the home screen
2. Enter your content
3. Enable AI features if desired
4. Note is auto-saved

**Audio Note:**
1. Tap "Record" on the home screen
2. Grant microphone permission
3. Record your audio
4. Stop and add text description
5. Toggle AI options
6. Tap "Save Note"

### AI Features

**Generate Summary:**
1. Open a note in detail view
2. Select your preferred Gemini model
3. Tap "Run AI" for real processing
4. Or tap "Dry Run" to test without API calls

**Tag Suggestions:**
- Enable "Tag Suggestions" when creating/editing notes
- AI will suggest up to 5 relevant tags
- Edit or remove suggested tags as needed

### Settings

- **API Key**: Store Gemini API key securely
- **Model Selection**: Choose between Gemini Pro and Gemini 1.5 Flash
- **Default Behaviors**: Set AI and dry-run preferences
- **Data Management**: Clear all AI summaries

## Architecture Highlights

### MVVM Pattern
- Each feature has a dedicated ViewModel
- ViewModels manage state and business logic
- Views are declarative and reactive

### Async/Await Networking
```swift
let response = try await GeminiClient.shared.generate(
    prompt: prompt,
    model: .gemini15Flash,
    isDryRun: false
)
```

### Secure Storage
```swift
try KeychainManager.shared.save(apiKey, forKey: "gemini_api_key")
let key = try KeychainManager.shared.retrieve(forKey: "gemini_api_key")
```

### Core Data Integration
```swift
let controller = PersistenceController.shared
let context = controller.container.viewContext
// Use with @Environment(\.managedObjectContext)
```

## Security & Privacy

- ✅ No hardcoded secrets
- ✅ API keys stored in Keychain
- ✅ HTTPS-only network requests
- ✅ No background data transmission
- ✅ User-initiated AI operations
- ✅ No analytics or tracking
- ✅ No device identifiers sent

## Constraints & Limitations

- **No iCloud**: All data is local
- **No Background Tasks**: No background refresh or processing
- **No Push Notifications**: No server communication
- **No Firebase**: No third-party analytics
- **No Private APIs**: Uses only public iOS APIs
- **No Special Entitlements**: Works with free Apple ID

## Device Compatibility

- iPhone 8 and newer
- iOS 18.0+
- Portrait and landscape orientations
- VoiceOver compatible (accessibility labels included)

## Building for Real Device

1. Connect your iPhone via USB
2. Trust your computer on the device
3. Select your device in Xcode
4. Build and run (⌘R)
5. Go to **Settings > General > VPN & Device Management**
6. Trust your developer certificate

## Third-Party Signing (Advanced)

This app is designed to be re-signable with tools like:
- AltStore
- Sideloadly
- iOS App Signer

No App Store dependencies or entitlements that would block this workflow.

## Future Enhancements (TODO)

- [ ] Speech-to-text for audio transcription
- [ ] Export notes to PDF/Markdown
- [ ] Note categories and folders
- [ ] Search functionality
- [ ] Rich text editing
- [ ] Image attachments
- [ ] Widgets
- [ ] Spotlight integration
- [ ] Handoff support
- [ ] Dark mode refinements

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Follow existing code style
4. Add comments for complex logic
5. Test on real device
6. Submit a pull request

## License

This project is available for personal and educational use. See LICENSE file for details.

## Acknowledgments

- Google Gemini API for AI capabilities
- Apple's Human Interface Guidelines
- SwiftUI community resources

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Check existing issues first
- Provide device info and iOS version

---

**Built with ❤️ using SwiftUI and Core Data**