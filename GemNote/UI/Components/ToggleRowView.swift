//
//  ToggleRowView.swift
//  GemNote
//
//  Reusable toggle row for settings and options
//

import SwiftUI

/// Toggle row with icon, title, and optional subtitle
struct ToggleRowView: View {
    let icon: String
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    var iconColor: Color = GemNoteTheme.Colors.primary
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconColor: Color = GemNoteTheme.Colors.primary,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self._isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: GemNoteTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(GemNoteTheme.Typography.body)
                    .foregroundColor(GemNoteTheme.Colors.text)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(GemNoteTheme.Colors.secondaryText)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(GemNoteTheme.Spacing.md)
        .background(GemNoteTheme.Colors.cardBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
    }
}

#Preview {
    VStack(spacing: 16) {
        ToggleRowView(
            icon: "wand.and.stars",
            title: "Enable AI Summary",
            subtitle: "Generate AI summaries for notes",
            isOn: .constant(true)
        )
        
        ToggleRowView(
            icon: "tag",
            title: "Tag Suggestions",
            isOn: .constant(false)
        )
    }
    .padding()
}
