//
//  PrimaryButton.swift
//  GemNote
//
//  Reusable primary button component.
//

import SwiftUI

/// Standard primary button following Apple design guidelines
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: GemNoteTheme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .font(GemNoteTheme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(GemNoteTheme.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(GemNoteTheme.CornerRadius.md)
        }
        .disabled(isLoading)
    }
}

/// Secondary button style
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: GemNoteTheme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .font(GemNoteTheme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(GemNoteTheme.Colors.secondaryBackground)
            .foregroundColor(GemNoteTheme.Colors.primary)
            .cornerRadius(GemNoteTheme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: GemNoteTheme.CornerRadius.md)
                    .stroke(GemNoteTheme.Colors.primary, lineWidth: 1)
            )
        }
    }
}

/// Destructive button style
struct DestructiveButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(role: .destructive, action: action) {
            HStack(spacing: GemNoteTheme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .font(GemNoteTheme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(GemNoteTheme.Colors.destructive)
            .foregroundColor(.white)
            .cornerRadius(GemNoteTheme.CornerRadius.md)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton("Primary Button", icon: "checkmark.circle") {
            print("Primary tapped")
        }
        
        PrimaryButton("Loading...", isLoading: true) {
            print("Loading tapped")
        }
        
        SecondaryButton("Secondary Button", icon: "square.and.arrow.up") {
            print("Secondary tapped")
        }
        
        DestructiveButton("Delete", icon: "trash") {
            print("Delete tapped")
        }
    }
    .padding()
}
