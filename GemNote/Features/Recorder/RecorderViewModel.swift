//
//  RecorderViewModel.swift
//  GemNote
//
//  ViewModel for audio recording
//

import Foundation
import AVFoundation
import CoreData

/// ViewModel for audio recording functionality
@MainActor
final class RecorderViewModel: NSObject, ObservableObject {
    @Published var recordingState: RecordingState = .idle
    @Published var recordingDuration: TimeInterval = 0
    @Published var enableAISummary: Bool
    @Published var enableTagSuggestion: Bool
    @Published var enableDryRun: Bool
    @Published var errorMessage: String?
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var audioFileURL: URL?
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.enableAISummary = UserDefaults.standard.enableAIByDefault
        self.enableTagSuggestion = UserDefaults.standard.enableAIByDefault
        self.enableDryRun = UserDefaults.standard.enableDryRunByDefault
        super.init()
    }
    
    // MARK: - Recording Control
    
    func startRecording() async {
        // Request permission
        let permissionGranted = await requestMicrophonePermission()
        guard permissionGranted else {
            errorMessage = "Microphone permission denied. Please enable in Settings."
            return
        }
        
        // Setup audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            errorMessage = "Failed to setup audio session: \(error.localizedDescription)"
            return
        }
        
        // Create audio file URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "recording_\(UUID().uuidString).m4a"
        audioFileURL = documentsPath.appendingPathComponent(fileName)
        
        guard let url = audioFileURL else {
            errorMessage = "Failed to create audio file URL"
            return
        }
        
        // Setup recorder settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            recordingState = .recording
            recordingDuration = 0
            
            // Start timer
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    self.recordingDuration = self.audioRecorder?.currentTime ?? 0
                }
            }
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingState = .stopped
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func cancelRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingState = .idle
        recordingDuration = 0
        
        // Delete audio file
        if let url = audioFileURL {
            try? FileManager.default.removeItem(at: url)
        }
        audioFileURL = nil
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: - Save Note
    
    func saveNote(text: String) throws -> Note {
        let note = Note(context: context)
        note.id = UUID()
        note.createdAt = Date()
        note.updatedAt = Date()
        note.rawText = text.isEmpty ? "Audio note" : text
        note.audioPath = audioFileURL?.lastPathComponent
        note.isAISummaryEnabled = enableAISummary
        note.isTagSuggestionEnabled = enableTagSuggestion
        
        try context.save()
        
        // Reset state
        audioFileURL = nil
        recordingState = .idle
        recordingDuration = 0
        
        return note
    }
    
    // MARK: - Permissions
    
    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    // MARK: - Helper Properties
    
    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var canSave: Bool {
        recordingState == .stopped && audioFileURL != nil
    }
}

// MARK: - AVAudioRecorderDelegate

extension RecorderViewModel: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if !flag {
                errorMessage = "Recording failed"
            }
        }
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in
            errorMessage = error?.localizedDescription ?? "Recording error occurred"
        }
    }
}
