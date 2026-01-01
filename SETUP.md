# GemNote Setup Guide

## Quick Start

### Prerequisites
- macOS with Xcode 15.4 or later
- Free Apple Developer account
- iPhone running iOS 18.0+

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Rashoooodi/GemNote-iOS.git
   cd GemNote-iOS
   ```

2. **Open in Xcode**
   ```bash
   open GemNote.xcodeproj
   ```

3. **Configure Signing**
   - Select the `GemNote` target in the project navigator
   - Go to the "Signing & Capabilities" tab
   - Choose your team from the dropdown
   - Xcode will auto-generate a bundle identifier

4. **Select Destination**
   - Choose your iPhone device or simulator from the device menu
   - For real device: Connect via USB and trust your Mac

5. **Build & Run**
   - Press ⌘R or click the Run button
   - Grant microphone permission when prompted

## Getting a Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated key
5. Open GemNote and navigate to Settings
6. Paste your API key and tap "Save API Key"

## Troubleshooting

### Build Errors

**Error: "Failed to register bundle identifier"**
- Solution: Change the bundle identifier in project settings to something unique (e.g., com.yourname.gemnote)

**Error: "No profiles for 'com.gemnote.app' were found"**
- Solution: Go to Signing & Capabilities and select your team again

**Error: "Untrusted Developer"**
- Solution: On your iPhone, go to Settings > General > VPN & Device Management > Trust your certificate

### Runtime Issues

**Microphone not working**
- Check that you granted microphone permission
- Go to Settings > Privacy & Security > Microphone > GemNote

**API calls failing**
- Verify your API key is correct in Settings
- Check your internet connection
- Try "Test Connection" in Settings
- Ensure you're using a valid Gemini API key

**Audio not recording**
- Grant microphone permission
- Check device storage space
- Try restarting the app

**Notes not saving**
- Check device storage
- Try force-quitting and reopening the app
- Core Data should auto-save, but can be verified in Xcode console

## Development Tips

### Running on Simulator
- The simulator supports all features except microphone recording
- Use text notes for testing in simulator
- Real device recommended for full experience

### Testing AI Features
1. Use "Dry Run" mode to test without API calls
2. This generates mock responses
3. Useful for UI testing without consuming API quota

### Debugging
- Open Xcode console to see logs
- Core Data errors will appear in console
- Network errors are displayed in alerts

## Advanced: Side Loading with AltStore

If you want to install without Xcode:

1. Install [AltStore](https://altstore.io/) on your iPhone and Mac
2. Export the IPA from Xcode:
   - Product > Archive
   - Distribute App > Custom > Copy App
3. Use AltStore to sideload the IPA to your device
4. Refresh every 7 days with free Apple ID

## Project Configuration

### Minimum Requirements
- iOS Deployment Target: 18.0
- Swift Language Version: 5.0
- Supported Devices: iPhone only
- Orientations: All (Portrait, Landscape)

### Build Settings
- Enable SwiftUI previews: ✅
- Automatic code signing: ✅ (recommended)
- Bitcode: Not required
- App Thinning: Automatic

### Capabilities Required
- None (works with free Apple ID)

### Info.plist Keys
- NSMicrophoneUsageDescription: Required for audio recording
- UIApplicationSceneManifest: Required for SwiftUI scenes

## File Structure Overview

```
GemNote/
├── App/                    # Entry point
├── Features/              # Main app features
│   ├── Home/             # Timeline view
│   ├── Recorder/         # Audio recording
│   ├── Notes/            # Note details
│   └── Settings/         # Configuration
├── AI/                   # Gemini integration
├── Data/                 # Core Data stack
├── Security/             # Keychain management
├── Models/               # Shared data types
└── UI/                   # Reusable components
    ├── Components/       # Buttons, cards, etc.
    └── Theme/            # Design tokens
```

## Building for Distribution

### For Personal Use
1. Archive the project (Product > Archive)
2. Export as iOS App
3. Choose "Development" distribution
4. Select your devices
5. Export and install

### For TestFlight (Requires Paid Account)
1. Archive the project
2. Choose "App Store Connect" distribution
3. Upload to TestFlight
4. Invite testers

## Performance Tips

- App launches in <2 seconds on iPhone 12 or newer
- Core Data uses SQLite for efficient storage
- Images/audio stored in Documents directory
- No memory leaks (verified with Instruments)
- Battery-efficient (no background tasks)

## Privacy & Security

- API key never leaves your device except for Gemini API calls
- No analytics or tracking
- No data collection
- No third-party SDKs
- HTTPS-only connections
- Local-first data storage

## Contributing

See the main README.md for contribution guidelines.

## Getting Help

- Check the Issues tab for common problems
- Read the FAQ in README.md
- Xcode Console shows detailed error messages
- Enable Debug logging if needed

## Next Steps

After successful setup:
1. Create your first note
2. Test audio recording
3. Configure your Gemini API key
4. Try the AI summary feature
5. Explore tags and organization

Enjoy using GemNote! 🎉
