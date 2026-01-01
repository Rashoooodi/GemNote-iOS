//
//  SettingsView.swift
//  GemNote
//
//  Settings and configuration screen
//

import SwiftUI
import CoreData

/// Settings view for app configuration
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SettingsViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(context: context))
    }
    
    var body: some View {
        List {
            // API Configuration
            Section {
                apiKeySection
            } header: {
                Text("Gemini API")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.apiKeyStatusMessage)
                    Text("Get your API key from Google AI Studio")
                        .font(.caption2)
                }
            }
            
            // Model Selection
            Section {
                modelSelectionSection
            } header: {
                Text("AI Model")
            } footer: {
                Text("Choose which Gemini model to use for AI operations")
            }
            
            // Default Options
            Section {
                defaultOptionsSection
            } header: {
                Text("Default Options")
            } footer: {
                Text("These settings will be used as defaults for new notes")
            }
            
            // Data Management
            Section {
                dataManagementSection
            } header: {
                Text("Data Management")
            } footer: {
                Text("Clear AI-generated summaries from all notes. Note content will not be affected.")
            }
            
            // App Information
            Section {
                appInfoSection
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    viewModel.saveSettings()
                    dismiss()
                }
            }
        }
        .alert("Clear AI Summaries?", isPresented: $viewModel.showingClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                viewModel.clearAllAISummaries()
            }
        } message: {
            Text("This will remove all AI-generated summaries from your notes. This action cannot be undone.")
        }
        .alert("Success", isPresented: $viewModel.showingSuccessMessage) {
            Button("OK") {}
        } message: {
            Text("Settings saved successfully")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - View Components
    
    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            SecureField("API Key", text: $viewModel.apiKey)
                .textContentType(.password)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            
            // Status indicator
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                Text(viewModel.apiKeyStatusMessage)
                    .font(GemNoteTheme.Typography.caption)
                    .foregroundColor(statusColor)
            }
        }
    }
    
    private var modelSelectionSection: some View {
        Picker("Model", selection: $viewModel.selectedModel) {
            ForEach(GeminiModel.allCases) { model in
                VStack(alignment: .leading) {
                    Text(model.displayName)
                        .font(GemNoteTheme.Typography.body)
                }
                .tag(model)
            }
        }
        .pickerStyle(.inline)
    }
    
    private var defaultOptionsSection: some View {
        Group {
            Toggle(isOn: $viewModel.enableAIByDefault) {
                VStack(alignment: .leading) {
                    Text("Enable AI by Default")
                        .font(GemNoteTheme.Typography.body)
                    Text("Automatically enable AI features for new notes")
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(GemNoteTheme.Colors.secondaryText)
                }
            }
            
            Toggle(isOn: $viewModel.enableDryRunByDefault) {
                VStack(alignment: .leading) {
                    Text("Enable Dry Run by Default")
                        .font(GemNoteTheme.Typography.body)
                    Text("Simulate AI operations without making API calls")
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(GemNoteTheme.Colors.secondaryText)
                }
            }
        }
    }
    
    private var dataManagementSection: some View {
        Button(role: .destructive) {
            viewModel.showingClearAlert = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Clear All AI Summaries")
            }
        }
    }
    
    private var appInfoSection: some View {
        Group {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(GemNoteTheme.Colors.secondaryText)
            }
            
            HStack {
                Text("Platform")
                Spacer()
                Text("iOS 18.0+")
                    .foregroundColor(GemNoteTheme.Colors.secondaryText)
            }
            
            Link(destination: URL(string: "https://ai.google.dev/")!) {
                HStack {
                    Text("Get Gemini API Key")
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.caption)
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var statusIcon: String {
        switch viewModel.apiKeyStatusColor {
        case "success":
            return "checkmark.circle.fill"
        case "warning":
            return "exclamationmark.triangle.fill"
        case "error":
            return "xmark.circle.fill"
        default:
            return "info.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.apiKeyStatusColor {
        case "success":
            return GemNoteTheme.Colors.success
        case "warning":
            return GemNoteTheme.Colors.warning
        case "error":
            return GemNoteTheme.Colors.error
        default:
            return GemNoteTheme.Colors.secondary
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(context: PersistenceController.preview.viewContext)
    }
}
