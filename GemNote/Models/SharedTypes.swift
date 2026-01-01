//
//  SharedTypes.swift
//  GemNote
//
//  Shared types and enums used across the app.
//

import Foundation

/// Represents the available Gemini AI models
enum GeminiModel: String, CaseIterable, Identifiable {
    case geminiPro = "gemini-pro"
    case gemini15Flash = "gemini-1.5-flash"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .geminiPro:
            return "Gemini Pro"
        case .gemini15Flash:
            return "Gemini 1.5 Flash"
        }
    }
}

/// Result type for AI operations
enum AIResult {
    case success(String)
    case failure(Error)
    case dryRun(String)
}

/// Common errors in the app
enum GemNoteError: LocalizedError {
    case noAPIKey
    case networkError(Error)
    case invalidResponse
    case audioRecordingFailed
    case audioPlaybackFailed
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "Gemini API key not configured. Please add it in Settings."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from AI service."
        case .audioRecordingFailed:
            return "Failed to record audio."
        case .audioPlaybackFailed:
            return "Failed to play audio."
        }
    }
}

/// Audio recording state
enum RecordingState {
    case idle
    case recording
    case paused
    case finished
}
