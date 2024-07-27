//
//  TextAlignmentMenu.swift
//  FlairSamples
//
//  Created by Mark Onyschuk on 07/14/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

public struct TextAlignmentMenu: View {
    @FocusedValue(\.styles) var selection

    public init() {}
    
    public var body: some View {
        options
    }
    
    @ViewBuilder public var title: some View {
        let selection = self.selection ?? []
        if case let .single(alignment) = selection.textAlignment {
            Text(alignment.rawValue.capitalized)
        } else {
            Text("Alignment")
        }
    }

    @ViewBuilder public var options: some View {
        Button {
            align(.leading)
        } label: {
            Label("Align Left", systemImage: "textalign.left")
        }.keyboardShortcut("{", modifiers: .command)
        
        Button {
            align(.centered)
        } label: {
            Label("Center", systemImage: "textalign.center")
        }.keyboardShortcut("|", modifiers: .command)

        Button {
            align(.justified)
        } label: {
            Label("Justify", systemImage: "textjustify")
        }

        Button {
            align(.trailing)
        } label: {
            Label("Align Right", systemImage: "textalign.right")
        }.keyboardShortcut("}", modifiers: .command)
    }
    
    func align(_ alignment: AlignmentStyle) {
        selection?.merge(Style { $0.textAlignment = alignment }, .adding)
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

    FontMenu().padding()
}
