//
//  HomeViewModel.swift
//  GemNote
//
//  View model for the home timeline.
//

import Foundation
import CoreData

/// Manages the home timeline display
@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var recentNotes: [Note] = []
    @Published var lastAINote: Note?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let maxRecentNotes = 10
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    /// Fetch recent notes from Core Data
    func fetchRecentNotes() {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)]
        fetchRequest.fetchLimit = maxRecentNotes
        
        do {
            recentNotes = try context.fetch(fetchRequest)
            fetchLastAIActivity()
        } catch {
            showErrorAlert("Failed to fetch notes: \(error.localizedDescription)")
        }
    }
    
    /// Create a new text note
    func createTextNote() -> Note {
        let note = Note(context: context)
        note.id = UUID()
        note.createdAt = Date()
        note.updatedAt = Date()
        note.rawText = ""
        note.isAISummaryEnabled = UserDefaults.standard.bool(forKey: "enable_ai_by_default")
        note.isTagSuggestionEnabled = false
        
        do {
            try context.save()
            fetchRecentNotes()
        } catch {
            showErrorAlert("Failed to create note: \(error.localizedDescription)")
        }
        
        return note
    }
    
    /// Get greeting based on time of day
    func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchLastAIActivity() {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "aiSummary != nil")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            lastAINote = try context.fetch(fetchRequest).first
        } catch {
            // Silently fail for AI activity - not critical
            print("Failed to fetch AI activity: \(error)")
        }
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}
