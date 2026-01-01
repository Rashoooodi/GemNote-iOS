# GemNote API Documentation

## Core Data API

### Note Entity

The central entity for storing note information.

**Attributes:**
- `id: UUID` - Unique identifier
- `createdAt: Date` - Creation timestamp
- `updatedAt: Date` - Last modification timestamp
- `rawText: String` - User-entered note content
- `aiSummary: String?` - AI-generated summary (optional)
- `aiModel: String?` - Model used for AI generation (optional)
- `audioPath: String?` - Relative path to audio file (optional)
- `isAISummaryEnabled: Bool` - Whether AI summary should be generated
- `isTagSuggestionEnabled: Bool` - Whether AI tags should be suggested

**Relationships:**
- `tags: Set<Tag>` - Many-to-many relationship with tags
- `attachments: Set<Attachment>` - One-to-many relationship with attachments

**Example Usage:**
```swift
let note = Note(context: context)
note.id = UUID()
note.createdAt = Date()
note.updatedAt = Date()
note.rawText = "My first note"
note.isAISummaryEnabled = true
try context.save()
```

### Tag Entity

Represents tags for organizing notes.

**Attributes:**
- `id: UUID` - Unique identifier
- `name: String` - Tag name (lowercase, single word)

**Relationships:**
- `notes: Set<Note>` - Many-to-many relationship with notes

**Example Usage:**
```swift
let tag = Tag(context: context)
tag.id = UUID()
tag.name = "work"
note.addToTags(tag)
try context.save()
```

### Attachment Entity

Future-ready entity for file attachments (not heavily used in v1.0).

**Attributes:**
- `id: UUID` - Unique identifier
- `type: String` - File type (e.g., "audio", "image")
- `localPath: String` - Path to file in documents directory
- `createdAt: Date` - Creation timestamp

---

## AI Client API

### GeminiClient

Singleton client for interacting with Google's Gemini API.

**Methods:**

#### `generate(prompt:model:isDryRun:) async throws -> String`

Generate AI content from a text prompt.

**Parameters:**
- `prompt: String` - The input text prompt
- `model: GeminiModel` - Which Gemini model to use
- `isDryRun: Bool` - If true, returns mock data without API call

**Returns:** `String` - Generated text response

**Throws:** `GemNoteError` if API key missing, network error, or invalid response

**Example:**
```swift
let summary = try await GeminiClient.shared.generate(
    prompt: PromptBuilder.summarize(text: noteText),
    model: .gemini15Flash,
    isDryRun: false
)
```

#### `ParsedResponse.parse(_:) -> ParsedResponse`

Parse a structured AI response into summary and tags.

**Parameters:**
- `text: String` - Raw AI response text

**Returns:** `ParsedResponse` containing optional summary and tag array

**Example:**
```swift
let response = try await GeminiClient.shared.generate(...)
let parsed = GeminiClient.ParsedResponse.parse(response)
print(parsed.summary ?? "No summary")
print(parsed.tags) // ["work", "urgent", "meeting"]
```

---

## Prompt Builder API

### PromptBuilder

Static methods for constructing AI prompts.

**Methods:**

#### `summarize(text:) -> String`

Generate a summary prompt.

**Parameters:**
- `text: String` - Note content to summarize

**Returns:** `String` - Formatted prompt

#### `suggestTags(text:) -> String`

Generate a tag suggestion prompt.

**Parameters:**
- `text: String` - Note content to generate tags for

**Returns:** `String` - Formatted prompt

#### `summarizeAndSuggestTags(text:) -> String`

Generate combined summary and tag prompt.

**Parameters:**
- `text: String` - Note content

**Returns:** `String` - Formatted prompt for both operations

**Example:**
```swift
let prompt = PromptBuilder.summarizeAndSuggestTags(text: myNote)
let response = try await GeminiClient.shared.generate(prompt: prompt, ...)
```

---

## Keychain Manager API

### KeychainManager

Secure storage manager for sensitive data.

**Methods:**

#### `save(_:forKey:) throws`

Save a string value to Keychain.

**Parameters:**
- `value: String` - Value to store
- `key: String` - Keychain key

**Throws:** `KeychainError` on save failure

#### `retrieve(forKey:) throws -> String?`

Retrieve a string value from Keychain.

**Parameters:**
- `key: String` - Keychain key

**Returns:** `String?` - Retrieved value or nil if not found

**Throws:** `KeychainError` on retrieval failure

#### `delete(forKey:) throws`

Delete a value from Keychain.

**Parameters:**
- `key: String` - Keychain key

**Throws:** `KeychainError` on deletion failure

**Example:**
```swift
// Save API key
try KeychainManager.shared.save(apiKey, forKey: KeychainManager.Keys.geminiAPIKey)

// Retrieve API key
let key = try KeychainManager.shared.retrieve(forKey: KeychainManager.Keys.geminiAPIKey)

// Delete API key
try KeychainManager.shared.delete(forKey: KeychainManager.Keys.geminiAPIKey)
```

---

## Persistence Controller API

### PersistenceController

Manages Core Data stack.

**Properties:**
- `shared: PersistenceController` - Singleton instance
- `preview: PersistenceController` - Preview instance with sample data
- `container: NSPersistentContainer` - Core Data container

**Methods:**

#### `save()`

Save pending changes to persistent store.

#### `clearAllAISummaries() throws`

Remove all AI summaries from all notes.

**Throws:** Core Data errors

#### `deleteNote(_:) throws`

Delete a note and its audio file.

**Parameters:**
- `note: Note` - Note to delete

**Throws:** Core Data or file system errors

#### `getDocumentsDirectory() -> URL`

Get the app's documents directory.

**Returns:** `URL` - Documents directory path

**Example:**
```swift
let controller = PersistenceController.shared
let context = controller.container.viewContext

// Save changes
controller.save()

// Clear AI data
try controller.clearAllAISummaries()

// Delete note
try controller.deleteNote(myNote)
```

---

## View Models

### HomeViewModel

Manages home timeline state.

**Published Properties:**
- `recentNotes: [Note]` - Recent notes array
- `lastAINote: Note?` - Most recent AI-processed note
- `showError: Bool` - Error alert visibility
- `errorMessage: String` - Error message text

**Methods:**
- `fetchRecentNotes()` - Load recent notes from Core Data
- `createTextNote() -> Note` - Create new empty note
- `getGreeting() -> String` - Get time-based greeting

### RecorderViewModel

Manages audio recording state.

**Published Properties:**
- `recordingState: RecordingState` - Current recording state
- `recordingTime: TimeInterval` - Recording duration
- `enableAISummary: Bool` - AI summary toggle
- `enableTagSuggestion: Bool` - Tag suggestion toggle
- `enableDryRun: Bool` - Dry run mode toggle
- `rawText: String` - Note text content

**Methods:**
- `startRecording()` - Begin audio recording
- `stopRecording()` - Stop recording
- `saveNote()` - Save note with audio
- `cancelRecording()` - Discard recording

### NoteDetailViewModel

Manages note detail and AI operations.

**Published Properties:**
- `note: Note` - Current note
- `isProcessingAI: Bool` - AI processing indicator
- `selectedModel: GeminiModel` - Selected AI model
- `isPlayingAudio: Bool` - Audio playback state
- `newTagName: String` - New tag input field

**Methods:**
- `runAI(isDryRun:) async` - Execute AI operations
- `addTag(_:)` - Add tag to note
- `removeTag(_:)` - Remove tag from note
- `updateNoteText(_:)` - Update note content
- `deleteNote() async` - Delete the note
- `playAudio()` - Play audio recording
- `stopAudio()` - Stop audio playback

### SettingsViewModel

Manages app settings and preferences.

**Published Properties:**
- `apiKey: String` - Gemini API key
- `selectedModel: GeminiModel` - Default AI model
- `enableAIByDefault: Bool` - AI default toggle
- `enableDryRunByDefault: Bool` - Dry run default toggle

**Methods:**
- `loadSettings()` - Load settings from storage
- `saveAPIKey()` - Save API key to Keychain
- `saveModelPreference()` - Save model to UserDefaults
- `clearAllAISummaries()` - Clear all AI data
- `testAPIConnection() async` - Test API connectivity

---

## Theme API

### GemNoteTheme

Design system constants.

**Colors:**
- `Colors.primary` - Primary brand color (blue)
- `Colors.secondary` - Secondary color (gray)
- `Colors.accent` - Accent color (green)
- `Colors.background` - Main background
- `Colors.destructive` - Delete/warning color (red)

**Typography:**
- `Typography.largeTitle` - Large title font
- `Typography.title` - Section titles
- `Typography.headline` - Headlines
- `Typography.body` - Body text
- `Typography.caption` - Small text

**Spacing:**
- `Spacing.xs` - 4pt
- `Spacing.sm` - 8pt
- `Spacing.md` - 16pt
- `Spacing.lg` - 24pt
- `Spacing.xl` - 32pt

**Corner Radius:**
- `CornerRadius.sm` - 8pt
- `CornerRadius.md` - 12pt
- `CornerRadius.lg` - 16pt

**Example:**
```swift
Text("Hello")
    .font(GemNoteTheme.Typography.headline)
    .foregroundColor(GemNoteTheme.Colors.primary)
    .padding(GemNoteTheme.Spacing.md)
    .background(GemNoteTheme.Colors.secondaryBackground)
    .cornerRadius(GemNoteTheme.CornerRadius.md)
```

---

## UI Components

### PrimaryButton

Standard primary action button.

**Parameters:**
- `title: String` - Button text
- `icon: String?` - SF Symbol name (optional)
- `isLoading: Bool` - Loading indicator (default: false)
- `action: () -> Void` - Button tap handler

### SecondaryButton

Secondary action button with outline.

**Parameters:**
- `title: String` - Button text
- `icon: String?` - SF Symbol name (optional)
- `action: () -> Void` - Button tap handler

### DestructiveButton

Delete/destructive action button.

**Parameters:**
- `title: String` - Button text
- `icon: String?` - SF Symbol name (optional)
- `action: () -> Void` - Button tap handler

### NoteCardView

Card component for displaying notes in lists.

**Parameters:**
- `note: Note` - Note to display
- `onTap: () -> Void` - Tap handler

### ToggleRowView

Settings-style toggle row.

**Parameters:**
- `icon: String` - SF Symbol name
- `title: String` - Row title
- `subtitle: String?` - Optional subtitle (optional)
- `isOn: Binding<Bool>` - Toggle binding

**Example:**
```swift
ToggleRowView(
    icon: "wand.and.stars",
    title: "Enable AI",
    subtitle: "Generate summaries",
    isOn: $enableAI
)
```

---

## Error Types

### GemNoteError

App-specific errors.

**Cases:**
- `.noAPIKey` - API key not configured
- `.networkError(Error)` - Network request failed
- `.invalidResponse` - Invalid API response
- `.audioRecordingFailed` - Recording error
- `.audioPlaybackFailed` - Playback error

### KeychainError

Keychain operation errors.

**Cases:**
- `.invalidData` - Data format error
- `.saveFailed(OSStatus)` - Save operation failed
- `.retrieveFailed(OSStatus)` - Retrieval failed
- `.deleteFailed(OSStatus)` - Deletion failed

---

## Enums

### GeminiModel

Available Gemini models.

**Cases:**
- `.geminiPro` - Gemini Pro model
- `.gemini15Flash` - Gemini 1.5 Flash model

**Properties:**
- `displayName: String` - Human-readable name
- `rawValue: String` - API identifier

### RecordingState

Audio recording states.

**Cases:**
- `.idle` - Not recording
- `.recording` - Currently recording
- `.paused` - Recording paused
- `.finished` - Recording complete

---

## UserDefaults Keys

### Settings Keys
- `"selected_gemini_model"` - GeminiModel raw value
- `"enable_ai_by_default"` - Bool
- `"enable_dry_run_by_default"` - Bool

### Keychain Keys
- `KeychainManager.Keys.geminiAPIKey` - "gemini_api_key"

---

## Best Practices

### Core Data
- Always use `@MainActor` for UI updates
- Save context after modifications
- Use fetch request predicates for filtering
- Batch operations for better performance

### Async/Await
- Use `async/await` for all network calls
- Handle errors with do-catch blocks
- Update UI on main actor
- Show loading indicators during operations

### Security
- Never log API keys or secrets
- Use Keychain for sensitive data
- UserDefaults for non-sensitive settings only
- HTTPS-only for network requests

### Audio
- Request permissions before recording
- Handle audio session interruptions
- Clean up audio files on deletion
- Store paths, not full URLs in Core Data

---

## Testing

### Dry Run Mode
Use dry run mode to test AI features without API calls:

```swift
let result = try await GeminiClient.shared.generate(
    prompt: prompt,
    model: .gemini15Flash,
    isDryRun: true  // No API call made
)
```

### Preview Data
Use `PersistenceController.preview` for SwiftUI previews:

```swift
#Preview {
    HomeView(context: PersistenceController.preview.container.viewContext)
}
```

---

For more information, see the README.md and SETUP.md files.
