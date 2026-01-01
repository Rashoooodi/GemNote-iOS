//
//  NoteDetailViewModel.swift
//  GemNote
//
//  View model for note detail and AI operations.
//

import Foundation
import AVFoundation
import CoreData

/// Manages note detail display and AI operations
@MainActor
class NoteDetailViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var note: Note
    @Published var isProcessingAI: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var selectedModel: GeminiModel
    @Published var isPlayingAudio: Bool = false
    @Published var newTagName: String = ""
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Initialization
    
    init(note: Note, context: NSManagedObjectContext) {
        self.note = note
        self.context = context
        
        // Load selected model from UserDefaults
        let modelRaw = UserDefaults.standard.string(forKey: "selected_gemini_model") ?? GeminiModel.gemini15Flash.rawValue
        self.selectedModel = GeminiModel(rawValue: modelRaw) ?? .gemini15Flash
        
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Run AI summary and tag suggestion
    func runAI(isDryRun: Bool = false) async {
        guard let rawText = note.rawText, !rawText.isEmpty else {
            showErrorAlert("Note has no content to process")
            return
        }
        
        isProcessingAI = true
        
        do {
            // Build prompt based on enabled features
            let prompt: String
            if note.isAISummaryEnabled && note.isTagSuggestionEnabled {
                prompt = PromptBuilder.summarizeAndSuggestTags(text: rawText)
            } else if note.isAISummaryEnabled {
                prompt = PromptBuilder.summarize(text: rawText)
            } else if note.isTagSuggestionEnabled {
                prompt = PromptBuilder.suggestTags(text: rawText)
            } else {
                showErrorAlert("No AI features enabled for this note")
                isProcessingAI = false
                return
            }
            
            // Call Gemini API
            let response = try await GeminiClient.shared.generate(
                prompt: prompt,
                model: selectedModel,
                isDryRun: isDryRun
            )
            
            // Parse response
            let parsed = GeminiClient.ParsedResponse.parse(response)
            
            // Update note
            if note.isAISummaryEnabled, let summary = parsed.summary {
                note.aiSummary = summary
                note.aiModel = selectedModel.rawValue
            }
            
            if note.isTagSuggestionEnabled && !parsed.tags.isEmpty {
                addTags(parsed.tags)
            }
            
            note.updatedAt = Date()
            try context.save()
            
            showSuccessAlert(isDryRun ? "Dry run completed" : "AI processing completed")
            
        } catch {
            showErrorAlert("AI processing failed: \(error.localizedDescription)")
        }
        
        isProcessingAI = false
    }
    
    /// Add a new tag
    func addTag(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !trimmedName.isEmpty else { return }
        
        // Check if tag already exists
        let existingTags = (note.tags as? Set<Tag>) ?? []
        if existingTags.contains(where: { $0.name == trimmedName }) {
            showErrorAlert("Tag already exists")
            return
        }
        
        // Check if tag exists in database
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", trimmedName)
        
        let tag: Tag
        if let existingTag = try? context.fetch(fetchRequest).first {
            tag = existingTag
        } else {
            tag = Tag(context: context)
            tag.id = UUID()
            tag.name = trimmedName
        }
        
        note.addToTags(tag)
        note.updatedAt = Date()
        
        do {
            try context.save()
            newTagName = ""
        } catch {
            showErrorAlert("Failed to add tag: \(error.localizedDescription)")
        }
    }
    
    /// Remove a tag
    func removeTag(_ tag: Tag) {
        note.removeFromTags(tag)
        note.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            showErrorAlert("Failed to remove tag: \(error.localizedDescription)")
        }
    }
    
    /// Update note text
    func updateNoteText(_ text: String) {
        note.rawText = text
        note.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            showErrorAlert("Failed to update note: \(error.localizedDescription)")
        }
    }
    
    /// Delete the note
    func deleteNote() async {
        do {
            try PersistenceController.shared.deleteNote(note)
        } catch {
            showErrorAlert("Failed to delete note: \(error.localizedDescription)")
        }
    }
    
    /// Play audio recording
    func playAudio() {
        guard let audioPath = note.audioPath else {
            showErrorAlert("No audio recording found")
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(audioPath)
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            showErrorAlert("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlayingAudio = true
        } catch {
            showErrorAlert("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    /// Stop audio playback
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlayingAudio = false
    }
    
    // MARK: - Private Methods
    
    private func addTags(_ tagNames: [String]) {
        for tagName in tagNames {
            addTag(tagName)
        }
    }
    
    private func showSuccessAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func showErrorAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

// MARK: - AVAudioPlayerDelegate

extension NoteDetailViewModel: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlayingAudio = false
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            isPlayingAudio = false
            showErrorAlert("Audio playback error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}
