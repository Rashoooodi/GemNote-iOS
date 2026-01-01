//
//  PromptBuilder.swift
//  GemNote
//
//  Builds prompts for AI requests
//

import Foundation

/// Builds prompts for different AI operations
struct PromptBuilder {
    
    /// Create a summary prompt for a note
    static func summarizePrompt(for text: String) -> String {
        """
        Summarize the following note clearly and concisely. Do not invent details.
        
        Note:
        \(text)
        """
    }
    
    /// Create a tag suggestion prompt for a note
    static func tagSuggestionPrompt(for text: String) -> String {
        """
        Suggest up to 5 single-word tags for this note. Return only the tags separated by commas.
        
        Note:
        \(text)
        """
    }
}
