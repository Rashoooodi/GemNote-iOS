//
//  RecorderViewModel.swift
//  GemNote
//
//  View model for audio recording.
//

import Foundation
import AVFoundation
import CoreData

/// Manages audio recording functionality
@MainActor
class RecorderViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var recordingState: RecordingState = .idle
    @Published var recordingTime: TimeInterval = 0
    @Published var enableAISummary: Bool = false
    @Published var enableTagSuggestion: Bool = false
    @Published var enableDryRun: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var rawText: String = ""
    
    // MARK: - Private Properties
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var audioFileURL: URL?
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        loadDefaults()
    }
    
    // MARK: - Public Methods
    
    /// Start recording audio
    func startRecording() {
        // Request permission
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
            Task { @MainActor in
                guard let self = self else { return }
                
                if allowed {
                    self.beginRecording()
                } else {
                    self.showErrorAlert("Microphone permission denied. Please enable it in Settings.")
                }
            }
        }
    }
    
    /// Stop recording audio
    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingState = .finished
    }
    
    /// Save the recorded note
    func saveNote() {
        guard recordingState == .finished else {
            showErrorAlert("Please finish recording first")
            return
        }
        
        guard !rawText.isEmpty else {
            showErrorAlert("Please enter some text for the note")
            return
        }
        
        let note = Note(context: context)
        note.id = UUID()
        note.createdAt = Date()
        note.updatedAt = Date()
        note.rawText = rawText
        note.isAISummaryEnabled = enableAISummary
        note.isTagSuggestionEnabled = enableTagSuggestion
        
        // Save audio file path if recording was made
        if let audioFileURL = audioFileURL {
            note.audioPath = audioFileURL.lastPathComponent
        }
        
        do {
            try context.save()
            showSuccessAlert("Note saved successfully!")
            resetRecording()
        } catch {
            showErrorAlert("Failed to save note: \(error.localizedDescription)")
        }
    }
    
    /// Cancel recording and reset
    func cancelRecording() {
        if recordingState == .recording {
            audioRecorder?.stop()
            recordingTimer?.invalidate()
            recordingTimer = nil
        }
        
        // Delete audio file if it exists
        if let audioFileURL = audioFileURL {
            try? FileManager.default.removeItem(at: audioFileURL)
        }
        
        resetRecording()
    }
    
    // MARK: - Private Methods
    
    private func loadDefaults() {
        let userDefaults = UserDefaults.standard
        enableAISummary = userDefaults.bool(forKey: "enable_ai_by_default")
        enableDryRun = userDefaults.bool(forKey: "enable_dry_run_by_default")
    }
    
    private func beginRecording() {
        do {
            // Configure audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // Create audio file URL
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = UUID().uuidString + ".m4a"
            audioFileURL = documentsPath.appendingPathComponent(audioFilename)
            
            // Configure recording settings
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // Create and start recorder
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            // Update state
            recordingState = .recording
            recordingTime = 0
            
            // Start timer
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    self.recordingTime = self.audioRecorder?.currentTime ?? 0
                }
            }
            
        } catch {
            showErrorAlert("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    private func resetRecording() {
        recordingState = .idle
        recordingTime = 0
        rawText = ""
        audioFileURL = nil
        audioRecorder = nil
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

// MARK: - AVAudioRecorderDelegate

extension RecorderViewModel: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if !flag {
                showErrorAlert("Recording failed")
                resetRecording()
            }
        }
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in
            showErrorAlert("Recording error: \(error?.localizedDescription ?? "Unknown error")")
            resetRecording()
        }
    }
}
