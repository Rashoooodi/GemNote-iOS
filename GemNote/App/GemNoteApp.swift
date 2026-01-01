//
//  GemNoteApp.swift
//  GemNote
//
//  Main app entry point
//

import SwiftUI

@main
struct GemNoteApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView(context: persistenceController.viewContext)
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
