//
//  FontInspector.swift
//  Flair
//
//  Created by Mark Onyschuk on 03/11/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

public struct FontInspector: View {
    @State private var selection = StyleSelection([Style(), Style()]) {
        merge in print("merging \(merge)")
    }

    var showsDynamicFonts: Bool = false
    
    private var fonts: [FontName] {
        showsDynamicFonts ? dynamicFonts : namedFonts
    }
    private var namedFonts: [FontName] = FontName.allCases.filter(\.isNamed)
    private var dynamicFonts: [FontName] = FontName.allCases.filter(\.isDynamic)

    @State private var selectedSize: CGFloat = 14
    @State private var selectedNames: Set<FontName> = [.named("Helvetica")]
    @State private var selectedWidths: Set<FontWidth> = [FontWidth.standard]
    @State private var selectedWeights: Set<FontWeight> = [FontWeight.regular]


    private func fontPicker() -> some View {
        MultistatePopup(fonts, id: \.self, selection: $selectedNames) {
            name in Text(name.description.capitalized)
                .font(.body)

        }
        .onChange(of: selectedNames) {
            value in if let name = value.first {
                selection.merge(
                    Style {
                        $0.fontName = name
                    }
                )
            }
        }
    }
    
    private func widthPicker() -> some View {
        MultistatePopup(FontWidth.allCases, id: \.self, selection: $selectedWidths) {
            width in Text(width.description.capitalized)
                .font(.body)
                .fontWidth(.init(rawValue: width.rawValue))
        }
        .onChange(of: selectedWidths) {
            value in if let width = value.first {
                selection.merge(
                    Style {
                        $0.fontWidth = width
                    }
                )
            }
        }
    }
    
    private func weightPicker() -> some View {
        MultistatePopup(FontWeight.allCases, id: \.self, selection: $selectedWeights) {
            weight in Text(weight.description.capitalized)
                .font(.body)
                .fontWeight(.init(rawValue: weight.rawValue))
        }
        .onChange(of: selectedWeights) {
            value in if let weight = value.first {
                selection.merge(
                    Style {
                        $0.fontWeight = weight
                    }
                )
            }
        }
    }

    private let formatter: NumberFormatter = {
        let suffix = " pt."
        let formatter = NumberFormatter()
       
        formatter.minimum        = 4
        formatter.isLenient      = true
        formatter.positiveSuffix = suffix
        formatter.negativeSuffix = suffix
        formatter.numberStyle    = .decimal

        return formatter
    }()
    
    private func pointSizePicker() -> some View {
        TextField("Size", value: $selectedSize, formatter: formatter)
            .multilineTextAlignment(.leading)
            .textFieldStyle(.plain)
            .onSubmit {
                selection.merge(
                    Style {
                        $0.fontSize = selectedSize
                    }
                )
            }
    }
    
    public var body: some View {
        Group {
            Inspector("Font") {
                fontPicker()
            }
            Inspector("Width") {
                widthPicker()
            }
            Inspector("Weight") {
                weightPicker()
            }
            Inspector("Size") {
                pointSizePicker()
            }
        }.buttonStyle(.borderless)
    }
    
    public init() {}
}

#Preview {
    InspectorList {
        FontInspector()
            .labelsHidden()
            .fontWidth(.condensed)
    }
    .frame(width: 250)
    .padding()
}
