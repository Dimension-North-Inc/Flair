//
//  QuickBrownFoxView.swift
//  Flair
//
//  Created by Mark Onyschuk on 02/13/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

struct QuickBrownFoxView: View {
    var font: FontRef
    
    var displayName: String {
        font.displayName!
    }
    var pointSize: Measurement<UnitLength> {
        Measurement(value: font.pointSize, unit: UnitLength.points)
    }
    
    @ViewBuilder
    var fontDetails: some View {
        Text("\(displayName), \(pointSize, format: .measurement(width: .abbreviated))")
    }
    
    var body: some View {
        VStack {
            Text("Quick Brown Fox", bundle: .module)
                .truncationMode(.tail)
                .lineLimit(1)
                .foregroundStyle(.primary)
                .font(Font(font))
            fontDetails
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.fixed(230)), GridItem(.fixed(230)), GridItem(.fixed(230))]) {
        ForEach(["en", "fr", "de", "es", "it", "uk", "pl"], id: \.self) {
            QuickBrownFoxView(font: .preferredFont(forTextStyle: .title3))
                .padding()
                .environment(\.locale, .init(identifier: $0))
        }
    }
}
