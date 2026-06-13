//
//  Style.swift
//  Flair
//
//  Created by Mark Onyschuk on 2023-07-17.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import Foundation
import os

/// A style comprised of a collection of keys and values.
///
/// Keys represent distinct style elements such as foreground or background colors, font weights,
/// border widths, or application specific display or behavioural settings. Values are their corresponding
/// values for the given style.
@dynamicMemberLookup
public struct Style {

    // MARK: - Type Aliases

    /// A style property value, backed by CascadingDictionary.Cascade.
    public typealias Value<T> = CascadingDictionary<String, T>.Cascade<T>

    // MARK: - Registry

    /// registers a custom `StyleKeys` conforming type, allowing it
    /// to be read-from and written-to `Encodable` containers.
    ///
    /// When defiining custom style keys, be sure to register each early
    /// during application start-up, so that styles stored within `Codable`
    /// archives can be succesfully read.
    ///
    /// - Parameter keys: a list of `StyleKeys` conforming types
    public static func register(_ keys: any StyleKeys.Type...) {
        for key in keys {
            registry.withLock { $0[key.name] = key }
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
            registry.withLock { $0[key.name] = key }
        }
    }

    /// Thread-safe registry of style-key types, keyed by coding `name`.
    private static let registry = OSAllocatedUnfairLock<[String: any StyleKeys.Type]>(initialState: [
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
    ])

    /// Looks up the registered key type for a coding `name`, if any.
    fileprivate static func styleKeyType(_ name: String) -> (any StyleKeys.Type)? {
        registry.withLock { $0[name] }
    }

    // MARK: - Storage

    private var values = CascadingDictionary<String, Any>()

    // MARK: - Style Subscripts

    /// Accesses the raw cascade value for a given style key.
    public subscript<T: StyleKeys>(key: T.Type) -> Value<Any> {
        get { values[T.name] }
        set { values[T.name] = newValue }
    }

    /// Accesses the raw cascade value for a given style key.
    public subscript<T: StyleKeys>(key: KeyPath<Style.Keys, T.Type>) -> Value<Any> {
        get { values[T.name] }
        set { values[T.name] = newValue }
    }

    /// Accesses the typed value for a given style key.
    public subscript<T: StyleKeys>(value key: T.Type) -> T.Value {
        get {
            switch values[T.name] {
            case .override(let any):
                return any as? T.Value ?? T.initial
            default:
                return T.initial
            }
        }
        set { values[T.name] = .override(newValue) }
    }

    /// Accesses the typed value for a given style key.
    public subscript<T: StyleKeys>(value key: KeyPath<Style.Keys, T.Type>) -> T.Value {
        get {
            switch values[T.name] {
            case .override(let any):
                return any as? T.Value ?? T.initial
            default:
                return T.initial
            }
        }
        set { values[T.name] = .override(newValue) }
    }

    // MARK: - Dynamic Member Lookup

    /// Accesses the typed value for a given style key via dynamic member lookup.
    public subscript<T: StyleKeys>(dynamicMember key: KeyPath<Style.Keys, T.Type>) -> T.Value {
        get { self[value: key] }
        set { self[value: key] = newValue }
    }

    // MARK: - Style Combinations

    /// Creates a new `Style` by appending the contents of `style` to `self`.
    ///
    /// - Parameter style: a style to append
    /// - Returns: a new style
    public func appending(_ style: Self) -> Self {
        var result = Style()
        result.values = self.values.appending(style.values)
        return result
    }

    /// Creates a new `Style` by appending the contents of `styles` to `self`.
    ///
    /// - Parameter styles: a collection of styles to append
    /// - Returns: a new style
    public func appending(_ styles: some Collection<Style>) -> Self {
        styles.reduce(self) { parent, child in parent.appending(child) }
    }

    /// Creates a new `Style` by prepending the contents of `style` to `self`.
    ///
    /// - Parameter style: a style to prepend
    /// - Returns: a new style
    public func prepending(_ style: Self) -> Self {
        var result = Style()
        result.values = self.values.prepending(style.values)
        return result
    }

    /// Creates a new `Style` by prepending the contents of `styles` to `self`.
    ///
    /// - Parameter styles: a collection of styles to prepend
    /// - Returns: a new style
    public func prepending(_ styles: some Collection<Style>) -> Self {
        styles.reduce(self) { parent, child in parent.prepending(child) }
    }

    /// Creates a new `Style` by cascading the contents of `styles`.
    ///
    /// - Parameter styles: a collection of styles to cascade
    /// - Returns: a new style
    public init(cascading styles: some Collection<Style>) {
        self.values = CascadingDictionary(cascading: styles.map(\.values))
    }

    public init(cascading styles: Style...) {
        self.init(cascading: styles)
    }

    // MARK: - Style Component Extraction

    /// Creates a new `Style` by extracting values for a list of style keys from `self`.
    /// - Parameter keys: a list of keypaths to style keys whose values should be extracted
    /// - Returns: a new `Style`.
    public func extracting(_ keys: KeyPath<Style.Keys, any StyleKeys.Type>...) -> Style {
        let names = keys.map { Style.Keys()[keyPath: $0].name }
        var result = Style()
        result.values = self.values.extracting(names)
        return result
    }

    /// Creates a new `Style` by removing values which exist and are equivalent to those found in `style`.
    /// - Parameter style: another style
    /// - Returns: a new style.
    public func subtracting(_ style: Style) -> Style {
        var result = Style()

        for key in self.values.keys {
            guard let keyType = Style.styleKeyType(key) else { continue }

            let selfValue = self[value: keyType]
            let otherValue = style[value: keyType]

            let equal = keyType.valuesAreEqual(selfValue, otherValue)
            if !equal {
                result.values[key] = self.values[key]
            }
        }

        return result
    }

    /// Creates a new `Style` by removing values which exist and are equivalent to those found in `style`.
    /// Uses custom equality function for value comparison.
    /// - Parameters:
    ///   - style: another style
    ///   - equals: a function that returns `true` if two values are equal
    /// - Returns: a new style.
    public func subtracting(_ style: Style, equals: (Any, Any) -> Bool) -> Style {
        var result = Style()
        result.values = self.values.subtracting(style.values, equals: equals)
        return result
    }

    // MARK: - Initializers

    public init() {}

    public init(conf: (inout Self) -> ()) {
        conf(&self)
    }
}

// MARK: - Equatable

extension Style: Equatable {
    public static func == (lhs: Style, rhs: Style) -> Bool {
        let lkeys = lhs.values.keys.sorted()
        let rkeys = rhs.values.keys.sorted()

        if lkeys != rkeys {
            return false
        }

        for key in lkeys {
            guard
                let codingValueType = Style.styleKeyType(key)
            else {
                return false
            }

            let lhsCascade = lhs.values[key]
            let rhsCascade = rhs.values[key]

            switch (lhsCascade, rhsCascade) {
            case (.override(let l), .override(let r)):
                return codingValueType.valuesAreEqual(l, r)
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

// MARK: - Hashable

extension Style: Hashable {
    public func hash(into hasher: inout Hasher) {
        for key in values.keys.sorted() {
            key.hash(into: &hasher)
            if let codingValueType = Style.styleKeyType(key) {
                switch values[key] {
                case .override(let any):
                    codingValueType.hash(value: any, into: &hasher)
                case .initial, .inherit:
                    break
                }
            }
        }
    }
}

// MARK: - Codable

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
                let codingKey = CodingKeys(stringValue: key),
                let codingValueType = Style.styleKeyType(key)
            else {
                continue
            }

            var nestedContainer = container.nestedUnkeyedContainer(forKey: codingKey)

            switch values[key] {
            case .inherit:
                break

            case .initial:
                try nestedContainer.encode("i")

            case .override(let any):
                try nestedContainer.encode("o")
                try codingValueType.encode(any, into: &nestedContainer)
            }
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        for key in container.allKeys {
            guard
                let codingValueType = Style.styleKeyType(key.stringValue)
            else {
                continue
            }

            var nestedContainer = try container.nestedUnkeyedContainer(forKey: key)

            switch try? nestedContainer.decode(String.self) {
            case "i":
                values[key.stringValue] = .initial
            case "o":
                values[key.stringValue] = .override(try codingValueType.decode(from: &nestedContainer))
            default:
                break
            }
        }
    }
}

// MARK: - Sendable
//
// Storage is `[String: Any]`, so the compiler cannot prove Sendable, but every
// value is a `StyleKeys.Value` — constrained to `Sendable` value types.
extension Style: @unchecked Sendable {}

// MARK: - Transferable

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
