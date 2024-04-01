//
//  MultistatePopup.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/24/23.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

/// A pop-up list with representations corresponding to
/// no-, single-, and multiple selection.
public struct MultistatePopup<Data, ID, Content>: View where Data: RandomAccessCollection, ID: Hashable, Content: View
{
    public typealias Element = Data.Element
    
    private var data:    Data
    private var ident:   (Element) -> ID
    
    @Binding private var selection: Set<ID>
    
    private var content: (Element) -> Content
    
    @ViewBuilder
    private var title: some View {
        if let first = selectedItems.first {
            if selectedItems.dropFirst().isEmpty {
                content(first.value)
            } else {
                Text("Multiple Selection")
            }
        } else {
            Text("No Selection")
        }
    }

    private var items: [Identified<Element, ID>] {
        data.map {
            item in Identified(value: item, id: ident(item))
        }
    }
    private var selectedItems: [Identified<Element, ID>] {
        items.filter {
            item in selection.contains(item.id)
        }
    }
    
    private func select(_ id: ID) {
        if selection != [id] {
            selection = [id]
        }
    }
    
    public var body: some View {
        Menu {
            if !selectedItems.isEmpty {
                ForEach(selectedItems) {
                    item in Button(action: { select(item.id) }) {
                        content(item.value)
                    }
                }
                Divider()
            }
            ForEach(items) {
                item in Button(action: { select(item.id) }) {
                    content(item.value)
                }
            }
        } label: {
            title
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(
            .borderless
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
    
    /// Initializes a `PopupList` with data and some current selection
    /// - Parameters:
    ///   - data: pop up data
    ///   - selection: the current selection
    ///   - content: a function used to render data elements
    public init(
        _ data: Data,
        selection: Binding<Set<ID>>,
        @ViewBuilder content: @escaping (Element) -> Content
    ) where Element: Identifiable, Element.ID == ID {
        self.data       = data
        self.ident      = { item in item.id }
        self.content    = content

        self._selection = selection
    }
    
    
    /// Initializes a `PopupList` with data, a key path to an element identifier,
    /// and some current selection.
    /// - Parameters:
    ///   - data: pop up data
    ///   - id: keypath to a unique id
    ///   - selection: the current selection
    ///   - content: a function used to render data elements
    public init(
        _ data: Data,
        id: KeyPath<Element, ID>,
        selection: Binding<Set<ID>>,
        @ViewBuilder content: @escaping (Element) -> Content
    ) {
        self.data       = data
        self.ident      = { item in item[keyPath: id] }
        self.content    = content

        self._selection = selection
    }
}

private struct Identified<Value, ID>: Identifiable where ID: Hashable {
    var value: Value
    var id: ID
}


#Preview {
    struct SampleList: View {
        // Sample data for completions
        let items = ["Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape", "Honeydew"]
        
        typealias Item = String
        @State private var selection: Set<Item> = ["Cherry", "Date"]
        
        var body: some View {
            MultistatePopup(items, id: \.self, selection: $selection) {
                item in Text(item)
            }
            .padding()
        }
    }

    return SampleList()
}
