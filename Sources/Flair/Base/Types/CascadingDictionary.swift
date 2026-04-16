//
//  CascadingDictionary.swift
//  Flair
//
//  Created by Mark Onyschuk on 04/16/26.
//  Copyright © 2026 Dimension North Inc. All rights reserved.
//

import Foundation


public struct CascadingDictionary<Key: Hashable, Value> {
    public enum Cascade<T> {
        case initial
        case inherit
        case override(T)
    }

    var values: [Key: Cascade<Value>]

    // MARK: - Initializers

    public init() {
        self.values = [:]
    }

    /// Creates a new dictionary by cascading a collection of dictionaries.
    /// - Parameter dictionaries: dictionaries to cascade, in order (first = parent, last = child)
    public init(cascading dictionaries: some Collection<Self>) {
        self = dictionaries.reduce(Self()) { parent, child in
            parent.appending(child)
        }
    }

    /// Creates a new dictionary by cascading a collection of dictionaries.
    /// - Parameter dictionaries: dictionaries to cascade, in order (first = parent, last = child)
    public init(cascading dictionaries: Self...) {
        self.init(cascading: dictionaries)
    }

    // MARK: - Subscripts

    /// Accesses the cascade value for a given key.
    public subscript(key: Key) -> Cascade<Value> {
        get { values[key] ?? .inherit }
        set { values[key] = newValue }
    }

    // MARK: - Combinations

    /// Creates a new dictionary by appending the contents of `dictionary` to `self`.
    /// - Parameter dictionary: the dictionary to append
    /// - Returns: a new dictionary
    public func appending(_ dictionary: Self) -> Self {
        Self.cascade(parent: self, child: dictionary)
    }

    /// Creates a new dictionary by appending the contents of `dictionaries` to `self`.
    /// - Parameter dictionaries: the dictionaries to append
    /// - Returns: a new dictionary
    public func appending(_ dictionaries: some Collection<Self>) -> Self {
        dictionaries.reduce(self) { parent, child in
            parent.appending(child)
        }
    }

    /// Creates a new dictionary by prepending the contents of `dictionary` to `self`.
    /// - Parameter dictionary: the dictionary to prepend
    /// - Returns: a new dictionary
    public func prepending(_ dictionary: Self) -> Self {
        Self.cascade(parent: dictionary, child: self)
    }

    /// Creates a new dictionary by prepending the contents of `dictionaries` to `self`.
    /// - Parameter dictionaries: the dictionaries to prepend
    /// - Returns: a new dictionary
    public func prepending(_ dictionaries: some Collection<Self>) -> Self {
        dictionaries.reduce(self) { child, parent in
            parent.prepending(child)
        }
    }

    /// Combines two dictionaries using cascade rules.
    /// Child's `.override` wins over parent's `.override`; absent or `.initial`/`.inherit` is excluded from result.
    private static func cascade(parent: Self, child: Self) -> Self {
        var result = Self()

        for key in Set(parent.values.keys).union(child.values.keys) {
            switch (parent.values[key], child.values[key]) {
            case (_, .override(let value)):
                result.values[key] = .override(value)
            case (.override(let value), _):
                result.values[key] = .override(value)
            default:
                break
            }
        }

        return result
    }

    // MARK: - Component Extraction

    /// Creates a new dictionary containing only the entries whose keys are in `keys`.
    /// - Parameter keys: the keys to extract
    /// - Returns: a new dictionary
    public func extracting(_ keys: some Sequence<Key>) -> Self {
        var result = Self()
        let keySet = Set(keys)
        for (key, cascade) in values where keySet.contains(key) {
            result.values[key] = cascade
        }
        return result
    }

    /// Creates a new dictionary by removing entries whose keys and cascade values match those in `dictionary`.
    /// Uses a custom equality function to compare values.
    /// - Parameters:
    ///   - dictionary: the dictionary whose entries should be removed
    ///   - equals: a function that returns `true` if two values are equal
    /// - Returns: a new dictionary
    public func subtracting(_ dictionary: Self, equals: (Value, Value) -> Bool) -> Self {
        var result = Self()

        for (key, cascade) in values {
            switch (dictionary.values[key], cascade) {
            case (.inherit, _):
                continue  // d2 says inherit this key — remove it
            case (.initial, .initial):
                continue  // both initial — remove
            case (.override(let a), .override(let b)) where equals(a, b):
                continue  // matching override values — remove
            default:
                result.values[key] = cascade
            }
        }

        return result
    }

    /// Creates a new dictionary by removing entries whose keys and cascade values match those in `dictionary`.
    /// Requires `Value: Equatable`.
    /// - Parameter dictionary: the dictionary whose entries should be removed
    /// - Returns: a new dictionary
    public func subtracting(_ dictionary: Self) -> Self where Value: Equatable {
        subtracting(dictionary) { $0 == $1 }
    }
}

extension CascadingDictionary.Cascade: Codable where T: Codable {}
extension CascadingDictionary.Cascade: Hashable where T: Hashable {}
extension CascadingDictionary.Cascade: Equatable where T: Equatable {}

extension CascadingDictionary.Cascade: Sendable where T: Sendable {}


extension CascadingDictionary: Codable where Key: Codable, Value: Codable {}
extension CascadingDictionary: Hashable where Key: Hashable, Value: Hashable {}
extension CascadingDictionary: Equatable where Key: Equatable, Value: Equatable {}

extension CascadingDictionary: Sendable where Key: Sendable, Value: Sendable {}
