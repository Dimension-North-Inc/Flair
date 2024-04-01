//
//  Inspector.swift
//  Flair
//
//  Created by Mark Onyschuk on 03/13/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Flair

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

public struct StyleTitle: View {
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
    var isDraggable: Bool

    var editor: Editor
    
    @State private var isHovering: Bool = false
    @Environment(\.labelWidth) private var labelWidth
    
    
    public var body: some View {
        if isActive {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "circle")
                    .scaleEffect(0.5)
                    .opacity(isDraggable && isHovering ? 1 : 0)
                
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
                
                Spacer()
            }
            .padding(5)
            .onHover {
                isHovering = $0
            }
            .background {
                if isHovering {
                    Capsule().fill(.background)
                }
            }
        }
    }
    
    public init(
        _ title: LocalizedStringKey,
        
        isActive: Bool = true,
        isDraggable: Bool = true,
        
        @ViewBuilder content: () -> Editor
    ) {
        self.title          = title
        
        self.isActive       = isActive
        self.isDraggable    = isDraggable
        
        self.editor        = content()
    }
}

// MARK: - Label Width Preference, Environment Key

fileprivate struct LabelWidth: PreferenceKey, EnvironmentKey {
    static var defaultValue: CGFloat?
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = switch (value, nextValue()) {
        case (nil, nil):
            nil
        case let (v1?, nil):
            v1
        case let (nil, v2?):
            v2
        case let (v1?, v2?):
            max(v1, v2)
        }
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
        StyleTitle("Font")
        
        Inspector("Name") {
            Text("Multiple")
        }
        Inspector("Width") {
            Text("Multiple")
        }
        Inspector("Weight") {
            Text("Multiple")
        }
        Inspector("Size") {
            Text("Multiple")
        }
        Divider()
        StyleTitle("Colors")
        
        Inspector("Text") {
            Text("Multiple")
        }
        Inspector("Highlighter") {
            Text("Multiple")
        }
    }
    .frame(width: 300)
    .padding()
    .font(.body).fontWidth(.condensed)
}
