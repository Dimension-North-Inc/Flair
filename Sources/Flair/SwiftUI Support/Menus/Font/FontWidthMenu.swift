//
//  FontWidthMenu.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/14/24.
//  Copyright © 2024, Dimension North Inc. All Rights Reserved

import SwiftUI

public struct FontWidthMenu: View {
    @FocusedValue(\.styles) var selection

    public init() {}
    
    public var body: some View {
        Menu(content: {options}, label: {title})
    }
    
    @ViewBuilder public var title: some View {
        if case let .single(width) = selection?.fontWidth {
            let font = Style {
                $0.fontName = .body
                $0.fontWidth = width
            }.font
            Text(width.description.capitalized)
                .font(font.flatMap(Font.init))
        } else {
            Text("Width")
        }
    }
    
    @ViewBuilder public var options: some View {
        ForEach(FontWidth.allCases, id: \.self) {
            width in
            let style = Style {
                $0.fontName = .body
                $0.fontWidth = width
            }
            MixedStateButton(state(width), "\(width.description.capitalized)", style) {
                select(width)
            }
        }
    }
    
    func state(_ width: FontWidth) -> MixedState {
        switch selection?.fontWidth {
        case nil, .empty: .off
        case let .single(value): width == value ? .on : .off
        case let .multiple(values): values.contains(width) ? .mixed : .off
        }
    }
    
    func select(_ width: FontWidth) {
        selection?.update(key: \.fontWidth, value: width)
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
}
