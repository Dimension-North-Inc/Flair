//
//  FontNameMenu.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/14/24.
//  Copyright © 2024, Dimension North Inc. All Rights Reserved

import Silo
import SwiftUI

private var FIXMESubFont = FontName.body

public struct FontNameMenu: View {
    @FocusedValue(\.styles) var selection
    
    @Default(.local("recentFonts"), default: []) private var recentFonts: [FontName]
    @Default(.local("maxRecentFontsCount"), default: 6) private var maxRecentFontsCount: Int
    
        
    public init() {}
    
    public var body: some View {
        Menu(content: {options}, label: {title})
    }

    @ViewBuilder public var title: some View {
        let selection = self.selection ?? []
        if case let .single(name) = selection.fontName {
            let font = Style {
                $0.fontName = FIXMESubFont
            }.font
            Text(name.description.capitalized)
                .font(font.flatMap(Font.init))
        } else {
            Text("Name")
        }
    }
    
    @ViewBuilder public var options: some View {
        ForEach(prefixFonts(), id: \.self) {
            name in
            let style = Style {
                $0.fontName = FIXMESubFont
            }
            MixedStateButton(state(name), "\(name.description.capitalized)", style) {
                select(name)
            }
            .frame(height: 26)
        }
        Divider()
        ForEach(FontName.allCases.filter(\.isNamed), id: \.self) {
            name in
            let style = Style {
                $0.fontName = FIXMESubFont
            }
            MixedStateButton(state(name), "\(name.description.capitalized)", style) {
                select(name)
            }
        }
    }
    
    func prefixFonts() -> [FontName] {
        var recents = Set(recentFonts)
        switch selection?.fontName {
        case let .single(value):    recents.insert(value)
        case let .multiple(values): recents.formUnion(values)
            
        default:
            break
        }
        
        return FontName.allCases.filter {
            name in recents.contains(name)
        }
    }
    
    func state(_ name: FontName) -> MixedState {
        switch selection?.fontName {
        case nil, .empty: .off
        case let .single(value): value == name ? .on : .off
        case let .multiple(values): values.contains(name) ? .mixed : .off
        }
    }
    
    func select(_ name: FontName) {
        // add the selected name to recents and trim the list to `maxRecentFontsCount` entries
        recentFonts = recentFonts.filter({ item in item != name }) + [name]
        recentFonts = recentFonts.suffix(maxRecentFontsCount)

        // merge our selection back into selected styles
        selection?.update(key: \.fontName, value: name)
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

    FontMenu()
        .menuStyle(.automatic)
        .padding()
}
