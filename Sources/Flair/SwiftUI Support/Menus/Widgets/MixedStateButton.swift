//
//  MixedStateButton.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/14/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Geometry

public enum MixedState {
    case on
    case off
    case mixed
}

extension MixedState {
    @ViewBuilder
    var image: some View {
        switch self {
        case .on:
            Image(systemName: "checkmark")
        case .off:
            EmptyView()
        case .mixed:
            Image(systemName: "minus")
        }
    }
}

public struct MixedStateButton: View {
    enum Title {
        case string(String)
        case attributed(AttributedString)
        
        var view: some View {
            switch self {
                case .string(let value):
                Text(value)
            case .attributed(let value):
                Text(value)
            }
        }
    }
    
    var title: Title
    var state: MixedState
    var action: () -> Void

    public var body: some View {
        Button(action: action) {
            state.image
            title.view
        }
    }
    
    public init(_ state: MixedState, _ title: AttributedString, action: @escaping () -> Void) {
        self.title  = .attributed(title)
        self.state  = state
        self.action = action
    }

    public init(_ state: MixedState, _ title: String, _ style: Style?, action: @escaping () -> Void) {
        if let style {
            let fixedAttributes = Style {
                $0.textColor = .primary
            }
            var string = AttributedString(title)
            string.documentStyle = style.appending(fixedAttributes)
            string = string.native
            
            self.title  = .attributed(string)
        } else {
            self.title  = .string(title)
        }
        
        self.state  = state
        self.action = action
    }

}

#Preview {
    Menu("Foo") {
        MixedStateButton(.on, "On State", Style {
            $0.fontName = .body
            $0.fontWeight = .light
        }, action: {})
        MixedStateButton(.off, "Off State", Style {
            $0.fontName = .body
            $0.fontWeight = .medium
        }, action: {})
        MixedStateButton(.mixed, "Mixed State", Style {
            $0.fontName = .body
            $0.fontWeight = .heavy
        }, action: {})
    }.preferredColorScheme(.light)
}
