//
//  StyleKeys.swift
//  Flair
//
//  Created by Mark Onyschuk on 2023-07-25.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import Foundation

/// A distinct style element, such as foreground or background color, font weight,  border width,
/// or application specific display or behavioural setting.
///
/// The definition of a style element includes a `name` used to store the element in `Codable` containers,
/// and an `initial` value used for the style element when it is left undefined within a style.
public protocol StyleKeys<Value> {
    associatedtype Value: Codable & Equatable
    
    /// a name used to store the element in `Codable` containers.
    static var name: String { get }
    
    /// an  initial - or default - value for the element used when it is left undefined within a style.
    static var initial: Value { get }
}

public extension StyleKeys {
    static func encode(_ value: Any, into container: inout UnkeyedEncodingContainer) throws {
        guard let encodable = value as? Value else {
            return
        }
        try container.encode(encodable)
    }
    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        return try container.decode(Value.self)
    }
    
    static func valuesAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        if let lhs = lhs as? Value, let rhs = rhs as? Value {
            return lhs == rhs
        } else {
            return false
        }
    }
}

extension Style {
    /// A container for  shorthand references to `StyleKeys` conforming types.
    ///
    /// When creating a  `StyleKeys` conforming type, add it to `Style.Key`
    /// to allow a more natural shorthand for subscripting styles:
    ///
    /// ```
    /// extension Style.Key {
    ///     struct CardStyle: StyleKeys {
    ///         enum Value {
    ///             case imageOnly
    ///             case imageLeading
    ///             case imageTrailing
    ///         }
    ///         static var name = "example.cardstyle"
    ///         static var initial = Value.imageLeading
    ///     }
    ///
    ///     var card: CardStyle.Type {
    ///         return CardStyle.self
    ///     }
    /// }
    ///
    /// var s = Style()
    /// s[\.card] = .imageTrailing
    ///
    /// ```
    public struct Key {
    }
}

