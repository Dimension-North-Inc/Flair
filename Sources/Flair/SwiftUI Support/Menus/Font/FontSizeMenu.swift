//
//  SwiftUIView.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/18/24.
//

import Silo
import SwiftUI

struct FontSizeMenu: View {
    @FocusedValue(\.styles) var selection
    
    public init() {}
    
    public var body: some View {
        Menu(content: {options}, label: {title})
    }
        
    @ViewBuilder var options: some View {
        if !selectedSizes.isEmpty {
            ForEach(selectedSizes.sorted(), id: \.self) {
                size in MixedStateButton(state(size), title(size), nil) {
                    select(size)
                }
            }
            Divider()
        }
        ForEach(sizes, id: \.self) {
            size in MixedStateButton(state(size), title(size), nil) {
                select(size)
            }
        }
    }
    
    @ViewBuilder var title: some View {
        Text("Size")
    }
    
    private let sizes: [CGFloat] = [
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        18,
        24,
        36,
        48,
        64,
        72,
        96,
        144,
        288
    ]
    
    private var selectedSizes: Set<CGFloat> {
        selection?.fontSize.values ?? []
    }
    
    private func title(_ size: CGFloat) -> String {
        "\(size.formatted()) pt."
    }
    private func state(_ size: CGFloat) -> MixedState {
        selectedSizes.contains(size)
        ? selectedSizes.count == 1 ? .on : .mixed
        : .off
    }
    
    private func select(_ size: CGFloat) {
        selection?.update(key: \.fontSize, value: size)
    }
}

#Preview {
    FontSizeMenu()
}
