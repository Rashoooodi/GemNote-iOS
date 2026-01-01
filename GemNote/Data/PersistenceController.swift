//
//  PersistenceController.swift
//  GemNote
//
//  Core Data stack and persistence controller.
//

import CoreData

/// Manages the Core Data stack for the application
struct PersistenceController {
    /// Shared singleton instance
    static let shared = PersistenceController()
    
    /// Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for previews
        for i in 0..<5 {
            let note = Note(context: viewContext)
            note.id = UUID()
            note.createdAt = Date().addingTimeInterval(TimeInterval(-i * 3600))
            note.updatedAt = note.createdAt
            note.rawText = "Sample note \(i + 1)"
            note.isAISummaryEnabled = i % 2 == 0
            note.isTagSuggestionEnabled = i % 2 == 0
            
            if i % 2 == 0 {
                note.aiSummary = "This is a sample AI summary for note \(i + 1)"
                note.aiModel = GeminiModel.gemini15Flash.rawValue
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to create preview data: \(error)")
        }
        
        return controller
    }()
    
    let container: NSPersistentContainer
    
    // MARK: - Initialization
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GemNote")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this more gracefully
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context
    
    /// Save changes to the persistent store
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            // TODO: Add proper error handling and user notification
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Batch Operations
    
    /// Delete all AI summaries from all notes
    func clearAllAISummaries() throws {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "aiSummary != nil")
        
        let notes = try context.fetch(fetchRequest)
        
        for note in notes {
            note.aiSummary = nil
            note.aiModel = nil
        }
        
        try context.save()
    }
    
    /// Delete a note and its associated audio file
    func deleteNote(_ note: Note) throws {
        let context = container.viewContext
        
        // Delete audio file if it exists
        if let audioPath = note.audioPath {
            let fileURL = getDocumentsDirectory().appendingPathComponent(audioPath)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        context.delete(note)
        try context.save()
    }
    
    // MARK: - Helper Methods
    
    /// Get the app's documents directory
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
