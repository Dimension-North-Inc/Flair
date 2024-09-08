//
//  TextView.swift
//  Flair
//
//  Created by Mark Onyschuk on 10/09/23.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

struct IngnoredSelection {
    @State var ranges: [NSRange] = []
    func binding() -> Binding<[NSRange]> {
        return Binding(
            get: { self.ranges },
            set: { self.ranges = $0 }
        )
    }
}

public struct FlairText {
    public struct Options {
        public var isRichText: Bool = true
        
        public var isEditable: Bool = true
        public var isSelectable: Bool = true
        
        public var usesRuler: Bool = false
        public var usesFontPanel: Bool = true
                
        public var isFieldEditor: Bool = true
        
        public var importsGraphics: Bool = false
        public var allowsImageEditing: Bool = false
        
        public var usesAdaptiveColorMappingForDarkAppearance: Bool = true
        
        // editor delegation
        public var doCommand: ((Selector) -> Bool)? = nil
        
        public init() {}
        public init(configure: (inout Self)->Void) {
            configure(&self)
        }
        
        public static var editor = Options { opt in opt.isFieldEditor = false }
        public static var fieldEditor = Options { opt in opt.isFieldEditor = true }
    }
    
    @Binding var text: NSAttributedString
    @Binding var selection: [NSRange]
    
    var options: Options
    
    public init(text: Binding<String>, style: Style = Style(), selection: Binding<[NSRange]>? = nil, options: Options = .fieldEditor) {
        self._text = Binding<NSAttributedString>(
            get: {
                let str = AttributedString(text.wrappedValue, style: style)
                return NSAttributedString(str.native)
            },
            set: { obj in text.wrappedValue = obj.string }
        )
        self._selection = selection ?? IngnoredSelection().binding()
        
        self.options = options
    }
    
    public init(text: Binding<AttributedString>, selection: Binding<[NSRange]>? = nil, options: Options = .fieldEditor) {
        self._text = Binding<NSAttributedString>(
            get: { NSAttributedString(text.wrappedValue.native) },
            set: { obj in text.wrappedValue = AttributedString(obj) }
        )
        self._selection = selection ?? IngnoredSelection().binding()
        
        self.options = options
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

extension AttributedString {
    /// Creates and returns the `String` equivalent of the receiver
    public var string: String {
        String(self.characters)
    }
}


extension AttributeContainer: @retroactive ExpressibleByDictionaryLiteral {
    public typealias Key   = NSAttributedString.Key
    public typealias Value = Any
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(elements, uniquingKeysWith: { old, new in new }))
    }
}

#Preview {
    @Previewable @State var text: String = "Hello World"
    VStack {
        FlairText(text: $text)
    }.padding().preferredColorScheme(.light)

}
