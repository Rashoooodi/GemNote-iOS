//
//  NoteDetailViewModel.swift
//  GemNote
//
//  ViewModel for note detail view
//

import Foundation
import CoreData
import AVFoundation

/// ViewModel for note detail screen
@MainActor
final class NoteDetailViewModel: NSObject, ObservableObject {
    @Published var note: Note
    @Published var aiProcessingStatus: AIProcessingStatus = .idle
    @Published var playbackState: PlaybackState = .idle
    @Published var playbackDuration: TimeInterval = 0
    @Published var errorMessage: String?
    @Published var tagInputText = ""
    
    private let context: NSManagedObjectContext
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    
    init(note: Note, context: NSManagedObjectContext) {
        self.note = note
        self.context = context
        super.init()
    }
    
    // MARK: - AI Operations
    
    func runAIProcessing(isDryRun: Bool = false) async {
        guard let rawText = note.rawText, !rawText.isEmpty else {
            errorMessage = "No text to process"
            return
        }
        
        aiProcessingStatus = .processing
        
        do {
            let model = UserDefaults.standard.selectedGeminiModel
            
            // Generate summary if enabled
            if note.isAISummaryEnabled {
                let summary = try await GeminiClient.shared.generateSummary(
                    for: rawText,
                    model: model,
                    isDryRun: isDryRun
                )
                note.aiSummary = summary
                note.aiModel = model.rawValue
            }
            
            // Generate tags if enabled
            if note.isTagSuggestionEnabled {
                let tagNames = try await GeminiClient.shared.generateTags(
                    for: rawText,
                    model: model,
                    isDryRun: isDryRun
                )
                
                // Add tags to note
                for tagName in tagNames {
                    addTag(name: tagName)
                }
            }
            
            note.updatedAt = Date()
            try context.save()
            
            aiProcessingStatus = .completed
        } catch {
            aiProcessingStatus = .failed(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func clearAISummary() {
        note.aiSummary = nil
        note.aiModel = nil
        note.updatedAt = Date()
        try? context.save()
    }
    
    // MARK: - Tag Management
    
    func addTag(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Check if tag already exists
        let existingTags = (note.tags as? Set<Tag>) ?? []
        if existingTags.contains(where: { $0.name == trimmedName }) {
            return
        }
        
        // Find or create tag
        let fetchRequest = NSFetchRequest<Tag>(entityName: "Tag")
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
        try? context.save()
    }
    
    func removeTag(_ tag: Tag) {
        note.removeFromTags(tag)
        note.updatedAt = Date()
        try? context.save()
    }
    
    // MARK: - Audio Playback
    
    func playAudio() {
        guard let audioPath = note.audioPath else {
            errorMessage = "No audio file available"
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(audioPath)
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            errorMessage = "Audio file not found"
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            playbackState = .playing
            playbackDuration = 0
            
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    self.playbackDuration = self.audioPlayer?.currentTime ?? 0
                }
            }
        } catch {
            errorMessage = "Failed to play audio: \(error.localizedDescription)"
        }
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        playbackState = .paused
        playbackTimer?.invalidate()
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        playbackState = .stopped
        playbackTimer?.invalidate()
        playbackDuration = 0
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: - Note Management
    
    func updateNoteText(_ text: String) {
        note.rawText = text
        note.updatedAt = Date()
        try? context.save()
    }
    
    func deleteNote() throws {
        // Delete audio file if exists
        if let audioPath = note.audioPath {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentsPath.appendingPathComponent(audioPath)
            try? FileManager.default.removeItem(at: audioURL)
        }
        
        context.delete(note)
        try context.save()
    }
    
    // MARK: - Helper Properties
    
    var formattedPlaybackTime: String {
        guard let player = audioPlayer else { return "00:00 / 00:00" }
        let current = Int(player.currentTime)
        let total = Int(player.duration)
        return String(format: "%02d:%02d / %02d:%02d",
                      current / 60, current % 60,
                      total / 60, total % 60)
    }
    
    var tags: [Tag] {
        Array((note.tags as? Set<Tag>) ?? []).sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}

// MARK: - AVAudioPlayerDelegate

extension NoteDetailViewModel: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            playbackState = .stopped
            playbackDuration = 0
            playbackTimer?.invalidate()
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            errorMessage = error?.localizedDescription ?? "Audio playback error"
            playbackState = .stopped
        }
    }
}
