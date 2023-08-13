//
//  Color.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import SwiftUI

public enum Color: Codable, Equatable {
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
    
    public var color: SwiftUI.Color {
        switch self {
        case .black:        .black
        case .white:        .white

        case .clear:        .clear

        case .blue:         .blue
        case .brown:        .brown
        case .cyan:         .cyan
        case .gray:         .gray
        case .green:        .green
        case .indigo:       .indigo
        case .mint:         .mint
        case .orange:       .orange
        case .pink:         .pink
        case .purple:       .purple
        case .red:          .red
        case .teal:         .teal
        case .yellow:       .yellow
            
        case .primary:      .primary
        case .secondary:    .secondary
        case .accentColor:  .accentColor
            
        case let .rgba(r, g, b, a):
            SwiftUI.Color(.sRGBLinear, red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
        }
    }
}
