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
    public static func register(_ paths: KeyPath<Style.Key, any StyleKeys.Type>...) {
        for path in paths {
            let key = Style.Key()[keyPath: path]
            styleKeyTypes[key.name] = key
        }
    }
    
    fileprivate static var styleKeyTypes: [String: any StyleKeys.Type] = [
        // builtin text styles
        Style.Key.AlignmentStyle.name:               Style.Key.AlignmentStyle.self,
        
        Style.Key.LineSpacingStyle.name:             Style.Key.LineSpacingStyle.self,
        Style.Key.LineHeightMultipleStyle.name:      Style.Key.LineHeightMultipleStyle.self,

        Style.Key.ParagraphSpacingStyle.name:        Style.Key.ParagraphSpacingStyle.self,
        Style.Key.ParagraphSpacingBeforeStyle.name:  Style.Key.ParagraphSpacingBeforeStyle.self,

        Style.Key.ForegroundColorStyle.name:         Style.Key.ForegroundColorStyle.self,
        Style.Key.BackgroundColorStyle.name:         Style.Key.BackgroundColorStyle.self,
        
        // builtin font styles
        Style.Key.BoldStyle.name:                    Style.Key.BoldStyle.self,
        Style.Key.ItalicStyle.name:                  Style.Key.ItalicStyle.self,
        Style.Key.UnderlineStyle.name:               Style.Key.UnderlineStyle.self,
        Style.Key.StrikethroughStyle.name:           Style.Key.StrikethroughStyle.self,
        
        Style.Key.FontSizeStyle.name:                Style.Key.FontSizeStyle.self,
        Style.Key.FontFaceStyle.name:                Style.Key.FontFaceStyle.self,
        Style.Key.FontFamilyStyle.name:              Style.Key.FontFamilyStyle.self,
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
    public subscript<T: StyleKeys>(value key: T.Type) -> Value {
        get { values[T.name] ?? .inherit }
        set { values[T.name]  = newValue }
    }
    public subscript<T: StyleKeys>(value key: KeyPath<Style.Key, T.Type>) -> Value {
        get { values[T.name] ?? .inherit }
        set { values[T.name]  = newValue }
    }

    // MARK: - Dynamic Member Lookup
    public subscript<T: StyleKeys>(dynamicMember key: KeyPath<Style.Key, T.Type>) -> T.Value {
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
    public func style(appending style: Self) -> Self {
        var cascading = Style()
        
        for key in Set(values.keys).union(style.values.keys) {
            switch (values[key], style.values[key]) {
            case let (_, .override(value)?):
                cascading.values[key] = .override(value)
            case let (.override(value)?, nil):
                cascading.values[key] = .override(value)
            default:
                break
            }
        }
        
        return cascading
    }
    
    
    /// Creates a new `Style` by appending the contents of `styles` to `self`.
    ///
    /// - Parameter styles: a collection of styles to append
    /// - Returns: a new style
    func style(appending styles: some Collection<Style>) -> Self {
        styles.reduce(self) {
            parent, child in parent.style(appending: child)
        }
    }

    
    /// Creates a new `Style` by cascading the contents of `styles`.
    ///
    /// - Parameter styles: a collection of styles to cascade
    /// - Returns: a new style
    public init(cascading styles: some Collection<Style>) {
        self = styles.reduce(Style()) {
            parent, child in parent.style(appending: child)
        }
    }
    
    public init() {}
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
