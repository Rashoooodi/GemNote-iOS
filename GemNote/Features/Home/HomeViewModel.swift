//
//  HomeViewModel.swift
//  GemNote
//
//  ViewModel for HomeView
//

import Foundation
import CoreData
import SwiftUI

/// ViewModel for the home screen
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recentNotes: [Note] = []
    @Published var lastAIActivityNote: Note?
    
    private let context: NSManagedObjectContext
    private let maxRecentNotes = 10
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        loadRecentNotes()
        loadLastAIActivity()
    }
    
    private func loadRecentNotes() {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)]
        fetchRequest.fetchLimit = maxRecentNotes
        
        do {
            recentNotes = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch recent notes: \(error)")
            recentNotes = []
        }
    }
    
    private func loadLastAIActivity() {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "aiSummary != nil")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let notes = try context.fetch(fetchRequest)
            lastAIActivityNote = notes.first
        } catch {
            print("Failed to fetch last AI activity: \(error)")
            lastAIActivityNote = nil
        }
    }
    
    // MARK: - Note Creation
    
    func createTextNote(text: String) {
        let note = Note(context: context)
        note.id = UUID()
        note.createdAt = Date()
        note.updatedAt = Date()
        note.rawText = text
        note.isAISummaryEnabled = UserDefaults.standard.enableAIByDefault
        note.isTagSuggestionEnabled = UserDefaults.standard.enableAIByDefault
        
        do {
            try context.save()
            loadData()
        } catch {
            print("Failed to save note: \(error)")
        }
    }
    
    // MARK: - Helper Properties
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
}
