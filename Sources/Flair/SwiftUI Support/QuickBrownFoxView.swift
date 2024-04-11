//
//  QuickBrownFoxView.swift
//  Flair
//
//  Created by Mark Onyschuk on 02/13/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI


/// A view used to illustrate font usage, and display font details
public struct QuickBrownFoxView: View {
    var font: FontRef
    var sample: LocalizedStringKey?
    var truncation: Text.TruncationMode

    var displayName: String {
        #if os(iOS)
        font.fontName
            .components(separatedBy: "-")
            .map(\.capitalized)
            .joined(separator: " ")
        #elseif os(macOS)
        font.displayName!
        #endif
    }
    
    var pointSize: Measurement<UnitLength> {
        Measurement(value: font.pointSize, unit: UnitLength.points)
    }
    
    @ViewBuilder
    var fontDetails: some View {
        Text("\(displayName), \(pointSize, format: .measurement(width: .abbreviated))")
    }
    
    @ViewBuilder
    var fontSample: some View {
        if let sample {
            Text(sample)
        } else {
            Text("Quick Brown Fox", bundle: .module)
        }
    }
    
    public var body: some View {
        VStack {
            fontSample
                .truncationMode(truncation)
                .lineLimit(1)
                .foregroundStyle(.primary)
                .font(Font(font))
            fontDetails
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    /// Initializes the view with a native reference-type font to display
    /// - Parameters:
    ///   - font: a font
    ///   - sample: alternative sample text
    ///   - truncation: alternative text truncation
    public init(
        _ font: FontRef,
        sample: LocalizedStringKey? = nil,
        truncation: Text.TruncationMode = .tail
    ) {
        self.font = font
        self.sample = sample
        self.truncation = truncation
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.fixed(225)), GridItem(.fixed(225)), GridItem(.fixed(225))]) {
        ForEach(["en", "fr", "de", "es", "it", "uk", "pl"], id: \.self) {
            QuickBrownFoxView(.preferredFont(forTextStyle: .largeTitle))
                .padding()
                .environment(\.locale, .init(identifier: $0))
        }
    }
}
