//
//  Color.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import SwiftUI

#if os(iOS)
public typealias ColorRef = UIColor
#elseif os(macOS)
public typealias ColorRef = NSColor
#endif

extension Style {
    public enum Color: Codable, Hashable, CustomStringConvertible {
        case black
        case white
        
        case clear
        
        case blue
        case brown
        case cyan
        case gray
        case green
        case indigo
        case mint
        case orange
        case pink
        case purple
        case red
        case teal
        case yellow
        
        case primary
        case secondary
        case accentColor
        
        case rgba(Float, Float, Float, Float)
        
        @available(iOS 17.0, macOS 14.0, *)
        public init(_ color: SwiftUI.Color, environment: SwiftUI.EnvironmentValues) {
            switch color {
            case .black:        self = .black
            case .white:        self = .white
                
            case .clear:        self = .clear
                
            case .blue:         self = .blue
            case .brown:        self = .brown
            case .cyan:         self = .cyan
            case .gray:         self = .gray
            case .green:        self = .green
            case .indigo:       self = .indigo
            case .mint:         self = .mint
            case .orange:       self = .orange
            case .pink:         self = .pink
            case .purple:       self = .purple
            case .red:          self = .red
            case .teal:         self = .teal
            case .yellow:       self = .yellow
                
            case .primary:      self = .primary
            case .secondary:    self = .secondary
            case .accentColor:  self = .accentColor
                
            default:
                let resolved = color.resolve(in: environment)
                self = .rgba(resolved.linearRed, resolved.linearGreen, resolved.linearBlue, resolved.opacity)
            }
        }
        
        // MARK: - CustomStringConvertible
        public var description: String {
            switch self {
            case .black:        ".black"
            case .white:        ".white"
                
            case .clear:        ".clear"
                
            case .blue:         ".blue"
            case .brown:        ".brown"
            case .cyan:         ".cyan"
            case .gray:         ".gray"
            case .green:        ".green"
            case .indigo:       ".indigo"
            case .mint:         ".mint"
            case .orange:       ".orange"
            case .pink:         ".pink"
            case .purple:       ".purple"
            case .red:          ".red"
            case .teal:         ".teal"
            case .yellow:       ".yellow"
                
            case .primary:      ".primary"
            case .secondary:    ".secondary"
            case .accentColor:  ".accentColor"
                
            case let .rgba(r, g, b, a):
                ".rgba(\(r), \(g), \(b), \(a))"
            }
        }
    }
}

extension Style.Color {
    var ref: ColorRef {
        switch self {
        case .black:        ColorRef.black
        case .white:        ColorRef.white
        case .clear:        ColorRef.clear
            
        case .blue:         ColorRef.systemBlue
        case .brown:        ColorRef.systemBrown
        case .cyan:         ColorRef.systemCyan
        case .gray:         ColorRef.systemGray
        case .green:        ColorRef.systemGreen
        case .indigo:       ColorRef.systemIndigo
        case .mint:         ColorRef.systemMint
        case .orange:       ColorRef.systemOrange
        case .pink:         ColorRef.systemPink
        case .purple:       ColorRef.systemPurple
        case .red:          ColorRef.systemRed
        case .teal:         ColorRef.systemTeal
        case .yellow:       ColorRef.systemYellow
            
        case .primary:      ColorRef.label
        case .secondary:    ColorRef.secondaryLabel

        case .accentColor:  ColorRef.tintColor
            
        case let .rgba(r, g, b, a):
            ColorRef(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
        }
    }
}

extension ColorRef {
    #if os(macOS)
    static var label: ColorRef {
        ColorRef.labelColor
    }
    static var secondaryLabel: ColorRef {
        ColorRef.secondaryLabelColor
    }
    static var tintColor: ColorRef {
        ColorRef.controlAccentColor
    }
    #endif
    
    #if os(iOS)
    var redComponent: CGFloat {
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return r
    }
    var greenComponent: CGFloat {
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return g
    }
    var blueComponent: CGFloat {
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return b
    }
    var alphaComponent: CGFloat {
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return a
    }
    #endif
    
    var value: Style.Color {
        if self.isEqual(ColorRef.black) {
            return .black
        } else if self.isEqual(ColorRef.white) {
            return .white
        } else if self.isEqual(ColorRef.clear) {
            return .clear
        } else if self.isEqual(ColorRef.systemBlue) {
            return .blue
        } else if self.isEqual(ColorRef.systemBrown) {
            return .brown
        } else if self.isEqual(ColorRef.systemCyan) {
            return .cyan
        } else if self.isEqual(ColorRef.systemGray) {
            return .gray
        } else if self.isEqual(ColorRef.systemGreen) {
            return .green
        } else if self.isEqual(ColorRef.systemIndigo) {
            return .indigo
        } else if self.isEqual(ColorRef.systemMint) {
            return .mint
        } else if self.isEqual(ColorRef.systemOrange) {
            return .orange
        } else if self.isEqual(ColorRef.systemPink) {
            return .pink
        } else if self.isEqual(ColorRef.systemPurple) {
            return .purple
        } else if self.isEqual(ColorRef.systemRed) {
            return .red
        } else if self.isEqual(ColorRef.systemTeal) {
            return .teal
        } else if self.isEqual(ColorRef.systemYellow) {
            return .yellow
        } else if self.isEqual(ColorRef.label) {
            return .primary
        } else if self.isEqual(ColorRef.secondaryLabel) {
            return .secondary
        } else if self.isEqual(ColorRef.tintColor) {
            return .accentColor
        } else {
            return .rgba(
                Float(self.redComponent),
                Float(self.greenComponent),
                Float(self.blueComponent),
                Float(self.alphaComponent)
            )
        }
    }
}
