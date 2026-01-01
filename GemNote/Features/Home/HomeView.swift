//
//  HomeView.swift
//  GemNote
//
//  Home screen showing recent notes and quick actions
//

import SwiftUI
import CoreData

/// Home screen with timeline and quick actions
struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HomeViewModel
    @State private var showingNewNoteSheet = false
    @State private var showingRecorder = false
    @State private var showingSettings = false
    @State private var newNoteText = ""
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: GemNoteTheme.Spacing.lg) {
                    // Greeting Header
                    greetingSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Last AI Activity
                    if let aiNote = viewModel.lastAIActivityNote {
                        lastAIActivitySection(note: aiNote)
                    }
                    
                    // Recent Notes
                    recentNotesSection
                }
                .padding(GemNoteTheme.Spacing.md)
            }
            .background(GemNoteTheme.Colors.background)
            .navigationTitle("GemNote")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingNewNoteSheet) {
                newNoteSheet
            }
            .sheet(isPresented: $showingRecorder) {
                RecorderView(context: viewContext)
            }
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    SettingsView(context: viewContext)
                }
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    // MARK: - View Components
    
    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greeting)
                    .font(GemNoteTheme.Typography.largeTitle)
                    .foregroundColor(GemNoteTheme.Colors.text)
                
                Text("Ready to capture your thoughts?")
                    .font(GemNoteTheme.Typography.body)
                    .foregroundColor(GemNoteTheme.Colors.secondaryText)
            }
            Spacer()
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: GemNoteTheme.Spacing.sm) {
            HStack(spacing: GemNoteTheme.Spacing.sm) {
                quickActionCard(
                    icon: "square.and.pencil",
                    title: "New Note",
                    color: GemNoteTheme.Colors.primary
                ) {
                    showingNewNoteSheet = true
                }
                
                quickActionCard(
                    icon: "mic.fill",
                    title: "Record",
                    color: GemNoteTheme.Colors.error
                ) {
                    showingRecorder = true
                }
            }
        }
    }
    
    private func quickActionCard(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: GemNoteTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(GemNoteTheme.Typography.callout)
                    .foregroundColor(GemNoteTheme.Colors.text)
            }
            .frame(maxWidth: .infinity)
            .padding(GemNoteTheme.Spacing.lg)
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
    
    private func lastAIActivitySection(note: Note) -> some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(GemNoteTheme.Colors.primary)
                Text("Last AI Activity")
                    .font(GemNoteTheme.Typography.headline)
                Spacer()
            }
            
            NavigationLink {
                NoteDetailView(note: note, context: viewContext)
            } label: {
                NoteCardView(note: note)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var recentNotesSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            HStack {
                Text("Recent Notes")
                    .font(GemNoteTheme.Typography.headline)
                Spacer()
                Text("\(viewModel.recentNotes.count)")
                    .font(GemNoteTheme.Typography.caption)
                    .foregroundColor(GemNoteTheme.Colors.secondaryText)
            }
            
            if viewModel.recentNotes.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.recentNotes, id: \.id) { note in
                    NavigationLink {
                        NoteDetailView(note: note, context: viewContext)
                    } label: {
                        NoteCardView(note: note)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: GemNoteTheme.Spacing.md) {
            Image(systemName: "note.text")
                .font(.system(size: 48))
                .foregroundColor(GemNoteTheme.Colors.secondaryText)
            
            Text("No notes yet")
                .font(GemNoteTheme.Typography.title3)
                .foregroundColor(GemNoteTheme.Colors.text)
            
            Text("Create your first note using the buttons above")
                .font(GemNoteTheme.Typography.body)
                .foregroundColor(GemNoteTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(GemNoteTheme.Spacing.xl)
        .background(GemNoteTheme.Colors.cardBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
    }
    
    private var newNoteSheet: some View {
        NavigationStack {
            VStack(spacing: GemNoteTheme.Spacing.md) {
                TextEditor(text: $newNoteText)
                    .font(GemNoteTheme.Typography.body)
                    .frame(minHeight: 200)
                    .padding(GemNoteTheme.Spacing.sm)
                    .background(GemNoteTheme.Colors.cardBackground)
                    .cornerRadius(GemNoteTheme.CornerRadius.md)
                
                Spacer()
            }
            .padding(GemNoteTheme.Spacing.md)
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newNoteText = ""
                        showingNewNoteSheet = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !newNoteText.isEmpty {
                            viewModel.createTextNote(text: newNoteText)
                            newNoteText = ""
                            showingNewNoteSheet = false
                        }
                    }
                    .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    HomeView(context: PersistenceController.preview.viewContext)
}
