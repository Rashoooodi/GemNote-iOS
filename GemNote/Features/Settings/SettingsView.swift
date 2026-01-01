//
//  SettingsView.swift
//  GemNote
//
//  Settings screen for API key and preferences.
//

import SwiftUI

/// Settings view for configuring the app
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // API Key Section
                Section {
                    SecureField("Enter Gemini API Key", text: $viewModel.apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Button("Save API Key") {
                        viewModel.saveAPIKey()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button("Test Connection") {
                        Task {
                            await viewModel.testAPIConnection()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.apiKey.isEmpty)
                    
                } header: {
                    Label("Gemini API Key", systemImage: "key.fill")
                } footer: {
                    Text("Get your free API key from Google AI Studio. Stored securely in Keychain.")
                        .font(.caption)
                }
                
                // Model Selection Section
                Section {
                    Picker("AI Model", selection: $viewModel.selectedModel) {
                        ForEach(GeminiModel.allCases) { model in
                            Text(model.displayName)
                                .tag(model)
                        }
                    }
                    .onChange(of: viewModel.selectedModel) { _, _ in
                        viewModel.saveModelPreference()
                    }
                } header: {
                    Label("AI Model", systemImage: "cpu")
                } footer: {
                    Text("Choose which Gemini model to use for AI operations.")
                        .font(.caption)
                }
                
                // Default Behaviors Section
                Section {
                    Toggle(isOn: $viewModel.enableAIByDefault) {
                        VStack(alignment: .leading) {
                            Text("Enable AI by Default")
                            Text("New notes will have AI enabled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: viewModel.enableAIByDefault) { _, _ in
                        viewModel.saveAIDefaultPreference()
                    }
                    
                    Toggle(isOn: $viewModel.enableDryRunByDefault) {
                        VStack(alignment: .leading) {
                            Text("Dry Run Mode by Default")
                            Text("Simulate AI without making API calls")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: viewModel.enableDryRunByDefault) { _, _ in
                        viewModel.saveDryRunDefaultPreference()
                    }
                } header: {
                    Label("Default Behaviors", systemImage: "gearshape.fill")
                }
                
                // Data Management Section
                Section {
                    Button(role: .destructive) {
                        viewModel.clearAllAISummaries()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear All AI Summaries")
                        }
                    }
                } header: {
                    Label("Data Management", systemImage: "folder")
                } footer: {
                    Text("This will remove all AI-generated summaries but keep your notes intact.")
                        .font(.caption)
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Settings", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    SettingsView()
}
