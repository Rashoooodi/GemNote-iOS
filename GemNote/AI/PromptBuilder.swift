//
//  PromptBuilder.swift
//  GemNote
//
//  Builds prompts for various AI operations.
//

import Foundation

/// Builds prompts for Gemini AI interactions
struct PromptBuilder {
    
    // MARK: - Summary Prompts
    
    /// Generate a summary prompt for a note
    static func summarize(text: String) -> String {
        """
        Summarize the following note clearly and concisely. Do not invent details.
        
        Note:
        \(text)
        """
    }
    
    // MARK: - Tag Suggestion Prompts
    
    /// Generate a tag suggestion prompt for a note
    static func suggestTags(text: String) -> String {
        """
        Suggest up to 5 single-word tags for this note. Return only the tags, separated by commas.
        
        Note:
        \(text)
        """
    }
    
    // MARK: - Combined Prompts
    
    /// Generate a combined prompt for summary and tags
    static func summarizeAndSuggestTags(text: String) -> String {
        """
        For the following note:
        1. Provide a clear and concise summary (do not invent details)
        2. Suggest up to 5 single-word tags
        
        Format your response as:
        SUMMARY: [your summary here]
        TAGS: [tag1, tag2, tag3, ...]
        
        Note:
        \(text)
        """
    }
}
