//
//  ToggleRowView.swift
//  GemNote
//
//  Reusable toggle row component for settings.
//

import SwiftUI

/// A settings-style toggle row with icon, title, and optional subtitle
struct ToggleRowView: View {
    let icon: String
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: GemNoteTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(GemNoteTheme.Colors.primary)
                .frame(width: 30, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(GemNoteTheme.Typography.body)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(GemNoteTheme.Typography.caption)
                        .foregroundColor(GemNoteTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(GemNoteTheme.Colors.secondaryBackground)
        .cornerRadius(GemNoteTheme.CornerRadius.md)
    }
}

#Preview {
    VStack {
        ToggleRowView(
            icon: "wand.and.stars",
            title: "Enable AI Summary",
            subtitle: "Automatically generate summaries",
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
