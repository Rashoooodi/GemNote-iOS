//
//  RecorderView.swift
//  GemNote
//
//  Audio recording interface
//

import SwiftUI
import CoreData

/// View for recording audio notes
struct RecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RecorderViewModel
    @State private var noteText = ""
    @State private var showingSaveAlert = false
    @State private var savedNote: Note?
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: RecorderViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: GemNoteTheme.Spacing.xl) {
                // Recording indicator
                recordingIndicator
                
                // Timer
                timerDisplay
                
                // Recording controls
                recordingControls
                
                Spacer()
                
                // Options
                optionsSection
                
                // Save button
                if viewModel.canSave {
                    saveSection
                }
            }
            .padding(GemNoteTheme.Spacing.lg)
            .navigationTitle("Record Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if viewModel.recordingState == .recording {
                            viewModel.cancelRecording()
                        }
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Note Saved", isPresented: $showingSaveAlert) {
                Button("View Note") {
                    savedNote = savedNote
                    dismiss()
                }
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your audio note has been saved successfully.")
            }
        }
    }
    
    // MARK: - View Components
    
    private var recordingIndicator: some View {
        ZStack {
            Circle()
                .fill(viewModel.recordingState == .recording ?
                      GemNoteTheme.Colors.error.opacity(0.2) :
                      GemNoteTheme.Colors.secondary.opacity(0.2))
                .frame(width: 200, height: 200)
                .scaleEffect(viewModel.recordingState == .recording ? 1.1 : 1.0)
                .animation(
                    viewModel.recordingState == .recording ?
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                        .default,
                    value: viewModel.recordingState
                )
            
            Image(systemName: "waveform")
                .font(.system(size: 72))
                .foregroundColor(
                    viewModel.recordingState == .recording ?
                    GemNoteTheme.Colors.error :
                    GemNoteTheme.Colors.secondary
                )
        }
    }
    
    private var timerDisplay: some View {
        Text(viewModel.formattedDuration)
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundColor(GemNoteTheme.Colors.text)
            .monospacedDigit()
    }
    
    private var recordingControls: some View {
        HStack(spacing: GemNoteTheme.Spacing.xl) {
            if viewModel.recordingState == .recording {
                Button {
                    viewModel.stopRecording()
                } label: {
                    VStack(spacing: GemNoteTheme.Spacing.sm) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(GemNoteTheme.Colors.error)
                        Text("Stop")
                            .font(GemNoteTheme.Typography.caption)
                    }
                }
            } else if viewModel.recordingState == .idle {
                Button {
                    Task {
                        await viewModel.startRecording()
                    }
                } label: {
                    VStack(spacing: GemNoteTheme.Spacing.sm) {
                        Image(systemName: "record.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(GemNoteTheme.Colors.error)
                        Text("Record")
                            .font(GemNoteTheme.Typography.caption)
                    }
                }
            }
        }
    }
    
    private var optionsSection: some View {
        VStack(spacing: GemNoteTheme.Spacing.sm) {
            Text("AI Options")
                .font(GemNoteTheme.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ToggleRowView(
                icon: "wand.and.stars",
                title: "Enable AI Summary",
                subtitle: "Generate summary after saving",
                isOn: $viewModel.enableAISummary
            )
            
            ToggleRowView(
                icon: "tag",
                title: "Enable Tag Suggestions",
                subtitle: "Suggest tags automatically",
                isOn: $viewModel.enableTagSuggestion
            )
            
            ToggleRowView(
                icon: "hammer",
                title: "Dry Run Mode",
                subtitle: "Simulate AI without API calls",
                iconColor: GemNoteTheme.Colors.warning,
                isOn: $viewModel.enableDryRun
            )
        }
    }
    
    private var saveSection: some View {
        VStack(spacing: GemNoteTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.xs) {
                Text("Add Note Text (Optional)")
                    .font(GemNoteTheme.Typography.caption)
                    .foregroundColor(GemNoteTheme.Colors.secondaryText)
                
                TextEditor(text: $noteText)
                    .font(GemNoteTheme.Typography.body)
                    .frame(height: 100)
                    .padding(GemNoteTheme.Spacing.sm)
                    .background(GemNoteTheme.Colors.cardBackground)
                    .cornerRadius(GemNoteTheme.CornerRadius.sm)
            }
            
            PrimaryButton("Save Recording", icon: "checkmark.circle.fill") {
                do {
                    let note = try viewModel.saveNote(text: noteText)
                    savedNote = note
                    showingSaveAlert = true
                } catch {
                    viewModel.errorMessage = "Failed to save note: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    RecorderView(context: PersistenceController.preview.viewContext)
}
