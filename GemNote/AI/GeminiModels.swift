//
//  GeminiModels.swift
//  GemNote
//
//  Data models for Gemini API requests and responses.
//

import Foundation

// MARK: - Request Models

struct GeminiRequest: Codable {
    let contents: [Content]
    let generationConfig: GenerationConfig?
    
    struct Content: Codable {
        let parts: [Part]
        
        struct Part: Codable {
            let text: String
        }
    }
    
    struct GenerationConfig: Codable {
        let temperature: Double?
        let maxOutputTokens: Int?
        let topP: Double?
        let topK: Int?
    }
}

// MARK: - Response Models

struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    let error: GeminiErrorResponse?
    
    struct Candidate: Codable {
        let content: Content
        let finishReason: String?
        
        struct Content: Codable {
            let parts: [Part]
            
            struct Part: Codable {
                let text: String
            }
        }
    }
}

struct GeminiErrorResponse: Codable {
    let code: Int
    let message: String
    let status: String
}

// MARK: - Helper Extensions

extension GeminiRequest {
    /// Create a request from plain text
    static func from(text: String, config: GenerationConfig? = nil) -> GeminiRequest {
        let part = Content.Part(text: text)
        let content = Content(parts: [part])
        return GeminiRequest(contents: [content], generationConfig: config)
    }
}

extension GeminiResponse {
    /// Extract the text from the first candidate
    var text: String? {
        candidates?.first?.content.parts.first?.text
    }
}
