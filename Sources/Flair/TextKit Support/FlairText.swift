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
    var delegate: FlairTextDelegate?
    
    @Binding var text: NSAttributedString

    @Binding var selection: [NSRange]
    
    private static func ignored() -> Binding<[NSRange]> {
        var ranges: [NSRange] = []
        
        return Binding {
            ranges
        } set: { value in
            ranges = value
        }
    }
    
    public init(_ text: String, selection: Binding<[NSRange]>? = nil, selectable: Bool = true) {
        self.options    = selectable ? .selectable : .display
        self._text      = .constant(AttributedString(text).object())
        self._selection = selection ?? Self.ignored()
    }
    
    public init(_ text: AttributedString, selection: Binding<[NSRange]>? = nil, selectable: Bool = true) {
        self.options    = selectable ? .selectable : .display
        self._text      = .constant(text.object())
        self._selection = selection ?? Self.ignored()
    }
    
    public init(_ text: NSAttributedString, selection: Binding<[NSRange]>? = nil, selectable: Bool = true) {
        self.options    = selectable ? .selectable : .display
        self._text      = .constant(text)
        self._selection = selection ?? Self.ignored()
    }
    
    public init(_ text: Binding<String>, selection: Binding<[NSRange]>? = nil, options: FlairTextOptions = .editable, delegate: FlairTextDelegate? = nil) {
        self.options  = options
        self.delegate = delegate
        
        self._text = Binding(
            get: { AttributedString(text.wrappedValue).object() },
            set: { storage in text.wrappedValue = storage.string }
        )
        
        self._selection = selection ?? Self.ignored()
    }
    
    public init(_ text: Binding<AttributedString>, selection: Binding<[NSRange]>? = nil, options: FlairTextOptions = .editable, delegate: FlairTextDelegate? = nil) {
        self.options  = options
        self.delegate = delegate
        
        self._text = Binding(
            get: { text.wrappedValue.object() },
            set: { storage in text.wrappedValue = storage.value() }
        )
        self._selection = selection ?? Self.ignored()
    }
    
    public init(_ text: Binding<NSAttributedString>, selection: Binding<[NSRange]>? = nil, options: FlairTextOptions = .editable, delegate: FlairTextDelegate? = nil) {
        self.options  = options
        self.delegate = delegate
        
        self._text = text
        self._selection = selection ?? Self.ignored()
    }
}

public struct FlairTextOptions {
    public static var display    = FlairTextOptions(interactivity: .display)
    public static var editable   = FlairTextOptions(interactivity: .editable)
    public static var selectable = FlairTextOptions(interactivity: .selectable)

    public enum Interactivity: Equatable {
        case display
        case editable
        case selectable
    }
    
    let interactivity: Interactivity
    
    let allowsUndo: Bool
    let isRichText: Bool
    
    let endsEditingOnNewline: Bool
    
    public init(
        interactivity: Interactivity,
        
        isRichText: Bool = true,
        allowsUndo: Bool = true,

        endsEditingOnNewline: Bool = true
    ) {
        self.interactivity        = interactivity

        self.isRichText           = isRichText
        self.allowsUndo           = allowsUndo
        self.endsEditingOnNewline = endsEditingOnNewline
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
        FlairText("Hello World", selectable: true)
    }.padding().preferredColorScheme(.light)

}
