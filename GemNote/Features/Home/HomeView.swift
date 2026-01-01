//
//  HomeView.swift
//  GemNote
//
//  Main home timeline view.
//

import SwiftUI

/// Main home view with timeline and quick actions
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showRecorder = false
    @State private var showSettings = false
    @State private var selectedNote: Note?
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: GemNoteTheme.Spacing.lg) {
                    // Greeting Header
                    greetingHeader
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Last AI Activity Card
                    if viewModel.lastAINote != nil {
                        lastAIActivitySection
                    }
                    
                    // Recent Notes Section
                    recentNotesSection
                }
                .padding()
            }
            .navigationTitle("GemNote")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onAppear {
                viewModel.fetchRecentNotes()
            }
            .refreshable {
                viewModel.fetchRecentNotes()
            }
            .sheet(isPresented: $showRecorder) {
                RecorderView(context: viewModel.context)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .navigationDestination(item: $selectedNote) { note in
                NoteDetailView(note: note, context: viewModel.context)
            }
            .alert("Home", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.getGreeting())
                .font(GemNoteTheme.Typography.largeTitle)
            
            Text("What would you like to note today?")
                .font(GemNoteTheme.Typography.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: GemNoteTheme.Spacing.sm) {
            HStack(spacing: GemNoteTheme.Spacing.sm) {
                // New Text Note
                QuickActionButton(
                    icon: "square.and.pencil",
                    title: "Text Note",
                    color: .blue
                ) {
                    let note = viewModel.createTextNote()
                    selectedNote = note
                }
                
                // Record Audio
                QuickActionButton(
                    icon: "mic.fill",
                    title: "Record",
                    color: .red
                ) {
                    showRecorder = true
                }
            }
        }
    }
    
    private var lastAIActivitySection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            Label("Last AI Activity", systemImage: "sparkles")
                .font(GemNoteTheme.Typography.headline)
            
            if let note = viewModel.lastAINote {
                Button(action: { selectedNote = note }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "cpu")
                                .foregroundColor(.secondary)
                            
                            Text(note.updatedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                                .font(GemNoteTheme.Typography.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if let model = note.aiModel {
                                Text(GeminiModel(rawValue: model)?.displayName ?? model)
                                    .font(GemNoteTheme.Typography.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text(note.aiSummary ?? "")
                            .font(GemNoteTheme.Typography.body)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [GemNoteTheme.Colors.primary.opacity(0.1), GemNoteTheme.Colors.accent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(GemNoteTheme.CornerRadius.md)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var recentNotesSection: some View {
        VStack(alignment: .leading, spacing: GemNoteTheme.Spacing.sm) {
            HStack {
                Label("Recent Notes", systemImage: "doc.text")
                    .font(GemNoteTheme.Typography.headline)
                
                Spacer()
                
                Text("\(viewModel.recentNotes.count)")
                    .font(GemNoteTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.recentNotes.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.recentNotes, id: \.id) { note in
                    NoteCardView(note: note) {
                        selectedNote = note
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: GemNoteTheme.Spacing.md) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No notes yet")
                .font(GemNoteTheme.Typography.headline)
                .foregroundColor(.secondary)
            
            Text("Tap the buttons above to create your first note")
                .font(GemNoteTheme.Typography.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, GemNoteTheme.Spacing.xxl)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: GemNoteTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(GemNoteTheme.Typography.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, GemNoteTheme.Spacing.lg)
            .background(GemNoteTheme.Colors.secondaryBackground)
            .cornerRadius(GemNoteTheme.CornerRadius.md)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(context: PersistenceController.preview.container.viewContext)
}
