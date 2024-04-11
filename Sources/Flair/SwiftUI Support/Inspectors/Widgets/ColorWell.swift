//
//  ColorWell.swift
//  Flair
//
//  Created by Mark Onyschuk on 03/04/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

public struct ColorWell {
    @Binding var value: Color

    public enum Style {
        case minimal
        case expanded

        case `default`
    }
    
    var style: Style = .default
    
    public init(_ value: Binding<Color>, style: Style = .default) {
        self._value = value
        self.style  = style
    }
}

#if os(iOS)
extension ColorWell: View {
    public var body: some View {
        ColorPicker(
            "Choose Color",
            selection: $value
        )
        .labelsHidden()
    }
}

#elseif os(macOS)
extension ColorWell.Style {
    var rawValue: NSColorWell.Style {
        switch self {
        case .minimal:  .minimal
        case .expanded: .expanded

        case .default:  .default
        }
    }
}

extension ColorWell: NSViewRepresentable {
    public func makeNSView(context: Context) -> NSColorWell {
        let view = NSColorWell(style: style.rawValue)
        
        view.target = context.coordinator
        view.action = #selector(Coordinator.takeColorFrom(_:))
        
        return view
    }
    
    public func updateNSView(_ view: NSColorWell, context: Context) {
        view.colorWellStyle = style.rawValue
        view.color = value.cgColor.flatMap(NSColor.init) ?? .labelColor
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, nsView view: NSColorWell, context: Context) -> CGSize? {
        view.fittingSize
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator {
            colorRef in self.value = Color(colorRef)
        }
    }
    
    public final class Coordinator: NSObject {
        var update: (NSColor) -> ()
        
        @IBAction func takeColorFrom(_ sender: NSColorWell) {
            update(sender.color)
        }
        
        init(update: @escaping (NSColor) -> ()) {
            self.update = update
        }
    }
    
}
#endif

#Preview {
    ColorWell(.constant(.red), style: .minimal).padding()
}
