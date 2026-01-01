//
//  PersistenceController.swift
//  GemNote
//
//  Core Data persistence layer
//

import CoreData

/// Manages Core Data stack and provides access to persistent storage
final class PersistenceController {
    static let shared = PersistenceController()
    
    /// Preview instance for SwiftUI previews with in-memory store
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for previews
        for i in 0..<5 {
            let note = Note(context: viewContext)
            note.id = UUID()
            note.createdAt = Date().addingTimeInterval(-Double(i) * 86400)
            note.updatedAt = Date()
            note.rawText = "Sample note \(i + 1)\n\nThis is a preview note for development."
            note.isAISummaryEnabled = i % 2 == 0
            note.isTagSuggestionEnabled = i % 2 == 0
            
            if i % 2 == 0 {
                note.aiSummary = "This is a sample AI-generated summary for note \(i + 1)."
                note.aiModel = GeminiModel.gemini15Flash.rawValue
            }
        }
        
        try? viewContext.save()
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
                // In production, implement proper error handling
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Context Management
    
    /// Main view context for UI operations
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    /// Create a new background context for non-UI operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Save Operations
    
    /// Save the view context if there are changes
    func save() throws {
        let context = viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// Save a specific context if there are changes
    func save(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - Batch Operations
    
    /// Clear all AI summaries from notes
    func clearAllAISummaries() throws {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        let notes = try viewContext.fetch(fetchRequest)
        
        for note in notes {
            note.aiSummary = nil
            note.aiModel = nil
        }
        
        try save()
    }
    
    /// Delete all data (for testing/development)
    func deleteAllData() throws {
        let entities = ["Note", "Tag", "Attachment"]
        
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try viewContext.execute(deleteRequest)
        }
        
        try save()
    }
}
