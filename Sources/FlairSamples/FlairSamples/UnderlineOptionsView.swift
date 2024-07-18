//
//  UnderlineOptionsView.swift
//  FlairSamples
//
//  Created by Mark Onyschuk on 07/10/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import Flair
import SwiftUI

struct UnderlineOptionsView: View {
    @State private var stroke: Flair.Stroke = .single
    @State private var pattern: Flair.Pattern = .solid
    
    var body: some View {
        MultistateOptionList(
            options: [Flair.Stroke.thick, .single, .double],
            id: \.self, select: toggleStroke
        ) { option in
            switch option {
            case .thick:
                (Text("Thick"),  stroke == option ? .on : .off)
            case .single:
                (Text("Single"), stroke == option ? .on : .off)
            case .double:
                (Text("Double"), stroke == option ? .on : .off)
            }
        }
        Divider()
        MultistateOptionList(
            options: [Flair.Pattern.solid, .dashed, .dotted, .dashDotted, .dashDotDotted],
            id: \.self, select: togglePattern
        ) { option in
            switch option {
            case .solid:
                (Text("Solid"), pattern == option ? .on : .off)
            case .dashed:
                (Text("Dashed"),  pattern == option ? .on : .off)
            case .dotted:
                (Text("Dotted"),  pattern == option ? .on : .off)
            case .dashDotted:
                (Text("Dash-Dotted"), pattern == option ? .on : .off)
            case .dashDotDotted:
                (Text("Dash-Dot-Dotted"), pattern == option ? .on : .off)
            }
        }
        Divider()

        ForEach(FontWeight.allCases, id: \.self) {
            weight in
            let style = Style {
                $0.fontName = .body
                $0.fontWeight = weight
            }
            MixedStateButton(.mixed, "\(weight.description.capitalized)", style) {
                print(#function)
            }
        }
        Divider()

        ForEach(FontWidth.allCases, id: \.self) {
            width in
            let style = Style {
                $0.fontName = .body
                $0.fontWidth = width
            }
            MixedStateButton(.mixed, "\(width.description.capitalized)", style) {
                print(#function)
            }
        }

        Divider()

        ForEach(FontAngle.allCases, id: \.self) {
            angle in
            let style = Style {
                $0.fontName = .body
                $0.fontAngle = angle
            }
            MixedStateButton(.mixed, "\(angle.description.capitalized)", style) {
                print(#function)
            }
        }
    }
    
    func toggleStroke(_ value: Flair.Stroke, selection: MixedState) {
        stroke = value
    }
    func togglePattern(_ value: Flair.Pattern, selection: MixedState) {
        pattern = value
    }
}

#Preview {
    UnderlineOptionsView()
        .padding()
    
}

public struct MixedStateButton: View {
    var title: AttributedString
    var state: MixedState
    var action: () -> Void

    public var body: some View {
        Button(action: action) {
            state.image
            Text(title)
        }
    }
    
    public init(_ state: MixedState, _ title: AttributedString, action: @escaping () -> Void) {
        self.title  = title
        self.state  = state
        self.action = action
    }

    public init(_ state: MixedState, _ title: String, _ style: Style, action: @escaping () -> Void) {
        var string = AttributedString(title)
        string.documentStyle = style
        
        self.title  = string.native
        self.state  = state
        self.action = action
    }

}

public enum MixedState {
    case on
    case off
    case mixed
    
    public var image: Image {
        switch self {
        case .on:
            Image(systemName: "checkmark")
        case .off:
            Image.empty(CGSize(width: 1, height: 1))
        case .mixed:
            Image(systemName: "minus")
        }
    }
}

struct MultistateOptionList<Options, ID, Content>: View
where Options: RandomAccessCollection, ID: Hashable, Content: View {
    
    var options: Options
    var id:      KeyPath<Options.Element, ID>
    
    var select: (Options.Element, MixedState) -> Void
    var content: (Options.Element) -> (view: Content, selection: MixedState)

    var body: some View {
        ForEach(options, id: id) {
            option in
            
            let (view, selection) = content(option)
                        
            Button(action: { selectItem(option, selection) }) {
                selection.image
                view
            }
        }
    }
                    
    func selectItem(_ option: Options.Element, _ selection: MixedState) {
        let update: MixedState = switch selection {
        case .mixed: .on
            
        case .on: .off
        case .off: .on
        }
        
        select(option, update)
    }
    
    init(
        options: Options, id: KeyPath<Options.Element, ID>,
        select: @escaping (Options.Element, MixedState) -> Void,
        content: @escaping (Options.Element) -> (view: Content, selection: MixedState)
    ) {
        self.options    = options
        self.id         = id
        self.select     = select
        self.content    = content
    }
    
    init(
        options: Options,
        select:  @escaping (Options.Element, MixedState) -> Void,
        content: @escaping (Options.Element) -> (view: Content, selection: MixedState)
    ) where Options.Element: Identifiable, Options.Element.ID == ID {
        self.init(options: options, id: \.id, select: select, content: content)
    }
    
}

struct TristateToggle: View {
    let label: String

    enum Tristate {
        case on
        case off
        case multiple
    }
    
    @Binding var state: Tristate
    @State private var isOn: Bool = false
    
    var body: some View {
        let image = switch state {
        case .on:       Image(systemName: "checkmark")
        case .off:      Image.empty(CGSize(width: 16, height: 16))
        case .multiple: Image(systemName: "minus")
        }
        
        Button(action: toggleTristate) {
            Text(label)
            image
        }
    }
    
    func toggleTristate() {
        switch state {
        case .on: state = .off
        case .off: state = .on
        case .multiple: state = .on
        }
    }
}

extension Image {
    static func empty(_ size: CGSize) -> Self {
        Self(size: size, renderer: { _ in })
    }
    static func empty(_ size: CGFloat) -> Self {
        Self.empty(CGSize(width: size, height: size))
    }
}
