//
//  SettingsViewModel.swift
//  GemNote
//
//  ViewModel for settings
//

import Foundation
import CoreData

/// ViewModel for settings screen
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var apiKey: String
    @Published var selectedModel: GeminiModel
    @Published var enableAIByDefault: Bool
    @Published var enableDryRunByDefault: Bool
    @Published var showingClearAlert = false
    @Published var showingSuccessMessage = false
    @Published var errorMessage: String?
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.apiKey = KeychainManager.shared.geminiAPIKey ?? ""
        self.selectedModel = UserDefaults.standard.selectedGeminiModel
        self.enableAIByDefault = UserDefaults.standard.enableAIByDefault
        self.enableDryRunByDefault = UserDefaults.standard.enableDryRunByDefault
    }
    
    // MARK: - Settings Management
    
    func saveSettings() {
        // Save API key to Keychain
        if apiKey.isEmpty {
            KeychainManager.shared.geminiAPIKey = nil
        } else {
            KeychainManager.shared.geminiAPIKey = apiKey
        }
        
        // Save preferences to UserDefaults
        UserDefaults.standard.selectedGeminiModel = selectedModel
        UserDefaults.standard.enableAIByDefault = enableAIByDefault
        UserDefaults.standard.enableDryRunByDefault = enableDryRunByDefault
        
        showingSuccessMessage = true
    }
    
    func clearAllAISummaries() {
        do {
            try PersistenceController.shared.clearAllAISummaries()
            showingSuccessMessage = true
        } catch {
            errorMessage = "Failed to clear AI summaries: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Validation
    
    var isAPIKeyValid: Bool {
        // Basic validation - should be at least 20 characters
        return apiKey.count >= 20 || apiKey.isEmpty
    }
    
    var apiKeyStatusMessage: String {
        if apiKey.isEmpty {
            return "No API key configured. AI features will not work."
        } else if !isAPIKeyValid {
            return "API key appears to be invalid"
        } else {
            return "API key configured"
        }
    }
    
    var apiKeyStatusColor: String {
        if apiKey.isEmpty {
            return "warning"
        } else if !isAPIKeyValid {
            return "error"
        } else {
            return "success"
        }
    }
}
