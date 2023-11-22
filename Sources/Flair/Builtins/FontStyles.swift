//
//  FontStyles.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//


#if os(iOS)
import UIKit
public typealias FontDescriptor = UIFontDescriptor
public typealias FontTextStyle  = UIFont.TextStyle
#elseif os(macOS)
import Cocoa
public typealias FontDescriptor = NSFontDescriptor
public typealias FontTextStyle  = NSFont.TextStyle
#endif

import SwiftUI

extension FontDescriptor {
    public static func preferred(_ textStyle: FontTextStyle) -> FontDescriptor {
        FontDescriptor
        #if os(iOS)
        .preferredFontDescriptor(withTextStyle: textStyle)
        #elseif os(macOS)
        .preferredFontDescriptor(forTextStyle: textStyle)
        #endif
    }
    
    subscript(key: FontDescriptor.AttributeName) -> Any? {
        self.object(forKey: key)
    }
    subscript<T>(key: FontDescriptor.AttributeName) -> T? {
        self.object(forKey: key) as? T
    }
}

extension Font {
    public struct Descriptor: Hashable, CustomStringConvertible {
        public let family: String
        public let face: String
        public let size: CGFloat
        
        var descriptor: FontDescriptor {
            FontDescriptor(fontAttributes: [
                .family: family,
                .face: face,
                .size: size
            ])
        }

        public var postscriptName: String {
            #if os(iOS)
            descriptor.postscriptName
            #elseif os(macOS)
            descriptor.postscriptName ?? "Helvetica"
            #endif
        }

        public var symbolicTraits: FontDescriptor.SymbolicTraits {
            descriptor.symbolicTraits
        }
        
        public var faces: [Descriptor] {
            descriptor
                .matchingFontDescriptors(withMandatoryKeys: [.family, .size])
                .map(Descriptor.init)
        }
        
        public func substituting(family: String, face: String, size: CGFloat) -> Self {
            self.withFamily(family)
                .withFace(face)
                .withSize(size)
        }
        
        public func withFamily(_ family: String) -> Self {
            Self(descriptor: descriptor.withFamily(family))
        }
        public func withFace(_ face: String) -> Self {
            Self(descriptor: descriptor.withFace(face))
        }
        public func withSize(_ size: CGFloat) -> Self {
            Self(descriptor: descriptor.withSize(size))
        }
        
        public func withSymbolicTraits(_ traits: FontDescriptor.SymbolicTraits) -> Self {
            let descriptor = FontDescriptor(fontAttributes: [
                .family: family,
                .size: size
            ])
            
            #if os(iOS)
            return Self(descriptor: descriptor.withSymbolicTraits(traits) ?? descriptor)
            #elseif os(macOS)
            return Self(descriptor: descriptor.withSymbolicTraits(traits))
            #endif
        }
        
        init(descriptor: FontDescriptor) {
            family          = descriptor[.family]       ?? "Helvetica"
            face            = descriptor[.face]         ?? "Regular"
            size            = descriptor[.size]         ?? 13.0
        }

        public init() {
            self.init(descriptor: FontDescriptor())
        }
        
        public init(_ textStyle: FontTextStyle) {
            self.init(descriptor: .preferred(textStyle))
        }

        public var description: String {
            "\(family) \(face), \(size) pt."
        }
    }
    
    public static func descriptor(_ descriptor: Descriptor) -> Font {
        .custom(descriptor.postscriptName, size: descriptor.size)
    }
}

private let BASE_DESCRIPTOR = Font.Descriptor()

extension Style {
    public var font: Font {
        var descriptor = BASE_DESCRIPTOR
            .substituting(
                family: self.fontFamily,
                face:   self.fontFace,
                size:   self.fontSize
            )

        var traits: FontDescriptor.SymbolicTraits = []
        #if os(iOS)
        if self.bold { traits.formUnion(.traitBold) }
        if self.italic { traits.formUnion(.traitItalic) }
        #elseif os(macOS)
        if self.bold { traits.formUnion(.bold) }
        if self.italic { traits.formUnion(.italic) }
        #endif
        
        if !traits.isEmpty {
            descriptor = descriptor.withSymbolicTraits(traits)
        }
        
        return Font.descriptor(descriptor)
    }
}

extension Style.Key {
    public struct BoldStyle: StyleKeys {
        public static var name      = "flair.bold"
        public static var initial   = false
    }
    public struct ItalicStyle: StyleKeys {
        public static var name      = "flair.italic"
        public static var initial   = false
    }
    public struct OutlineStyle: StyleKeys {
        public static var name      = "flair.outline"
        public static var initial   = false
    }
    public struct UnderlineStyle: StyleKeys {
        public static var name      = "flair.underline"
        public static var initial   = false
    }
    public struct StrikethroughStyle: StyleKeys {
        public static var name      = "flair.strikethrough"
        public static var initial   = false
    }

    public struct FontSizeStyle: StyleKeys {
        public static var name      = "flair.font-size"
        public static var initial   = BASE_DESCRIPTOR.size
    }
    public struct FontFaceStyle: StyleKeys {
        public static var name      = "flair.font-face"
        public static var initial   = BASE_DESCRIPTOR.face
    }
    public struct FontFamilyStyle: StyleKeys {
        public static var name      = "flair.font-family"
        public static var initial   = BASE_DESCRIPTOR.family
    }

    public var bold: BoldStyle.Type {
        BoldStyle.self
    }
    public var italic: ItalicStyle.Type {
        ItalicStyle.self
    }
    public var outline: OutlineStyle.Type {
        OutlineStyle.self
    }
    public var underline: UnderlineStyle.Type {
        UnderlineStyle.self
    }
    public var strikethrough: StrikethroughStyle.Type {
        StrikethroughStyle.self
    }
    
    public var fontSize: FontSizeStyle.Type {
        FontSizeStyle.self
    }
    
    public var fontFace: FontFaceStyle.Type {
        FontFaceStyle.self
    }
    public var fontFamily: FontFamilyStyle.Type {
        FontFamilyStyle.self
    }
}
