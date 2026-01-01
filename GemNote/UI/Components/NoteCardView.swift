//
//  NoteCardView.swift
//  GemNote
//
//  Card view for displaying note in list
//

import SwiftUI
import CoreData

/// Card view for displaying a note in a list
struct NoteCardView: View {
    @ObservedObject var note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            // Header with date and indicators
            HStack {
                Text(note.updatedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                    .font(GemNoteTheme.Typography.caption)
                    .foregroundColor(GemNoteTheme.Colors.secondaryText)
                
                Spacer()
                
                if note.audioPath != nil {
                    Image(systemName: "waveform")
                        .font(.caption)
                        .foregroundColor(GemNoteTheme.Colors.accent)
                }
                
                if note.aiSummary != nil {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(GemNoteTheme.Colors.primary)
                }
            }
            
            // Note text preview
            Text(note.rawText ?? "")
                .font(GemNoteTheme.Typography.body)
                .foregroundColor(GemNoteTheme.Colors.text)
                .lineLimit(3)
            
            // Tags
            if let tags = note.tags as? Set<Tag>, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: GemNoteTheme.Spacing.xs) {
                        ForEach(Array(tags).sorted(by: { ($0.name ?? "") < ($1.name ?? "") }), id: \.id) { tag in
                            Text(tag.name ?? "")
                                .font(GemNoteTheme.Typography.caption)
                                .padding(.horizontal, GemNoteTheme.Spacing.sm)
                                .padding(.vertical, GemNoteTheme.Spacing.xs)
                                .background(GemNoteTheme.Colors.primary.opacity(0.1))
                                .foregroundColor(GemNoteTheme.Colors.primary)
                                .cornerRadius(GemNoteTheme.CornerRadius.sm)
                        }
                    }
                }
            }
        }
        .padding(GemNoteTheme.Spacing.md)
        .background(GemNoteTheme.Colors.cardBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
        .shadow(
            color: GemNoteTheme.Shadow.card.color,
            radius: GemNoteTheme.Shadow.card.radius,
            x: GemNoteTheme.Shadow.card.x,
            y: GemNoteTheme.Shadow.card.y
        )
    }
}

#Preview {
    let controller = PersistenceController.preview
    let note = Note(context: controller.viewContext)
    note.id = UUID()
    note.createdAt = Date()
    note.updatedAt = Date()
    note.rawText = "This is a sample note with some content that demonstrates the card layout."
    note.aiSummary = "Sample summary"
    note.audioPath = "/path/to/audio"
    
    return NoteCardView(note: note)
        .padding()
        .previewLayout(.sizeThatFits)
}
