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
    public let merge: (Style, Style.Merge) -> ()
    
    /// A convenience, given a style selection and a proposed new style value,
    /// determines the appropriate operation to perform to existing styles.
    ///
    /// Behavior is determined based on the current selection, and the proposed
    /// style value:
    /// * In absence of an existing style value, or multiple style values, we opt to
    /// add the new style value to all styles within the selection.
    /// * If all styles within the selection share the same value, and that value
    /// matches the proposed style value, then we opt to delete the style value,
    /// otherwise we add the new style value to all styles within the selection.
    ///
    /// - Parameters:
    ///   - key: a style key
    ///   - value: a selected value
    public func update<Key>(key: KeyPath<Style.Keys, Key.Type>, value: Key.Value) where Key: StyleKeys {
        let operation: Style.Merge = switch cardinality(of: key) {
        case .empty, .multiple: .adding
        case let .single(previous): (previous != value) ? .adding : .subtracting
        }
        
        let style = Style() {
            $0[key] = .override(value)
        }

        merge(style, operation)
    }
    
    /// Initializes a new `StyleSelection`.
    /// - Parameters:
    ///   - selection: a collection of selected styles
    ///   - mergeStyle: an update function used to merge a passed style into the selection
    public init(_ selection: [Style], merge: @escaping (Style, Style.Merge) -> ()) {
        self.selection = selection
        self.merge = merge
    }

    /// A type used to describe whether - across some selection of styles -
    /// each style reports a single unique value for some style key, multiple values, or -
    /// when the selection itself is empty - no values.
    public enum Cardinality<Key> where Key: StyleKeys {
        case empty                      /// the style collection is empty
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
            case .empty: []
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
            return .empty
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
            operation, style in Logger().debug("merge \(String(describing: operation)) \(String(describing: style))")
        }
    }
}

extension Style {
    /// A merging strategy for style properties.
    public enum Merge {
        case adding
        case subtracting
    }
    
    /// Merges `style` into the receiver, either by adding or subtracting properties, according to `operation`.
    /// - Parameters:
    ///   - style: a style to merge
    ///   - operation: the merge operation
    /// - Returns: a new style
    public func merge(_ style: Style, _ operation: Style.Merge) -> Style {
        switch operation {
        case .adding:
            self.appending(style)
        case .subtracting:
            self.subtracting(style)
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
    public func focusedStyles(_ styles: some Collection<Style>, merge: @escaping (Style, Style.Merge) -> ()) -> some View  {
        self.focusable(true).focusedValue(\.styles, StyleSelection(Array(styles), merge: merge))
    }
    
    /// Identifies styles associated with the focused scene, and a function used to merge new style attributes into the selection.
    /// - Parameters:
    ///   - styles: a collection of `Style`s
    ///   - merge: a function used to merge new style attributes into the selection
    /// - Returns: a View
    public func focusedSceneStyles(_ styles: some Collection<Style>, merge: @escaping (Style, Style.Merge) -> ()) -> some View {
        self.focusable(true).focusedSceneValue(\.styles, StyleSelection(Array(styles), merge: merge))
    }
}
