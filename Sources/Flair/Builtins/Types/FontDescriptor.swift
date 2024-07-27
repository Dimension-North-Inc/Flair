//
//  FontDescriptor.swift
//  Flair
//
//  Created by Mark Onyschuk on 02/17/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Foundation

#if os(iOS)
public typealias FontRef = UIFont
public typealias FontDescriptorRef = UIFontDescriptor
#elseif os(macOS)
public typealias FontRef = NSFont
public typealias FontDescriptorRef = NSFontDescriptor
#endif

public typealias Traits = [FontDescriptorRef.TraitKey: Any]

/// A font description.
public struct FontDescriptor {
    private var impl: FontDescriptorRef
    private init(impl: FontDescriptorRef) {
        self.impl = impl
    }
    
    public var font: FontRef? {
        #if os(iOS)
        FontRef(descriptor: ref, size: 0)
        #elseif os(macOS)
        if let size {
            FontRef(descriptor: ref, size: size)
        } else {
            FontRef(descriptor: ref, textTransform: .identity)
        }
        #endif
    }
    
    public init(font: FontRef) {
        impl = font.fontDescriptor
    }
    
    public init(style: FontName) {
        #if os(iOS)
        let dynamic = {FontDescriptorRef.preferredFontDescriptor(withTextStyle: $0)}
        #elseif os(macOS)
        let dynamic = {FontDescriptorRef.preferredFontDescriptor(forTextStyle: $0)}
        #endif
        
        self.impl = switch style {
        case .title1:       dynamic(.title1)
        case .title2:       dynamic(.title2)
        case .title3:       dynamic(.title3)
        
        case .largeTitle:   dynamic(.largeTitle)
        
        case .headline:     dynamic(.headline)
        case .subheadline:  dynamic(.subheadline)
            
        case .body:         dynamic(.body)
            
        case .callout:      dynamic(.callout)
        case .footnote:     dynamic(.footnote)
            
        case .caption1:     dynamic(.caption1)
        case .caption2:     dynamic(.caption2)
            
        case let .named(name):
            .init().withFamily(name)
        }
    }
    
    public var ref: FontDescriptorRef {
        impl
    }
    
    public var family: String? {
        impl.object(forKey: .family) as? String
    }
    
    public var face: String? {
        impl.object(forKey: .face) as? String
    }
    
    public var size: CGFloat? {
        impl.object(forKey: .size) as? CGFloat
    }

    public var displayName: String {
        func toPoints(_ value: CGFloat) -> String {
            Measurement(value: Double(value), unit: UnitLength.points).description
        }
        return [family, face, size.map(toPoints)].compactMap({ part in part }).joined(separator: ", ")
    }
    
    public var traits: Traits? {
        impl.object(forKey: .traits) as? Traits
    }
    
    public var angle: FontAngle? {
        (traits?[.slant] as? CGFloat).map(FontAngle.init)
    }

    public var width: FontWidth? {
        (traits?[.width] as? CGFloat).map(FontWidth.init)
    }
    
    public var weight: FontWeight? {
        (traits?[.weight] as? CGFloat).map(FontWeight.init)
    }
        
    private func resolvedImpl() -> FontDescriptorRef {
        guard let family, let face, let size else {
            return impl
        }
        
        let match = FontDescriptorRef()
            .withFamily(family).withFace(face).withSize(size)
        
        return match
    }
    
    public func familyMembers(resized: CGFloat? = nil) -> [Self] {
        var match = resolvedImpl()

        if let family   { match = match.withFamily(family) }
        if let size     { match = match.withSize(resized ?? size) }
        
        return match.matchingFontDescriptors(withMandatoryKeys: [.family, .face, .size, .name, .visibleName]).map(Self.init)
    }
    
    public func matchingFaces() -> Set<String> {
        Set(familyMembers().compactMap(\.face))
    }
    
    public func replacing(family value: String) -> Self {
        return Self(impl: impl.withFamily(value))
    }
    
    public func replacing(size value: CGFloat) -> Self {
        return Self(impl: impl.withSize(value))
    }

    public func replacing(weight value: FontWeight) -> Self {
        let options = familyMembers(resized: size)
        let nearest = _nearest(to: value, in: options.compactMap(\.weight)) ?? value

        var traits = impl.fontAttributes[.traits] as? [FontDescriptorRef.TraitKey: Any] ?? [:]
        
        traits[.weight] = nearest.rawValue
        
        return Self(impl: impl.addingAttributes([.traits: traits]))
    }
    
    public func replacing(width value: FontWidth) -> Self {
        let options = familyMembers(resized: size)
        let nearest = _nearest(to: value, in: options.compactMap(\.width)) ?? value

        var traits = impl.fontAttributes[.traits] as? [FontDescriptorRef.TraitKey: Any] ?? [:]
        
        traits[.width] = nearest.rawValue
        
        return Self(impl: impl.addingAttributes([.traits: traits]))
    }
    
    public func replacing(angle value: FontAngle) -> Self {
        let options = familyMembers(resized: size)
        let nearest = _nearest(to: value, in: options.compactMap(\.angle)) ?? value

        var traits = impl.fontAttributes[.traits] as? [FontDescriptorRef.TraitKey: Any] ?? [:]
        
        traits[.slant] = nearest.rawValue
        
        return Self(impl: impl.addingAttributes([.traits: traits]))
    }
}

extension FontDescriptor {
    public static func families() -> [FontDescriptor] {
        var familyNames: Set<String> = []
        var descriptors: [(family: String, descriptor: FontDescriptor)] = []

        for desc in FontDescriptorRef().matchingFontDescriptors(withMandatoryKeys: [.family]) {
            guard let family: String = desc[.family] else {
                continue
            }
            
            if !familyNames.contains(family) {
                descriptors.append((family: family, descriptor: FontDescriptor(impl: desc)))
                familyNames.insert(family)
            }
        }

        return descriptors
            .sorted { lhs, rhs in lhs.family < rhs.family }
            .map    { elt in elt.descriptor }
    }
}

extension FontDescriptorRef {
    subscript<T>(key: FontDescriptorRef.AttributeName) -> T? {
        self.object(forKey: key) as? T
    }
}

/// Standard font weights
public struct FontWeight: Codable, Hashable, RawRepresentable, CaseIterable, CustomStringConvertible {
    public var rawValue: CGFloat
    public init(rawValue: CGFloat) {
        self.rawValue = rawValue
    }
    
    public static let ultraLight    = instance(.ultraLight)
    public static let thin          = instance(.thin)
    public static let light         = instance(.light)
    public static let regular       = instance(.regular)
    public static let medium        = instance(.medium)
    public static let semibold      = instance(.semibold)
    public static let bold          = instance(.bold)
    public static let heavy         = instance(.heavy)
    public static let black         = instance(.black)
    
    private static func instance(_ other: FontRef.Weight) -> Self {
        Self(rawValue: other.rawValue)
    }
    
    public static var allCases: [FontWeight]  = [
        .ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black
    ]
        
    public var description: String {
        switch self {
        case .ultraLight:   "ultralight"
        case .thin:         "thin"
        case .light:        "light"
        case .regular:      "regular"
        case .medium:       "medium"
        case .semibold:     "semibold"
        case .bold:         "bold"
        case .heavy:        "heavy"
        case .black:        "black"
            
        default:            "custom(\(rawValue))"
        }
    }
    
    public var nearest: Self {
        _nearest(
            to: self, 
            in: .ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black
        )
    }

    /// the next greatest weight, relative to `self`
    ///
    /// This value should be used for font weight when it is notionally `bolded`.
    public var next: Self {
        let cases = Self.allCases
        
        if let index = cases.firstIndex(of: nearest) {
            return cases.suffix(from: cases.index(after: index)).first ?? self
        } else {
            return self
        }
    }
}

/// Standard font widths
public struct FontWidth: Codable, Hashable, RawRepresentable, CaseIterable, CustomStringConvertible {
    public var rawValue: CGFloat
    public init(rawValue: CGFloat) {
        self.rawValue = rawValue
    }
    
    public static let compressed = instance(.compressed)
    public static let condensed  = instance(.condensed)
    public static let standard   = instance(.standard)
    public static let expanded   = instance(.expanded)

    private static func instance(_ other: FontRef.Width) -> Self {
        Self(rawValue: other.rawValue)
    }
    
    public static var allCases: [FontWidth] = [
        .compressed, .condensed, .standard, .expanded
    ]

    public var description: String {
        switch self {
        case .compressed:   "compressed"
        case .condensed:    "condensed"
        case .standard:     "standard"
        case .expanded:     "expanded"
            
        default:            "custom(\(rawValue))"
        }
    }
}

/// Standard font angles
public struct FontAngle: Codable, Hashable, RawRepresentable, CaseIterable, CustomStringConvertible {
    public var rawValue: CGFloat
    public init(rawValue: CGFloat) {
        self.rawValue = rawValue
    }
    
    public static let italic    = Self(rawValue:  0.2)
    public static let standard  = Self(rawValue:  0.0)
    public static let backslant = Self(rawValue: -0.2)

    public static var allCases: [FontAngle] {[
        .italic, .standard, .backslant
    ]}
    
    public var description: String {
        switch self {
        case .italic:    "italic"
        case .standard:  "standard"
        case .backslant: "backslant"
            
        default:         "custom(\(rawValue))"
        }
    }
    
    public var nearest: Self {
        _nearest(
            to: self, 
            in: .italic, .standard, .backslant
        )
    }
    
    /// the next greatest angle, relative to `self`
    ///
    /// This value should be used for font angle when it is notionally `italicized`.
    public var next: Self {
        let cases = Self.allCases
        
        if let index = cases.firstIndex(of: nearest) {
            return cases.suffix(from: cases.index(after: index)).first ?? self
        } else {
            return self
        }
    }
}

/// Returns the nearest matching member of `values`, to `v`, based on
/// `RawRepresentable.RawValue`s.
///
/// - Parameters:
///   - v: an instance of `Value`
///   - values: one or more instances of `Value`
/// - Returns: a member of `values` whose rawValue most closely matches that of `v`.
///
private func _nearest<Value>(
    to v: Value, in values: Value...
) -> Value! where Value: RawRepresentable, Value.RawValue: SignedNumeric {
    return values
        .map    { elt      in (element: elt, distance: (v.rawValue - elt.rawValue).magnitude) }
        .sorted { lhs, rhs in lhs.distance < rhs.distance }
        .first!
        .element
}
private func _nearest<Value>(
    to v: Value, in values: some Collection<Value>
) -> Value! where Value: RawRepresentable, Value.RawValue: SignedNumeric {
    return values
        .map    { elt      in (element: elt, distance: (v.rawValue - elt.rawValue).magnitude) }
        .sorted { lhs, rhs in lhs.distance < rhs.distance }
        .first!
        .element
}


/// Standard font styles
public enum FontName: Codable, Hashable, CaseIterable, CustomStringConvertible {
    case title1
    case title2
    case title3

    case largeTitle

    case headline
    case subheadline

    case body

    case callout
    case footnote

    case caption1
    case caption2
        
    case named(String)
    
    public var isDynamic: Bool {
        switch self {
        case .named:    false
        default:        true
        }
    }
    
    public var isNamed: Bool {
        switch self {
        case .named:    true
        default:        false
        }
    }
    
    public static var allCases: [FontName] {
        [
            .title1,
            .title2,
            .title3,
            .largeTitle,
            .headline,
            .subheadline,
            .body,
            .callout,
            .footnote,
            .caption1,
            .caption2
        ]
        + FontDescriptor.families().compactMap(\.family).map {
            .named($0)
        }
    }
    
    public var description: String {
        switch self {
        case .largeTitle:  "large title"
            
        case .title1:      "title 1"
        case .title2:      "title 2"
        case .title3:      "title 3"
            
        case .headline:    "headline"
        case .subheadline: "subheadline"
            
        case .body:        "body"
        
        case .callout:     "callout"
        case .footnote:    "footnote"
        
        case .caption1:    "caption 1"
        case .caption2:    "caption 2"
            
        case let .named(name):
            name
        }
    }
}

// TODO: move this somewhere else?

extension View {
    @ViewBuilder
    public func fontAngle(_ a: FontAngle) -> some View {
        self.italic(a.rawValue != 0)
    }

    @ViewBuilder
    public func fontName(_ s: FontName) -> some View {
        self.font(FontDescriptor(style: s).font.map(Font.init))
    }

    @ViewBuilder
    public func fontWeight(_ w: FontWeight) -> some View {
        let weight: Font.Weight? = switch w {
        case .ultraLight:    .ultraLight
        case .thin:          .thin
        case .light:         .light
        case .regular:       .regular
        case .medium:        .medium
        case .semibold:      .semibold
        case .bold:          .bold
        case .heavy:         .heavy
        case .black:         .black
        
        default:             nil
        }
        
        self.fontWeight(weight)
    }
    
    @ViewBuilder
    public func fontWidth(_ w: FontWidth) -> some View {
        let width: Font.Width? = switch w {
        case .compressed:   .compressed
        case .condensed:    .condensed
        case .standard:     .standard
        case .expanded:     .expanded
            
        default:            nil
        }
        
        self.fontWidth(width)
    }
    
}
