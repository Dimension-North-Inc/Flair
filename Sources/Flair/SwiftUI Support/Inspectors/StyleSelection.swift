//
//  StyleSelection.swift
//  Flair
//
//  Created by Mark Onyschuk on 03/02/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import OSLog
import SwiftUI

/// A type used to describe a selection of styles, and define an
/// action used to merge new style elements into that selection.
@dynamicMemberLookup
public struct StyleSelection {
    /// a collection of selected styles
    public let selection: [Style]
    
    /// an update function used to merge a passed style into the selection
    public let merge: (Style) -> ()
    
    /// Initializes a new `StyleSelection`.
    /// - Parameters:
    ///   - selection: a collection of selected styles
    ///   - mergeStyle: an update function used to merge a passed style into the selection
    public init(_ selection: [Style], merge: @escaping (Style) -> ()) {
        self.selection = selection
        self.merge = merge
    }

    /// A type used to describe whether - across some selection of styles -
    /// each style reports a single unique value for some style key, multiple values, or -
    /// when the selection itself is empty - no values.
    public enum Cardinality<Key> where Key: StyleKeys {
        case none                       /// the style collection is empty
        case single(Key.Value)          /// the style key has a single value across all styles
        case multiple(Set<Key.Value>)   /// the style key has more than one value across all styles

        var value: Key.Value? {
            if case let .single(value) = self {
                return value
            } else {
                return nil
            }
        }
        
        /// unique values for `Key`
        var values: Set<Key.Value> {
            switch self {
            case .none: []
            case .single(let value): [value]
            case .multiple(let values): values
            }
        }
    }

    public func cardinality<Key>(of key: KeyPath<Style.Keys, Key.Type>) -> Cardinality<Key> where Key: StyleKeys {
        let values = Set(
            selection.map { style in style[value: key] }
        )
        
        if let first = values.first {
            return values.dropFirst().isEmpty ? .single(first) : .multiple(values)
        } else {
            return .none
        }
    }
    
    public subscript<Key>(dynamicMember key: KeyPath<Style.Keys, Key.Type>) -> Cardinality<Key> where Key: StyleKeys {
        cardinality(of: key)
    }
}

// MARK: - StyleSelection Debug Support

extension StyleSelection: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Style...) {
        self.init(elements) {
            style in Logger().debug("merge \(String(describing: style))")
        }
    }
}


// MARK: - SwiftUI Support

extension FocusedValues {
    private struct StylesKey: FocusedValueKey {
        typealias Value = StyleSelection
    }
    public var styles: StyleSelection? {
        get { self[StylesKey.self] }
        set { self[StylesKey.self] = newValue }
    }
}

extension View {
    /// Identifies styles associated with application focus, and a function used to merge new style attributes into the selection.
    /// - Parameters:
    ///   - styles: a collection of `Style`s
    ///   - merge: a function used to merge new style attributes into the selection
    /// - Returns: a View
    public func focusedStyles(_ styles: some Collection<Style>, merge: @escaping (Style) -> ()) -> some View  {
        self.focusedValue(\.styles, StyleSelection(Array(styles), merge: merge))
    }
    
    /// Identifies styles associated with the focused scene, and a function used to merge new style attributes into the selection.
    /// - Parameters:
    ///   - styles: a collection of `Style`s
    ///   - merge: a function used to merge new style attributes into the selection
    /// - Returns: a View
    public func focusedSceneStyles(_ styles: some Collection<Style>, merge: @escaping (Style) -> ()) -> some View {
        self.focusedSceneValue(\.styles, StyleSelection(Array(styles), merge: merge))
    }
}
