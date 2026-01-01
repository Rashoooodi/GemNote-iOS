//
//  GeminiModels.swift
//  GemNote
//
//  Models for Gemini AI integration
//

import Foundation

/// Available Gemini models
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
    
    var apiEndpoint: String {
        switch self {
        case .geminiPro:
            return "gemini-pro"
        case .gemini15Flash:
            return "gemini-1.5-flash"
        }
    }
}

// MARK: - API Request/Response Models

struct GeminiRequest: Encodable {
    let contents: [Content]
    
    struct Content: Encodable {
        let parts: [Part]
        
        struct Part: Encodable {
            let text: String
        }
    }
}

struct GeminiResponse: Decodable {
    let candidates: [Candidate]?
    let error: ErrorResponse?
    
    struct Candidate: Decodable {
        let content: Content
        
        struct Content: Decodable {
            let parts: [Part]
            
            struct Part: Decodable {
                let text: String
            }
        }
    }
    
    struct ErrorResponse: Decodable {
        let code: Int
        let message: String
        let status: String
    }
    
    var text: String? {
        candidates?.first?.content.parts.first?.text
    }
}

// MARK: - Settings Storage

extension UserDefaults {
    private enum Keys {
        static let selectedModel = "selected_gemini_model"
        static let enableAIByDefault = "enable_ai_by_default"
        static let enableDryRunByDefault = "enable_dry_run_by_default"
    }
    
    var selectedGeminiModel: GeminiModel {
        get {
            guard let rawValue = string(forKey: Keys.selectedModel),
                  let model = GeminiModel(rawValue: rawValue) else {
                return .gemini15Flash
            }
            return model
        }
        set {
            set(newValue.rawValue, forKey: Keys.selectedModel)
        }
    }
    
    var enableAIByDefault: Bool {
        get {
            if object(forKey: Keys.enableAIByDefault) == nil {
                return false
            }
            return bool(forKey: Keys.enableAIByDefault)
        }
        set {
            set(newValue, forKey: Keys.enableAIByDefault)
        }
    }
    
    var enableDryRunByDefault: Bool {
        get {
            if object(forKey: Keys.enableDryRunByDefault) == nil {
                return false
            }
            return bool(forKey: Keys.enableDryRunByDefault)
        }
        set {
            set(newValue, forKey: Keys.enableDryRunByDefault)
        }
    }
}
