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
    
    public init(_ text: String, selectable: Bool = true) {
        self.options = selectable ? .selectable : .display
        self._text   = .constant(AttributedString(text).object())
    }
    
    public init(_ text: AttributedString, selectable: Bool = true) {
        self.options = selectable ? .selectable : .display
        self._text   = .constant(text.object())
    }
    
    public init(_ text: NSAttributedString, selectable: Bool = true) {
        self.options = selectable ? .selectable : .display
        self._text   = .constant(text)
    }
    
    public init(_ text: Binding<String>, options: FlairTextOptions = .editable, delegate: FlairTextDelegate? = nil) {
        self.options  = options
        self.delegate = delegate
        
        self._text = Binding(
            get: { AttributedString(text.wrappedValue).object() },
            set: { storage in text.wrappedValue = storage.string }
        )
    }
    
    public init(_ text: Binding<AttributedString>, options: FlairTextOptions = .editable, delegate: FlairTextDelegate? = nil) {
        self.options  = options
        self.delegate = delegate
        
        self._text = Binding(
            get: { text.wrappedValue.object() },
            set: { storage in text.wrappedValue = storage.value() }
        )
    }
    
    public init(_ text: Binding<NSAttributedString>, options: FlairTextOptions = .editable, delegate: FlairTextDelegate? = nil) {
        self.options  = options
        self.delegate = delegate
        
        self._text = text
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
        
        allowsUndo: Bool = true,
        isRichText: Bool = true,
        
        endsEditingOnNewline: Bool = true
    ) {
        self.interactivity = interactivity
        self.allowsUndo = allowsUndo
        self.isRichText = isRichText
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
    return FlairText("Hello World", selectable: true).padding()
}
