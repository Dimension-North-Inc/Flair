//
//  FontWeightMenu.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/14/24.
//  Copyright © 2024, Dimension North Inc. All Rights Reserved

import SwiftUI

public struct FontWeightMenu: View {
    @FocusedValue(\.styles) var selection
    
    public init() {}
    
    public var body: some View {
        Menu(content: {options}, label: {title})
    }
    
    @ViewBuilder public var title: some View {
        if case let .single(weight) = selection?.fontWeight {
            let font = Style {
                $0.fontName = .body
                $0.fontWeight = weight
            }.font
            Text(weight.description.capitalized)
                .font(font.flatMap(Font.init))
        } else {
            Text("Weight")
        }
    }

    @ViewBuilder public var options: some View {
        ForEach(FontWeight.allCases, id: \.self) {
            weight in
            let style = Style {
                $0.fontName = .body
                $0.fontWeight = weight
            }
            MixedStateButton(state(weight), "\(weight.description.capitalized)", style) {
                select(weight)
            }
        }
    }
    
    func state(_ weight: FontWeight) -> MixedState {
        switch selection?.fontWeight {
        case nil, .empty: .off
        case let .single(value): weight == value ? .on : .off
        case let .multiple(values): values.contains(weight) ? .mixed : .off
        }
    }
    
    func select(_ weight: FontWeight) {
        selection?.update(key: \.fontWeight, value: weight)
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
