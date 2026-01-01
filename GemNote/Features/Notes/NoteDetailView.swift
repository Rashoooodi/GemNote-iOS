//
//  NoteDetailView.swift
//  GemNote
//
//  Detailed view for a single note
//

import SwiftUI
import CoreData

/// Detail view for viewing and editing a note
struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NoteDetailViewModel
    @State private var isEditingText = false
    @State private var editedText = ""
    @State private var showingDeleteAlert = false
    @State private var showingRunAISheet = false
    
    init(note: Note, context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: NoteDetailViewModel(note: note, context: context))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.lg) {
                // Metadata
                metadataSection
                
                // Raw text section
                rawTextSection
                
                // AI Summary section
                if viewModel.note.aiSummary != nil {
                    aiSummarySection
                }
                
                // Tags section
                tagsSection
                
                // Audio section
                if viewModel.note.audioPath != nil {
                    audioSection
                }
                
                // Actions
                actionsSection
            }
            .padding(GemNoteTheme.Spacing.md)
        }
        .background(GemNoteTheme.Colors.background)
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingRunAISheet = true
                    } label: {
                        Label("Run AI Processing", systemImage: "wand.and.stars")
                    }
                    
                    if viewModel.note.aiSummary != nil {
                        Button(role: .destructive) {
                            viewModel.clearAISummary()
                        } label: {
                            Label("Clear AI Summary", systemImage: "trash")
                        }
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Note", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingRunAISheet) {
            runAISheet
        }
        .alert("Delete Note?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                do {
                    try viewModel.deleteNote()
                    dismiss()
                } catch {
                    viewModel.errorMessage = "Failed to delete note: \(error.localizedDescription)"
                }
            }
        } message: {
            Text("This action cannot be undone.")
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
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.xs) {
            HStack {
                Label(
                    viewModel.note.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "",
                    systemImage: "calendar"
                )
                .font(GemNoteTheme.Typography.caption)
                .foregroundColor(GemNoteTheme.Colors.secondaryText)
                
                Spacer()
                
                if let model = viewModel.note.aiModel {
                    Text(GeminiModel(rawValue: model)?.displayName ?? model)
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(GemNoteTheme.Colors.secondaryText)
                }
            }
        }
    }
    
    private var rawTextSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            HStack {
                Text("Note")
                    .font(GemNoteTheme.Typography.headline)
                Spacer()
                Button(isEditingText ? "Done" : "Edit") {
                    if isEditingText {
                        viewModel.updateNoteText(editedText)
                    } else {
                        editedText = viewModel.note.rawText ?? ""
                    }
                    isEditingText.toggle()
                }
                .font(GemNoteTheme.Typography.callout)
            }
            
            if isEditingText {
                TextEditor(text: $editedText)
                    .font(GemNoteTheme.Typography.body)
                    .frame(minHeight: 150)
                    .padding(GemNoteTheme.Spacing.sm)
                    .background(GemNoteTheme.Colors.cardBackground)
                    .cornerRadius(GemNoteTheme.CornerRadius.sm)
            } else {
                Text(viewModel.note.rawText ?? "")
                    .font(GemNoteTheme.Typography.body)
                    .foregroundColor(GemNoteTheme.Colors.text)
                    .padding(GemNoteTheme.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(GemNoteTheme.Colors.cardBackground)
                    .cornerRadius(GemNoteTheme.CornerRadius.md)
            }
        }
    }
    
    private var aiSummarySection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            HStack {
                Label("AI Summary", systemImage: "sparkles")
                    .font(GemNoteTheme.Typography.headline)
                Spacer()
            }
            
            Text(viewModel.note.aiSummary ?? "")
                .font(GemNoteTheme.Typography.body)
                .foregroundColor(GemNoteTheme.Colors.text)
                .padding(GemNoteTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(GemNoteTheme.Colors.primary.opacity(0.1))
                .cornerRadius(GemNoteTheme.CornerRadius.md)
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            Text("Tags")
                .font(GemNoteTheme.Typography.headline)
            
            // Existing tags
            if !viewModel.tags.isEmpty {
                FlowLayout(spacing: GemNoteTheme.Spacing.sm) {
                    ForEach(viewModel.tags, id: \.id) { tag in
                        TagChip(
                            text: tag.name ?? "",
                            onDelete: {
                                viewModel.removeTag(tag)
                            }
                        )
                    }
                }
            }
            
            // Add tag field
            HStack {
                TextField("Add tag", text: $viewModel.tagInputText)
                    .font(GemNoteTheme.Typography.body)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        viewModel.addTag(name: viewModel.tagInputText)
                        viewModel.tagInputText = ""
                    }
                
                Button {
                    viewModel.addTag(name: viewModel.tagInputText)
                    viewModel.tagInputText = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .disabled(viewModel.tagInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private var audioSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            Label("Audio Recording", systemImage: "waveform")
                .font(GemNoteTheme.Typography.headline)
            
            VStack(spacing: GemNoteTheme.Spacing.md) {
                Text(viewModel.formattedPlaybackTime)
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(GemNoteTheme.Colors.text)
                
                HStack(spacing: GemNoteTheme.Spacing.lg) {
                    if viewModel.playbackState == .playing {
                        Button {
                            viewModel.pauseAudio()
                        } label: {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(GemNoteTheme.Colors.primary)
                        }
                    } else {
                        Button {
                            viewModel.playAudio()
                        } label: {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(GemNoteTheme.Colors.primary)
                        }
                    }
                    
                    if viewModel.playbackState != .idle {
                        Button {
                            viewModel.stopAudio()
                        } label: {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(GemNoteTheme.Colors.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(GemNoteTheme.Spacing.lg)
            .background(GemNoteTheme.Colors.cardBackground)
            .cornerRadius(GemNoteTheme.CornerRadius.md)
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: GemNoteTheme.Spacing.sm) {
            if viewModel.note.isAISummaryEnabled || viewModel.note.isTagSuggestionEnabled {
                PrimaryButton("Run AI Processing", icon: "wand.and.stars") {
                    showingRunAISheet = true
                }
            }
        }
    }
    
    private var runAISheet: some View {
        NavigationStack {
            VStack(spacing: GemNoteTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
                    Text("AI Processing Options")
                        .font(GemNoteTheme.Typography.headline)
                    
                    Text("Choose whether to use the real API or run in dry-run mode (simulation).")
                        .font(GemNoteTheme.Typography.body)
                        .foregroundColor(GemNoteTheme.Colors.secondaryText)
                }
                
                // Model selection
                VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.xs) {
                    Text("Model")
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(GemNoteTheme.Colors.secondaryText)
                    
                    Picker("Model", selection: Binding(
                        get: { UserDefaults.standard.selectedGeminiModel },
                        set: { UserDefaults.standard.selectedGeminiModel = $0 }
                    )) {
                        ForEach(GeminiModel.allCases) { model in
                            Text(model.displayName).tag(model)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: GemNoteTheme.Spacing.sm) {
                    if case .processing = viewModel.aiProcessingStatus {
                        ProgressView("Processing...")
                            .padding()
                    } else {
                        PrimaryButton("Run with API", icon: "sparkles") {
                            Task {
                                await viewModel.runAIProcessing(isDryRun: false)
                                if case .completed = viewModel.aiProcessingStatus {
                                    showingRunAISheet = false
                                }
                            }
                        }
                        
                        PrimaryButton("Run Dry-Run Mode", icon: "hammer") {
                            Task {
                                await viewModel.runAIProcessing(isDryRun: true)
                                if case .completed = viewModel.aiProcessingStatus {
                                    showingRunAISheet = false
                                }
                            }
                        }
                    }
                }
            }
            .padding(GemNoteTheme.Spacing.lg)
            .navigationTitle("Run AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingRunAISheet = false
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

/// Tag chip with delete button
struct TagChip: View {
    let text: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(GemNoteTheme.Typography.caption)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, GemNoteTheme.Spacing.sm)
        .padding(.vertical, GemNoteTheme.Spacing.xs)
        .background(GemNoteTheme.Colors.primary.opacity(0.1))
        .foregroundColor(GemNoteTheme.Colors.primary)
        .cornerRadius(GemNoteTheme.CornerRadius.sm)
    }
}

/// Flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        NoteDetailView(
            note: PersistenceController.preview.viewContext.registeredObjects
                .compactMap { $0 as? Note }
                .first!,
            context: PersistenceController.preview.viewContext
        )
    }
}
