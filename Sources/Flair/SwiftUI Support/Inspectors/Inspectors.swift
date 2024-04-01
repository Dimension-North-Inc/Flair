//
//  Inspector.swift
//  Flair
//
//  Created by Mark Onyschuk on 03/13/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

// MARK: - Inspector List
public struct InspectorList<Content>: View where Content: View {
    var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @State private var labelWidth: CGFloat?
    
    public var body: some View {
        VStack(spacing: 1) {
            content
        }
        .onPreferenceChange(LabelWidth.self) {
            labelWidth = $0
        }
        .environment(\.labelWidth, labelWidth)
    }
}

public struct InspectorTitle: View {
    var title: LocalizedStringKey
    
    public var body: some View {
        Text(title)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    public init(_ title: LocalizedStringKey) {
        self.title = title
    }
}

// MARK: - Inspector
public struct Inspector<Editor>: View where Editor: View {
    var title: LocalizedStringKey
    
    var isActive: Bool

    var editor: Editor
    
    @State private var isHovering: Bool = false

    @FocusState private var isFocused: Bool
    
    @Environment(\.labelWidth) private var labelWidth
    
    
    public var body: some View {
        if isActive {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
                    .background(GeometryReader {
                        reader in
                        Color.clear.preference(
                            key: LabelWidth.self,
                            value: reader.size.width
                        )
                    })
                    .frame(minWidth: labelWidth, alignment: .trailing)
                
                editor
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                    .focused($isFocused)
                Spacer()
            }
            .padding(5)
            .onHover {
                isHovering = $0
            }
            .background {
                if isHovering || isFocused {
                    Capsule().fill(.background)
                }
            }
        }
    }
    
    public init(
        _ title: LocalizedStringKey,
        
        isActive: Bool = true,
        
        @ViewBuilder content: () -> Editor
    ) {
        self.title          = title
        
        self.isActive       = isActive
        
        self.editor        = content()
    }
}

// MARK: - Label Width Preference, Environment Key
fileprivate struct LabelWidth: PreferenceKey, EnvironmentKey {
    static var defaultValue: CGFloat?
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = [value, nextValue()].compactMap({ $0 }).max()
    }
}

extension EnvironmentValues {
    fileprivate var labelWidth: CGFloat? {
        get { self[LabelWidth.self] }
        set { self[LabelWidth.self] = newValue }
    }
}


#Preview {
    InspectorList {
        InspectorTitle("Font")
        
        Inspector("Name") {
            Text("Gill Sans")
                .font(.custom("Gill Sans", size: 12))
                .fontWidth(.condensed)
                .fontWeight(.black)
        }
        Inspector("Width") {
            Text("Condensed")
                .fontWidth(.condensed)
        }
        Inspector("Weight") {
            Text("Black")
                .fontWeight(.black)
        }
        Inspector("Size") {
            Text("12 pt.")
        }

        Divider()

        InspectorTitle("Colors")

        Inspector("Text") {
            ColorWell(.constant(.white), style: .minimal)
        }
        Inspector("Highlighter") {
            ColorWell(.constant(.orange), style: .minimal)
        }
    }
    .frame(width: 300)
    .padding()
}
