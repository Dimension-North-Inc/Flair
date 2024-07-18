//
//  Style.swift
//  Flair
//
//  Created by Mark Onyschuk on 2023-07-17.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import Foundation

/// A style comprised of a collection of keys and values.
///
/// Keys represent distinct style elements such as foreground or background colors, font weights,
/// border widths, or application specific display or behavioural settings. Values are their corresponding
/// values for the given style.
@dynamicMemberLookup
public struct Style {
    /// Registers a custom `StyleKeys` conforming type, allowing it
    /// to be read-from and written-to `Encodable` containers.
    ///
    /// When defiining custom style keys, be sure to register each early
    /// during application start-up, so that styles stored within `Codable`
    /// archives can be succesfully read.
    ///
    /// - Parameter keys: a list of `StyleKeys` conforming types
    public static func register(_ keys: any StyleKeys.Type...) {
        for key in keys {
            styleKeyTypes[key.name] = key
        }
    }
    
    /// Registers a custom `StyleKeys` conforming type, allowing it
    /// to be read-from and written-to `Encodable` containers.
    ///
    /// When defiining custom style keys, be sure to register each early
    /// during application start-up, so that styles stored within `Codable`
    /// archives can be succesfully read.
    ///
    /// - Parameter paths: a list of keypaths to `StyleKeys` conforming types declared by `Style.Key`
    public static func register(_ paths: KeyPath<Style.Keys, any StyleKeys.Type>...) {
        for path in paths {
            let key = Style.Keys()[keyPath: path]
            styleKeyTypes[key.name] = key
        }
    }
    
    fileprivate static var styleKeyTypes: [String: any StyleKeys.Type] = [
        // builtin font styles
        FontNameStyle.name:               FontNameStyle.self,
        FontSizeStyle.name:               FontSizeStyle.self,
        
        FontAngleStyle.name:              FontAngleStyle.self,
        FontWidthStyle.name:              FontWidthStyle.self,
        FontWeightStyle.name:             FontWeightStyle.self,
        
        // builtin text styles
        AlignmentStyle.name:              AlignmentStyle.self,
        
        LineSpacingStyle.name:            LineSpacingStyle.self,
        LineHeightMultipleStyle.name:     LineHeightMultipleStyle.self,
        
        ParagraphSpacingStyle.name:       ParagraphSpacingStyle.self,
        ParagraphSpacingBeforeStyle.name: ParagraphSpacingBeforeStyle.self,
        
        ForegroundColorStyle.name:        ForegroundColorStyle.self,
        BackgroundColorStyle.name:        BackgroundColorStyle.self,
        
        BoldStyle.name:                   BoldStyle.self,
        ItalicStyle.name:                 ItalicStyle.self,
        OutlineStyle.name:                OutlineStyle.self,
        UnderlineStyle.name:              UnderlineStyle.self,
        StrikethroughStyle.name:          StrikethroughStyle.self,
    ]
    
    // MARK: - Style Values
    /// a style property value
    public enum Value {
        case initial
        case inherit
        case override(Any)
    }
    
    private var values: [String: Value] = [:]
    
    // MARK: - Style Subscripts
    public subscript<T: StyleKeys>(key: T.Type) -> Value {
        get { values[T.name] ?? .inherit }
        set { values[T.name]  = newValue }
    }
    public subscript<T: StyleKeys>(key: KeyPath<Style.Keys, T.Type>) -> Value {
        get { values[T.name] ?? .inherit }
        set { values[T.name]  = newValue }
    }
    
    public subscript<T: StyleKeys>(value key: T.Type) -> T.Value {
        get {
            switch values[T.name] {
            case let .override(value)?:
                value as? T.Value ?? T.initial
            default:
                T.initial
            }
        }
        set { values[T.name] = .override(newValue) }
    }
    
    public subscript<T: StyleKeys>(value key: KeyPath<Style.Keys, T.Type>) -> T.Value {
        get {
            switch values[T.name] {
            case let .override(value)?:
                value as? T.Value ?? T.initial
            default:
                T.initial
            }
        }
        set { values[T.name] = .override(newValue) }
    }
    
    // MARK: - Dynamic Member Lookup
    public subscript<T: StyleKeys>(dynamicMember key: KeyPath<Style.Keys, T.Type>) -> T.Value {
        get {
            switch values[T.name] {
            case let .override(value)?:
                value as? T.Value ?? T.initial
            default:
                T.initial
            }
        }
        set { values[T.name] = .override(newValue) }
    }

    // MARK: - Style Combinations
    
    /// Creates a new `Style` by appending the contents of `style` to `self`.
    ///
    /// - Parameter style: a style to append
    /// - Returns: a new style
    public func appending(_ style: Self) -> Self {
        return Self.cascade(parent: self, child: style)
    }
    
    /// Creates a new `Style` by appending the contents of `styles` to `self`.
    ///
    /// - Parameter styles: a collection of styles to append
    /// - Returns: a new style
    public func appending(_ styles: some Collection<Style>) -> Self {
        styles.reduce(self) {
            parent, child in parent.appending(child)
        }
    }
    
    /// Creates a new `Style` by prepending the contents of `style` to `self`.
    ///
    /// - Parameter style: a style to prepend
    /// - Returns: a new style
    public func prepending(_ style: Self) -> Self {
        return Self.cascade(parent: style, child: self)
    }
    
    
    /// Creates a new `Style` by prepending the contents of `styles` to `self`.
    ///
    /// - Parameter styles: a collection of styles to prepend
    /// - Returns: a new style
    public func prepending(_ styles: some Collection<Style>) -> Self {
        styles.reduce(self) {
            parent, child in parent.prepending(child)
        }
    }
    
    /// Creates a new `Style` by cascading the contents of `styles`.
    ///
    /// - Parameter styles: a collection of styles to cascade
    /// - Returns: a new style
    public init(cascading styles: some Collection<Style>) {
        self = styles.reduce(Style()) {
            parent, child in parent.appending(child)
        }
    }
    
    private static func cascade(parent: Style, child: Style) -> Style {
        var cascade = Style()
        
        for key in Set(parent.values.keys).union(child.values.keys) {
            switch (parent.values[key], child.values[key]) {
            case let (_, .override(value)?):
                cascade.values[key] = .override(value)
            case let (.override(value)?, nil):
                cascade.values[key] = .override(value)
            default:
                break
            }
        }
        return cascade
    }
    
    // MARK: - Style Component Extraction

    /// Creates a new `Style` by extracting values for a list of style keys from `self`.
    /// - Parameter keys: a list of style keys whose values should be extracted into the new style
    /// - Returns: a new `Style`.
    public func extracting(_ keys: KeyPath<Style.Keys, any StyleKeys.Type>...) -> Style {
        let names = keys.map {
            key in Style.Keys()[keyPath: key].name
        }
        
        return Style(values: values.filter {
            key, value in names.contains(key)
        })
    }
    
    private init(values: [String: Value]) {
        self.values = values
    }
    
    public init() {}
    
    public init(conf: (inout Self) -> ()) {
        conf(&self)
    }
}

extension Style: Equatable {
    public static func == (lhs: Style, rhs: Style) -> Bool {
        
        let lkeys = lhs.values.keys.sorted()
        let rkeys = rhs.values.keys.sorted()

        if lkeys != rkeys {
            return false
        }
        
        for key in lkeys {
            guard 
                let codingValueType = Style.styleKeyTypes[key],
                let lhs = lhs.values[key], let rhs = rhs.values[key]
            else {
                return false
            }
            
            switch (lhs, rhs) {
            case let (.override(lhs), .override(rhs)):
                return codingValueType.valuesAreEqual(lhs, rhs)
            case (.initial, .initial):
                return true
            case (.inherit, .inherit):
                return true
                
            default:
                return false
            }
        }
        return true
    }
}

extension Style: Hashable {
    public func hash(into hasher: inout Hasher) {
        values.forEach {
            (key, value) in
            key.hash(into: &hasher)
            if let codingValueType = Style.styleKeyTypes[key] {
                codingValueType.hash(value: value, into: &hasher)
            } else {
                // TODO: log warning for unrecognized style key type
            }
        }
    }
    
}
extension Style: Codable {
    struct CodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        for key in values.keys {
            guard
                let value = values[key],
                let codingKey = CodingKeys(stringValue: key),
                let codingValueType = Style.styleKeyTypes[key]
            else {
                continue
            }

            var nestedContainer = container.nestedUnkeyedContainer(forKey: codingKey)

            switch value {
            case .inherit:
                break

            case .initial:
                try nestedContainer.encode("i")
            
            case let .override(overridden):
                try nestedContainer.encode("o")
                try codingValueType.encode(overridden, into: &nestedContainer)
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        for key in container.allKeys {
            guard
                let codingValueType = Style.styleKeyTypes[key.stringValue]
            else {
                continue
            }
            
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: key)
            
            switch try? nestedContainer.decode(String.self) {
            case "i":   values[key.stringValue] = .initial
            case "o":   values[key.stringValue] = .override(try codingValueType.decode(from: &nestedContainer))
            
            default:    break
            }
        }
    }
}

import CoreTransferable
import UniformTypeIdentifiers

extension Style: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .flair.style)
    }
}

extension UTType {
    /// a namespace for `Flair` specific types
    public enum flair {
        /// flair style content type - access UTType as `.flair.style`
        public static var style: UTType { UTType(importedAs: "com.ndimensionl.flair.style") }
    }
}
