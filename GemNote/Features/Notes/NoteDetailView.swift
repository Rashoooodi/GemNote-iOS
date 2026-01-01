//
//  NoteDetailView.swift
//  GemNote
//
//  Detailed view of a single note with AI controls.
//

import SwiftUI

/// Displays full note details with edit and AI capabilities
struct NoteDetailView: View {
    @StateObject private var viewModel: NoteDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var editedText: String
    @State private var isEditingText = false
    
    init(note: Note, context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: NoteDetailViewModel(note: note, context: context))
        _editedText = State(initialValue: note.rawText ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: GemNoteTheme.Spacing.lg) {
                // Metadata Section
                metadataSection
                
                // Audio Section
                if viewModel.note.audioPath != nil {
                    audioSection
                }
                
                // Raw Text Section
                rawTextSection
                
                // AI Summary Section
                if viewModel.note.aiSummary != nil {
                    aiSummarySection
                }
                
                // Tags Section
                tagsSection
                
                // AI Controls
                aiControlsSection
                
                // Delete Button
                deleteSection
            }
            .padding()
        }
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Note Detail", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .confirmationDialog("Delete Note", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteNote()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }
    
    // MARK: - View Components
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Created")
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.note.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .font(GemNoteTheme.Typography.body)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Updated")
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.note.updatedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .font(GemNoteTheme.Typography.body)
                }
            }
            
            if let model = viewModel.note.aiModel {
                HStack {
                    Image(systemName: "cpu")
                        .foregroundColor(.secondary)
                    Text("Processed with \(GeminiModel(rawValue: model)?.displayName ?? model)")
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(GemNoteTheme.Colors.secondaryBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
    }
    
    private var audioSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            Label("Audio Recording", systemImage: "waveform")
                .font(GemNoteTheme.Typography.headline)
            
            HStack {
                if viewModel.isPlayingAudio {
                    Button(action: viewModel.stopAudio) {
                        Label("Stop", systemImage: "stop.circle.fill")
                            .font(GemNoteTheme.Typography.body)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.red)
                            .foregroundColor(.white)
                            .cornerRadius(GemNoteTheme.CornerRadius.md)
                    }
                } else {
                    Button(action: viewModel.playAudio) {
                        Label("Play", systemImage: "play.circle.fill")
                            .font(GemNoteTheme.Typography.body)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(GemNoteTheme.Colors.accent)
                            .foregroundColor(.white)
                            .cornerRadius(GemNoteTheme.CornerRadius.md)
                    }
                }
            }
        }
        .padding()
        .background(GemNoteTheme.Colors.secondaryBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
    }
    
    private var rawTextSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            HStack {
                Label("Note Content", systemImage: "text.alignleft")
                    .font(GemNoteTheme.Typography.headline)
                
                Spacer()
                
                Button(isEditingText ? "Done" : "Edit") {
                    if isEditingText {
                        viewModel.updateNoteText(editedText)
                    }
                    isEditingText.toggle()
                }
                .font(GemNoteTheme.Typography.body)
            }
            
            if isEditingText {
                TextEditor(text: $editedText)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(GemNoteTheme.Colors.tertiaryBackground)
                    .cornerRadius(GemNoteTheme.CornerRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: GemNoteTheme.CornerRadius.sm)
                            .stroke(GemNoteTheme.Colors.primary, lineWidth: 1)
                    )
            } else {
                Text(viewModel.note.rawText ?? "")
                    .font(GemNoteTheme.Typography.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(GemNoteTheme.Colors.tertiaryBackground)
                    .cornerRadius(GemNoteTheme.CornerRadius.sm)
            }
        }
        .padding()
        .background(GemNoteTheme.Colors.secondaryBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
    }
    
    private var aiSummarySection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            Label("AI Summary", systemImage: "sparkles")
                .font(GemNoteTheme.Typography.headline)
            
            Text(viewModel.note.aiSummary ?? "")
                .font(GemNoteTheme.Typography.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(GemNoteTheme.Colors.tertiaryBackground)
                .cornerRadius(GemNoteTheme.CornerRadius.sm)
        }
        .padding()
        .background(GemNoteTheme.Colors.secondaryBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            Label("Tags", systemImage: "tag")
                .font(GemNoteTheme.Typography.headline)
            
            // Existing tags
            if let tags = viewModel.note.tags as? Set<Tag>, !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(Array(tags).sorted(by: { ($0.name ?? "") < ($1.name ?? "") }), id: \.id) { tag in
                        HStack(spacing: 4) {
                            Text(tag.name ?? "")
                                .font(GemNoteTheme.Typography.caption)
                            
                            Button(action: { viewModel.removeTag(tag) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(GemNoteTheme.Colors.primary.opacity(0.1))
                        .foregroundColor(GemNoteTheme.Colors.primary)
                        .cornerRadius(GemNoteTheme.CornerRadius.sm)
                    }
                }
            }
            
            // Add new tag
            HStack {
                TextField("Add tag", text: $viewModel.newTagName)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                
                Button("Add") {
                    viewModel.addTag(viewModel.newTagName)
                }
                .disabled(viewModel.newTagName.isEmpty)
            }
        }
        .padding()
        .background(GemNoteTheme.Colors.secondaryBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
    }
    
    private var aiControlsSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            Label("AI Operations", systemImage: "cpu")
                .font(GemNoteTheme.Typography.headline)
            
            Picker("Model", selection: $viewModel.selectedModel) {
                ForEach(GeminiModel.allCases) { model in
                    Text(model.displayName).tag(model)
                }
            }
            .pickerStyle(.segmented)
            
            HStack(spacing: GemNoteTheme.Spacing.sm) {
                PrimaryButton("Run AI", icon: "wand.and.stars", isLoading: viewModel.isProcessingAI) {
                    Task {
                        await viewModel.runAI(isDryRun: false)
                    }
                }
                
                SecondaryButton("Dry Run", icon: "testtube.2") {
                    Task {
                        await viewModel.runAI(isDryRun: true)
                    }
                }
                .disabled(viewModel.isProcessingAI)
            }
        }
        .padding()
        .background(GemNoteTheme.Colors.secondaryBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
    }
    
    private var deleteSection: some View {
        DestructiveButton("Delete Note", icon: "trash") {
            showDeleteConfirmation = true
        }
    }
}

// MARK: - Flow Layout

/// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                lineWidth = size.width + spacing
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            totalWidth = max(totalWidth, lineWidth)
        }
        
        totalHeight += lineHeight
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineX + size.width > bounds.maxX && lineX > bounds.minX {
                lineY += lineHeight + spacing
                lineHeight = 0
                lineX = bounds.minX
            }
            
            subview.place(at: CGPoint(x: lineX, y: lineY), proposal: .unspecified)
            
            lineHeight = max(lineHeight, size.height)
            lineX += size.width + spacing
        }
    }
}

#Preview {
    let controller = PersistenceController.preview
    let context = controller.container.viewContext
    
    let note = Note(context: context)
    note.id = UUID()
    note.createdAt = Date()
    note.updatedAt = Date()
    note.rawText = "This is a detailed note for preview"
    note.aiSummary = "AI summary of the note"
    note.aiModel = GeminiModel.gemini15Flash.rawValue
    note.isAISummaryEnabled = true
    note.isTagSuggestionEnabled = true
    
    return NavigationStack {
        NoteDetailView(note: note, context: context)
    }
}
