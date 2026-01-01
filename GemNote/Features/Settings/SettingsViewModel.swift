//
//  SettingsViewModel.swift
//  GemNote
//
//  View model for settings management.
//

import Foundation
import Combine

/// Manages settings and preferences
@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var apiKey: String = ""
    @Published var selectedModel: GeminiModel = .gemini15Flash
    @Published var enableAIByDefault: Bool = false
    @Published var enableDryRunByDefault: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // MARK: - Private Properties
    
    private let keychainManager = KeychainManager.shared
    private let userDefaults = UserDefaults.standard
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let selectedModel = "selected_gemini_model"
        static let enableAIByDefault = "enable_ai_by_default"
        static let enableDryRunByDefault = "enable_dry_run_by_default"
    }
    
    // MARK: - Initialization
    
    init() {
        loadSettings()
    }
    
    // MARK: - Public Methods
    
    /// Load settings from storage
    func loadSettings() {
        // Load API key from Keychain
        apiKey = (try? keychainManager.retrieve(forKey: KeychainManager.Keys.geminiAPIKey)) ?? ""
        
        // Load preferences from UserDefaults
        if let modelRaw = userDefaults.string(forKey: Keys.selectedModel),
           let model = GeminiModel(rawValue: modelRaw) {
            selectedModel = model
        }
        
        enableAIByDefault = userDefaults.bool(forKey: Keys.enableAIByDefault)
        enableDryRunByDefault = userDefaults.bool(forKey: Keys.enableDryRunByDefault)
    }
    
    /// Save API key to Keychain
    func saveAPIKey() {
        do {
            if apiKey.isEmpty {
                try keychainManager.delete(forKey: KeychainManager.Keys.geminiAPIKey)
                showSuccessAlert("API key cleared")
            } else {
                try keychainManager.save(apiKey, forKey: KeychainManager.Keys.geminiAPIKey)
                showSuccessAlert("API key saved securely")
            }
        } catch {
            showErrorAlert("Failed to save API key: \(error.localizedDescription)")
        }
    }
    
    /// Save model preference
    func saveModelPreference() {
        userDefaults.set(selectedModel.rawValue, forKey: Keys.selectedModel)
        showSuccessAlert("Model preference saved")
    }
    
    /// Save AI default preference
    func saveAIDefaultPreference() {
        userDefaults.set(enableAIByDefault, forKey: Keys.enableAIByDefault)
    }
    
    /// Save dry run default preference
    func saveDryRunDefaultPreference() {
        userDefaults.set(enableDryRunByDefault, forKey: Keys.enableDryRunByDefault)
    }
    
    /// Clear all AI summaries from Core Data
    func clearAllAISummaries() {
        do {
            try PersistenceController.shared.clearAllAISummaries()
            showSuccessAlert("All AI summaries cleared")
        } catch {
            showErrorAlert("Failed to clear summaries: \(error.localizedDescription)")
        }
    }
    
    /// Test API connection
    func testAPIConnection() async {
        guard !apiKey.isEmpty else {
            showErrorAlert("Please enter an API key first")
            return
        }
        
        do {
            let testPrompt = "Say 'Hello' in one word."
            let response = try await GeminiClient.shared.generate(
                prompt: testPrompt,
                model: selectedModel,
                isDryRun: false
            )
            showSuccessAlert("API connection successful!\nResponse: \(response)")
        } catch {
            showErrorAlert("API test failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    private func showSuccessAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func showErrorAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
