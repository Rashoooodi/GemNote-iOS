//
//  RecorderView.swift
//  GemNote
//
//  Audio recording interface.
//

import SwiftUI

/// View for recording audio notes
struct RecorderView: View {
    @StateObject private var viewModel: RecorderViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: RecorderViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: GemNoteTheme.Spacing.lg) {
                    // Recording Status
                    recordingStatusView
                    
                    // Recording Controls
                    recordingControlsView
                    
                    // Note Text Input
                    noteTextSection
                    
                    // AI Options
                    aiOptionsSection
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding()
            }
            .navigationTitle("Record Note")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.cancelRecording()
                        dismiss()
                    }
                }
            }
            .alert("Recorder", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {
                    if viewModel.alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    private var recordingStatusView: some View {
        VStack(spacing: GemNoteTheme.Spacing.md) {
            // Waveform icon
            Image(systemName: viewModel.recordingState == .recording ? "waveform" : "waveform.slash")
                .font(.system(size: 60))
                .foregroundColor(viewModel.recordingState == .recording ? .red : .gray)
                .symbolEffect(.pulse, isActive: viewModel.recordingState == .recording)
            
            // Timer
            Text(formatTime(viewModel.recordingTime))
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundColor(viewModel.recordingState == .recording ? .red : .primary)
            
            // Status text
            Text(statusText)
                .font(GemNoteTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(GemNoteTheme.Colors.secondaryBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.lg)
    }
    
    private var recordingControlsView: some View {
        HStack(spacing: GemNoteTheme.Spacing.lg) {
            if viewModel.recordingState == .idle {
                Button(action: viewModel.startRecording) {
                    Label("Start Recording", systemImage: "record.circle.fill")
                        .font(GemNoteTheme.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(GemNoteTheme.CornerRadius.md)
                }
            } else if viewModel.recordingState == .recording {
                Button(action: viewModel.stopRecording) {
                    Label("Stop", systemImage: "stop.circle.fill")
                        .font(GemNoteTheme.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(GemNoteTheme.CornerRadius.md)
                }
            }
        }
    }
    
    private var noteTextSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            Label("Note Text", systemImage: "text.alignleft")
                .font(GemNoteTheme.Typography.headline)
            
            TextEditor(text: $viewModel.rawText)
                .frame(minHeight: 120)
                .padding(8)
                .background(GemNoteTheme.Colors.tertiaryBackground)
                .cornerRadius(GemNoteTheme.CornerRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: GemNoteTheme.CornerRadius.sm)
                        .stroke(GemNoteTheme.Colors.secondary.opacity(0.3), lineWidth: 1)
                )
            
            Text("Add text description or transcription")
                .font(GemNoteTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var aiOptionsSection: some View {
        VStack(spacing: GemNoteTheme.Spacing.sm) {
            ToggleRowView(
                icon: "wand.and.stars",
                title: "Enable AI Summary",
                subtitle: "Generate summary after saving",
                isOn: $viewModel.enableAISummary
            )
            
            ToggleRowView(
                icon: "tag",
                title: "Enable Tag Suggestions",
                subtitle: "Get AI-suggested tags",
                isOn: $viewModel.enableTagSuggestion
            )
            
            ToggleRowView(
                icon: "testtube.2",
                title: "Dry Run Mode",
                subtitle: "Simulate AI without API calls",
                isOn: $viewModel.enableDryRun
            )
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: GemNoteTheme.Spacing.sm) {
            PrimaryButton("Save Note", icon: "checkmark.circle") {
                viewModel.saveNote()
            }
            .disabled(viewModel.recordingState != .finished || viewModel.rawText.isEmpty)
            
            if viewModel.recordingState == .finished {
                SecondaryButton("Record Again", icon: "arrow.counterclockwise") {
                    viewModel.cancelRecording()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var statusText: String {
        switch viewModel.recordingState {
        case .idle:
            return "Ready to record"
        case .recording:
            return "Recording..."
        case .paused:
            return "Paused"
        case .finished:
            return "Recording complete"
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
    }
}

#Preview {
    RecorderView(context: PersistenceController.preview.container.viewContext)
}
