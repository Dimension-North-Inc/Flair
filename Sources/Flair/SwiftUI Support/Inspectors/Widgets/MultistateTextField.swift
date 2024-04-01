//
//  SwiftUIView.swift
//  
//
//  Created by Mark Onyschuk on 03/25/24.
//

import SwiftUI


public struct MultistateTextField<C>: View
where C: RangeReplaceableCollection, C.Element: Hashable {
    
    @Binding var collection: C
    
    @State private var text: String = ""

    var formatter: Formatter?

    public init(collection: Binding<C>, formatter: Formatter? = nil) {
        self._collection = collection
        self.formatter = formatter
        self._text = State(
            initialValue:self.text(for: collection.wrappedValue)
        )
    }
    
    public var body: some View {
        TextField("Enter value", text: $text, onCommit: {
            commitText()
        })
        .onAppear {
            self.text = text(for: collection)
        }
    }
    
    private func text(for collection: C) -> String {
        if collection.isEmpty {
            return ""
        } else if collection.count == 1, let first = collection.first {
            return formatter?.string(for: first) ?? String(describing: first)
        } else {
            return "Multiple Selection"
        }
    }

    private func commitText() {
        if text == "Multiple Selection" || text.isEmpty {
            collection = C()
        } else {
            var objectValue: AnyObject? = nil
            var errorDesc: NSString? = nil
            if let formatter = formatter,
               formatter.getObjectValue(&objectValue, for: text, errorDescription: &errorDesc),
               let newValue = objectValue as? C.Element {
                collection = C([newValue])
            } else {
                // Fallback for String or when no formatter is provided
                if let directValue = text as? C.Element {
                    collection = C([directValue])
                }
            }
        }
    }
}

#Preview {
    struct Multistate_Preview: View {
        @State private var values: [CGFloat] = [1, 2, 3]
        var body: some View {
            MultistateTextField(collection: $values, formatter: NumberFormatter())
                .textFieldStyle(.plain)
                .padding()
        }
    }
    return Multistate_Preview()
}
