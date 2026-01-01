//
//  SharedTypes.swift
//  GemNote
//
//  Shared types and enums used across the app
//

import Foundation

/// Recording state for the audio recorder
enum RecordingState {
    case idle
    case recording
    case paused
    case stopped
}

/// Playback state for audio player
enum PlaybackState {
    case idle
    case playing
    case paused
    case stopped
}

/// AI processing status
enum AIProcessingStatus {
    case idle
    case processing
    case completed
    case failed(Error)
}

/// Error types for the app
enum GemNoteError: LocalizedError {
    case audioRecordingFailed
    case audioPlaybackFailed
    case aiRequestFailed(String)
    case noAPIKey
    case invalidAPIKey
    case networkError
    case dataNotFound
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .audioRecordingFailed:
            return "Failed to record audio"
        case .audioPlaybackFailed:
            return "Failed to play audio"
        case .aiRequestFailed(let message):
            return "AI request failed: \(message)"
        case .noAPIKey:
            return "No API key configured. Please add your Gemini API key in Settings."
        case .invalidAPIKey:
            return "Invalid API key"
        case .networkError:
            return "Network error occurred"
        case .dataNotFound:
            return "Data not found"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
