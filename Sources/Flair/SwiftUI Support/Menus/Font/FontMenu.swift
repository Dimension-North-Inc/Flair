//
//  FontMenu.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/14/24.
//  Copyright © 2024, Dimension North Inc. All Rights Reserved
//

import SwiftUI

public struct FontMenu: View {
    @FocusedValue(\.styles) var selection
    @State private var recentFonts: [FontName] = []
        
    public init() {}
    
    public var body: some View {
        Menu("Font") {
            options
        }
    }
    
    @ViewBuilder public var options: some View {
        FontNameMenu()
        FontSizeMenu()
        FontWidthMenu()
        FontWeightMenu()
        Divider()
        TextEffectsMenu()
        Divider()
        TextAlignmentMenu()
        Divider()

        Button("Show Fonts") {
            NSFontPanel.shared.orderFront(nil)
        }.keyboardShortcut("T", modifiers: .command)

        Button("Show Colors") {
            NSColorPanel.shared.orderFront(nil)
        }.keyboardShortcut("C", modifiers: [.command, .shift])
    }
}

#Preview {
    @Previewable @State var recentFonts: [FontName] = [
        .named("Hoefler Text"), .named("Times New Roman")
    ]
    
    @Previewable @State var selection: StyleSelection = [
        Style {
            $0.fontWeight = .ultraLight
            $0.fontWidth = .condensed

            $0.fontName  = .named("American Typewriter")
        },
        Style {
            $0.fontWeight = .black
            $0.fontWidth = .condensed

            $0.fontName  = .named("American Typewriter")
        }
    ]

    HStack {
        FontMenu()
    }
    .buttonStyle(.borderless)
    .padding()
}
