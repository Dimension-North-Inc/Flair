//
//  FontStyleView.swift
//  Flair
//
//  Created by Mark Onyschuk on 02/13/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

public struct FontStyleView: View {
    public var body: some View {
        VStack {
            FontFaceSelector()
            FontWeightSelector()
            FontWidthSelector()
            FontAngleSelector()
        }
    }
}

public struct FontFaceSelector: View {
    var showsDynamicFaces: Bool = false
    @State private var selection = FontName.body

    public var body: some View {
        Picker(
            selection: $selection,
            label: Text("Face:").frame(width: 100, alignment: .leading)
        ) {
            if showsDynamicFaces {
                ForEach(FontName.allCases.filter(\.isDynamic), id: \.self) {
                    face in
                    
                    Text(face.description.capitalized)
                        .font(.body)
                        .fontName(face)
                }
                Divider()
            }
            ForEach(FontName.allCases.filter(\.isNamed), id: \.self) {
                face in

                Text(face.description.capitalized)
                    .font(.body)
                    .fontName(face)
            }
        }
    }
}

public struct FontAngleSelector: View {
    @State private var selection = false
    public var body: some View {
        Toggle("Italic", isOn: $selection)
            .toggleStyle(.switch)
    }
}

public struct FontWidthSelector: View {
    @State private var selection = FontWidth.standard
    
    public var body: some View {
        Picker(
            selection: $selection,
            label: Text("Width:").frame(width: 100, alignment: .leading)
        ) {
            ForEach(FontWidth.allCases, id: \.self) {
                width in
                Text(width.description.capitalized)
                    .font(.body)
                    .fontWidth(width)                
            }
        }
        .pickerStyle(.menu)
    }
    
}
public struct FontWeightSelector: View {
    @State private var selection = FontWeight.regular
    public var body: some View {
        Picker(
            selection: $selection,
            label: Text("Weight:").frame(width: 100, alignment: .leading)
        ) {
            ForEach(FontWeight.allCases, id: \.self) {
                weight in
                Text(weight.description.capitalized)
                    .font(.body)
                    .fontWeight(weight)
            }
        }
        .pickerStyle(.menu)
    }
}

#Preview {
    FontStyleView().padding()
}
