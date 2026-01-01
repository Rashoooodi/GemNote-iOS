//
//  NoteCardView.swift
//  GemNote
//
//  Card view for displaying a note in lists.
//

import SwiftUI

/// Displays a note in a card format
struct NoteCardView: View {
    let note: Note
    let onTap: () -> Void
    
    private var hasAudio: Bool {
        note.audioPath != nil
    }
    
    private var hasAISummary: Bool {
        note.aiSummary != nil
    }
    
    private var displayText: String {
        if let summary = note.aiSummary, !summary.isEmpty {
            return summary
        }
        return note.rawText ?? ""
    }
    
    private var tags: [String] {
        guard let tagSet = note.tags as? Set<Tag> else { return [] }
        return tagSet.map { $0.name ?? "" }.sorted()
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
                // Header with date and indicators
                HStack {
                    Text(note.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(GemNoteTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        if hasAudio {
                            Image(systemName: "waveform")
                                .font(.caption)
                                .foregroundColor(GemNoteTheme.Colors.accent)
                        }
                        
                        if hasAISummary {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(GemNoteTheme.Colors.primary)
                        }
                    }
                }
                
                // Note content
                Text(displayText)
                    .font(GemNoteTheme.Typography.body)
                    .foregroundColor(GemNoteTheme.Colors.textPrimary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Tags
                if !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(GemNoteTheme.Typography.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(GemNoteTheme.Colors.primary.opacity(0.1))
                                    .foregroundColor(GemNoteTheme.Colors.primary)
                                    .cornerRadius(GemNoteTheme.CornerRadius.sm)
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GemNoteTheme.Colors.secondaryBackground)
            .cornerRadius(GemNoteTheme.CornerRadius.md)
            .shadow(color: GemNoteTheme.Shadow.light, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let controller = PersistenceController.preview
    let context = controller.container.viewContext
    
    let note = Note(context: context)
    note.id = UUID()
    note.createdAt = Date()
    note.updatedAt = Date()
    note.rawText = "This is a sample note with some content that demonstrates how the card looks."
    note.aiSummary = "AI-generated summary of the note"
    note.audioPath = "sample.m4a"
    
    let tag1 = Tag(context: context)
    tag1.id = UUID()
    tag1.name = "work"
    
    let tag2 = Tag(context: context)
    tag2.id = UUID()
    tag2.name = "important"
    
    note.tags = NSSet(array: [tag1, tag2])
    
    return VStack {
        NoteCardView(note: note) {
            print("Note tapped")
        }
        .padding()
    }
    .environment(\.managedObjectContext, context)
}
