//
//  PrimaryButton.swift
//  GemNote
//
//  Reusable primary button component
//

import SwiftUI

/// Primary button with consistent styling
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isDestructive: Bool = false
    var isDisabled: Bool = false
    
    init(
        _ title: String,
        icon: String? = nil,
        isDestructive: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: GemNoteTheme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                Text(title)
                    .font(GemNoteTheme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(GemNoteTheme.CornerRadius.md)
            .shadow(
                color: GemNoteTheme.Shadow.button.color,
                radius: GemNoteTheme.Shadow.button.radius,
                x: GemNoteTheme.Shadow.button.x,
                y: GemNoteTheme.Shadow.button.y
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return GemNoteTheme.Colors.secondary
        } else if isDestructive {
            return GemNoteTheme.Colors.error
        } else {
            return GemNoteTheme.Colors.primary
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton("Save Note", icon: "checkmark") {}
        PrimaryButton("Delete", isDestructive: true) {}
        PrimaryButton("Disabled", isDisabled: true) {}
    }
    .padding()
}
