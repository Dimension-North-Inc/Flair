//
//  TextView.swift
//  Flair
//
//  Created by Mark Onyschuk on 10/09/23.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

public struct FlairText {
    public struct Options {
        static var display    = Options(interactivity: .display)
        static var editable   = Options(interactivity: .editable)
        static var selectable = Options(interactivity: .selectable)

        public enum Interactivity: Equatable {
            case display
            case editable
            case selectable
        }
        
        let interactivity: Interactivity
        
        let allowsUndo: Bool
        let isRichText: Bool
        
        let endsEditingOnNewline: Bool
        
        init(
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
    
    public var options: Options
    public var delegate: FlairTextDelegate?
    
    @Binding var text: NSAttributedString

    init(_ text: String, selectable: Bool = true) {
        self.options = selectable ? .selectable : .display
        self._text   = .constant(AttributedString(text).object())
    }
    
    init(_ text: AttributedString, selectable: Bool = true) {
        self.options = selectable ? .selectable : .display
        self._text   = .constant(text.object())
    }
    
    init(_ text: NSAttributedString) {
        self.options = .display
        self._text   = .constant(text)
    }

    init(_ text: Binding<String>, options: Options = .editable, delegate: FlairTextDelegate? = nil) {
        self.options = options
        self.delegate = delegate
        
        self._text = Binding(
            get: { AttributedString(text.wrappedValue).object() },
            set: { storage in text.wrappedValue = storage.string }
        )
    }
    
    init(_ text: Binding<AttributedString>, options: Options = .editable, delegate: FlairTextDelegate? = nil) {
        self.options = options
        self.delegate = delegate
        
        self._text = Binding(
            get: { text.wrappedValue.object() },
            set: { storage in text.wrappedValue = storage.value() }
        )
    }
    
    init(_ text: Binding<NSAttributedString>, options: Options = .editable, delegate: FlairTextDelegate? = nil) {
        self.options = options
        self.delegate = delegate
        
        self._text = text
    }
}

extension NSAttributedString {
    func value() -> AttributedString {
        return AttributedString(self)
    }
}

extension AttributedString {
    func object() -> NSAttributedString {
        return NSAttributedString(self)
    }
}

extension AttributeContainer: ExpressibleByDictionaryLiteral {
    public typealias Key = NSAttributedString.Key
    
    public typealias Value = Any
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(elements, uniquingKeysWith: { old, new in new }))
    }
}

#Preview {
    return FlairText("Hello World").padding()
}
