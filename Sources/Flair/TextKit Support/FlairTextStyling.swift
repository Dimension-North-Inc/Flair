//
//  FlairTextStyling.swift
//  Flair
//
//  Created by Mark Onyschuk on 02/24/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Foundation

extension FontRef: @unchecked @retroactive Sendable {}

extension NSParagraphStyle: @unchecked @retroactive Sendable {}
extension NSMutableParagraphStyle: @unchecked @retroactive Sendable {}

extension AttributeScopes {
    public struct FlairAttributeScopes: AttributeScope  {
        public let documentStyle: DocumentStyleAttribute
        public let characterStyle: CharacterStyleAttribute
        
        #if os(iOS)
        public let uikit: UIKitAttributes
        #elseif os(macOS)
        public let appkit: AppKitAttributes
        #endif
        public let swiftUI: SwiftUIAttributes
    }
    
    public var flair: FlairAttributeScopes.Type { FlairAttributeScopes.self }
}

public extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(
        dynamicMember keyPath: KeyPath<AttributeScopes.FlairAttributeScopes, T>
    ) -> T {
        return self[T.self]
    }
}

public struct DocumentStyleAttribute: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
    public typealias Value = Style
    public static var name: String = "flair.paragraphStyle"
}

public struct CharacterStyleAttribute: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
    public typealias Value = Style
    public static var name: String = "flair.characterStyle"
}

extension Style {
    public var font: FontRef? {
        fontDescriptor.font
    }

    public var fontDescriptor: FontDescriptor {
        get {
            var desc: FontDescriptor = FontDescriptor(style: self.fontName)
            
            if !self.fontName.isDynamic {
                desc = desc.replacing(size: self.fontSize)
            }
            
            desc = desc
                .replacing(
                    weight: self.bold
                    ? self.fontWeight.next : self.fontWeight
                )
                .replacing(
                    width: self.fontWidth
                )
                .replacing(
                    angle: self.italic
                    ? self.fontAngle.next : self.fontAngle
                )
            
            return desc
        }
        set {
            // TODO:
        }
    }
    
    public var paragraph: NSParagraphStyle {
        let value = NSMutableParagraphStyle()
                
        switch self.textAlignment {
        case .leading:   value.alignment = .left
        case .trailing:  value.alignment = .right
        case .centered:  value.alignment = .center
        
        default:         value.alignment = .justified
        }
        
        value.lineSpacing = self.lineSpacing
        value.lineHeightMultiple = self.lineHeightMultiple

        value.paragraphSpacing = self.paragraphSpacing
        value.paragraphSpacingBefore = self.paragraphSpacingBefore
        
        return value
    }
}

extension NSRange {
    public func `in`(_ string: String) -> Range<String.Index>? {
        Range(self, in: string)
    }
    public func `in`(_ string: AttributedString) -> Range<AttributedString.Index>? {
        Range(self, in: string)
    }
}

extension AttributedString {
    public init(_ string: String, style: Style) {
        self.init(string)
        self.documentStyle = style
    }
    public init(_ substring: Substring, style: Style) {
        self.init(substring)
        self.documentStyle = style
    }

    public init<S>(_ elements: S, style: Style) where S : Sequence, S.Element == Character {
        self.init(elements)
        self.documentStyle = style
    }

    public subscript(range: NSRange) -> AttributedSubstring? {
        range.in(self).map {
            range in self[range]
        }
    }
    
    public func styles(in selection: [NSRange]) -> [Style] {
        let doc = self.documentStyle ?? Style()
        
        return selection
            .compactMap {
                // extract substrings
                range in self[range]
            }
            .flatMap {
                // extract all runs from substrings
                substring in substring.runs
            }
            .compactMap {
                // extract character styles from each run
                run in self[run.range].characterStyle
            }
            .map {
                // combine each character style with the document style
                style in Style(cascading: [doc, style])
            }
    }
    
    public mutating func setStyle(_ style: Style, _ selection: [NSRange]) {
        let style = style.subtracting(
            self.documentStyle ?? Style()
        )
        for range in selection {
            guard let r = range.in(self) else {
                continue
            }
            self[r].characterStyle = style
        }
    }
    
    /// Returns a new attributed string whose flair attributes are transformed to either AppKit or UIKit  attributed string attributes
    public var native: Self {
        var copy = self

        // apply document style
        if let style = self.flair.documentStyle {
            copy.paragraphStyle = style.paragraph
        }
        
        // apply other character styles
        for run in self.runs {
            let range = run.range
            let attributes = run.attributes
            
            // this is our blended style
            let style = Style(cascading: [attributes.flair.documentStyle, attributes.flair.characterStyle].compactMap { $0 })
            
            copy[range].font = style.font
            
            // foreground, background colors
            copy[range].foregroundColor     = style.textColor.ref
            copy[range].backgroundColor     = style.textBackgroundColor.ref
            
            // underline style, color
            copy[range].underlineStyle      = style.underline?.style
            copy[range].underlineColor      = style.underline?.color?.ref
            
            // strikethrough style, color
            copy[range].strikethroughStyle  = style.strikethrough?.style
            copy[range].strikethroughColor  = style.strikethrough?.color?.ref
        }
        
        return copy
    }
    
    /// Returns a new attributed string whose flair attributes are transformed to SwiftUI attributed string attributes
    public var swiftui: Self {
        var copy = self

        // apply paragraph style
        if let style = self.flair.documentStyle {
            copy.paragraphStyle = style.paragraph
        }
        
        // apply other character styles
        for run in self.runs {
            let range = run.range
            let attributes = run.attributes
            
            // this is our blended style
            let style = Style(cascading: [attributes.flair.documentStyle, attributes.flair.characterStyle].compactMap { $0 })
            
            copy[range].font = style.font
        }
        return copy
    }
}
