//
//  TextView.swift
//  Flair
//
//  Created by Mark Onyschuk on 10/09/23.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

public struct FlairText {
    var options: FlairTextOptions
    
    @Binding var text: NSAttributedString

    @Binding var selection: [NSRange]
    
    private static func ignoresSelection() -> Binding<[NSRange]> {
        var ranges: [NSRange] = []
        
        return Binding {
            ranges
        } set: { value in
            ranges = value
        }
    }
    
    public init(_ text: String, selection: Binding<[NSRange]>? = nil) {
        self._text      = .constant(AttributedString(text).object())
        self._selection = selection ?? Self.ignoresSelection()

        self.options    = selection != nil ? .selectable() : .display()
    }
    
    public init(_ text: AttributedString, selection: Binding<[NSRange]>? = nil) {
        self._text      = .constant(text.object())
        self._selection = selection ?? Self.ignoresSelection()

        self.options    = selection != nil ? .selectable() : .display()
    }
    
    public init(_ text: NSAttributedString, selection: Binding<[NSRange]>? = nil) {
        self._text      = .constant(text)
        self._selection = selection ?? Self.ignoresSelection()

        self.options    = selection != nil ? .selectable() : .display()
    }
    
    public init(_ text: Binding<String>, selection: Binding<[NSRange]>? = nil, options: FlairTextOptions = .editable()) {
        self._text      = Binding(
            get: { AttributedString(text.wrappedValue).object() },
            set: { storage in text.wrappedValue = storage.string }
        )
        
        self._selection = selection ?? Self.ignoresSelection()

        self.options    = options
    }
    
    public init(_ text: Binding<AttributedString>, selection: Binding<[NSRange]>? = nil, options: FlairTextOptions = .editable()) {
        self._text      = Binding(
            get: { text.wrappedValue.object() },
            set: { storage in text.wrappedValue = storage.value() }
        )
        self._selection = selection ?? Self.ignoresSelection()

        self.options    = options
    }
    
    public init(_ text: Binding<NSAttributedString>, selection: Binding<[NSRange]>? = nil, options: FlairTextOptions = .editable()) {
        self._text      = text
        self._selection = selection ?? Self.ignoresSelection()

        self.options    = options
    }
}

public struct FlairTextOptions {
    public enum Interactivity: Equatable {
        case display
        case editable
        case selectable
    }
    
    public enum ClickSelection: Equatable {
        case all
        case location
    }
    
    let interactivity: Interactivity

    public typealias Configuration = (inout Self) -> Void

    public static func display(configuration: Configuration? = nil) -> Self {
        Self(.display, configuration: configuration)
    }
    public static func editable(configuration: Configuration? = nil) -> Self {
        Self(.editable, configuration: configuration)
    }
    public static func selectable(configuration: Configuration? = nil) -> Self {
        Self(.selectable, configuration: configuration)
    }
    
    
    public var allowsUndo = true
    public var isRichText = true
    
    public var endsEditingOnNewline = true

    public var clickSelects = ClickSelection.location

    public var editor = FlairTextEditingOptions()
    
    public init(_ interactivity: Interactivity, configuration: Configuration?) {
        self.interactivity = interactivity
        configuration?(&self)
    }
}

extension NSAttributedString {
    /// Creates and returns the value type equivalent of the receiver
    /// - Returns: an   AttributedString`
    public func value() -> AttributedString {
        return AttributedString(self)
    }
}

extension AttributedString {
    /// Creates and returns the reference type equivalent of the receiver
    /// - Returns: an `NSAttributedString`
    public func object() -> NSAttributedString {
        return NSAttributedString(self)
    }
}

extension AttributeContainer: ExpressibleByDictionaryLiteral {
    public typealias Key   = NSAttributedString.Key
    public typealias Value = Any
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(elements, uniquingKeysWith: { old, new in new }))
    }
}

#Preview {
    return VStack {
        FlairText("Hello World", selection: .constant([]))
    }.padding().preferredColorScheme(.light)

}
