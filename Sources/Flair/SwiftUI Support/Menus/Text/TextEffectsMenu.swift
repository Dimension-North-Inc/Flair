//
//  TextEffectsMenu.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/15/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

public struct TextEffectsMenu: View {
    @FocusedValue(\.styles) var selection

    public init() {}
    
    public var body: some View {
        options
    }
    
    @ViewBuilder public var title: some View {
        if case let .single(alignment) = selection?.textAlignment {
            Text(alignment.rawValue.capitalized)
        } else {
            Text("Alignment")
        }
    }

    @ViewBuilder public var options: some View {
        MixedStateButton(state(of: \.bold, value: true), "Bold", nil) {
            selection?.update(key: \.bold, value: true)
        }.keyboardShortcut("B", modifiers: .command)
        
        MixedStateButton(state(of: \.italic, value: true), "Italic", nil) {
            selection?.update(key: \.italic, value: true)
        }.keyboardShortcut("I", modifiers: .command)
        
        MixedStateButton(state(of: \.outline, value: true), "Outline", nil) {
            selection?.update(key: \.outline, value: true)
        }
        
        MixedStateButton(state(of: \.underline, value: UnderlineStyle()), "Underline", nil) {
            selection?.update(key: \.underline, value: UnderlineStyle())
        }.keyboardShortcut("U", modifiers: .command)
        
        MixedStateButton(state(of: \.strikethrough, value: StrikethroughStyle()), "Strikethrough", nil) {
            selection?.update(key: \.strikethrough, value: StrikethroughStyle())
        }.keyboardShortcut("U", modifiers: [.command, .shift])
    }
    
    func state<Key>(of key: KeyPath<Style.Keys, Key.Type>, value match: Key.Value) -> MixedState where Key: StyleKeys {
        switch selection?.cardinality(of: key) {
        case nil, .empty:
            return .off
        case .multiple:
            return .mixed
        case .single(let value):
            return value == match ? .on : .off
        }
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
