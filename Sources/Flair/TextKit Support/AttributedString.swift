//
//  AttributedString.swift
//  Flair
//
//  Created by Mark Onyschuk on 02/24/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Foundation

extension FontRef: @unchecked Sendable {}

extension NSParagraphStyle: @unchecked Sendable {}
extension NSMutableParagraphStyle: @unchecked Sendable {}


extension AttributeScopes {
    public struct FlairAttributeScopes: AttributeScope  {
        public let paragraphStyle: ParagraphStyleAttribute
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

public struct ParagraphStyleAttribute: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
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
        var desc: FontDescriptor = FontDescriptor(style: self.fontName)

        desc = desc
            .replacing(weight:   self.fontWeight)
            .replacing(width:    self.fontWidth)
            .replacing(angle:    self.fontAngle)

        if !self.fontName.isDynamic {
            desc = desc.replacing(size: self.fontSize)
        }

        return desc
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

extension AttributedString {
    /// Returns a new attributed string whose flair attributes are transformed to either AppKit or UIKit  attributed string attributes
    public var native: Self {
        var copy = self

        // apply paragraph style
        if let style = self.flair.paragraphStyle {
            copy.paragraphStyle = style.paragraph
        }
        
        // apply other character styles
        for run in self.runs {
            let range = run.range
            let attributes = run.attributes
            
            // this is our blended style
            let style = Style(cascading: [attributes.flair.paragraphStyle, attributes.flair.characterStyle].compactMap { $0 })
            
            // base font
            var descriptor = style.fontDescriptor
            
            // bold modifier
            if style.bold, let weight = descriptor.weight {
                descriptor = descriptor.replacing(weight: weight.next)
            }
            
            // italic modifier
            if style.italic, let angle = descriptor.angle {
                descriptor = descriptor.replacing(angle: angle.next)
            }
            
            copy[range].font = descriptor.font
            
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
        if let style = self.flair.paragraphStyle {
            copy.paragraphStyle = style.paragraph
        }
        
        // apply other character styles
        for run in self.runs {
            let range = run.range
            let attributes = run.attributes
            
            // this is our blended style
            let style = Style(cascading: [attributes.flair.paragraphStyle, attributes.flair.characterStyle].compactMap { $0 })
            
            copy[range].font = style.font
        }
        return copy
    }
}
