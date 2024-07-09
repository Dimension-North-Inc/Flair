//
//  FontStyles.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import SwiftUI


public struct FontNameStyle: StyleKeys {
    
    public static var name = "flair.font-name"
    public static var initial: FontName = {
        func userFont() -> FontRef? {
            #if os(iOS)
            FontRef.preferredFont(forTextStyle: .body)
            #elseif os(macOS)
            FontRef.userFont(ofSize: 12)
            #endif
        }

        guard let font = userFont() else {
            return .body
        }
        
        let descriptor = FontDescriptor(font: font)
        guard let family = descriptor.family else {
            return .body
        }
        
        return .named(family)
    }()
}

public struct FontSizeStyle: StyleKeys {
    public static var name = "flair.font-size"
    public static var initial: CGFloat = 12
}

public struct FontAngleStyle: StyleKeys {
    public static var name = "flair.font-angle"
    public static var initial: FontAngle = .standard
}

public struct FontWeightStyle: StyleKeys {
    public static var name = "flair.font-weight"
    public static var initial: FontWeight = .regular
}

public struct FontWidthStyle: StyleKeys {
    public static var name = "flair.font-width"
    public static var initial: FontWidth = .standard
}

public struct FontBoldStyle: StyleKeys {
    public static var name = "flair.font-bold"
    public static var initial: Bool = false
}

public struct FontItalicStyle: StyleKeys {
    public static var name = "flair.font-italic"
    public static var initial: Bool = false
}

extension Style.Keys {
    public var fontName: FontNameStyle.Type {
        FontNameStyle.self
    }
    
    public var fontSize: FontSizeStyle.Type {
        FontSizeStyle.self
    }
    
    public var fontAngle: FontAngleStyle.Type {
        FontAngleStyle.self
    }
    
    public var fontWeight: FontWeightStyle.Type {
        FontWeightStyle.self
    }
    
    public var fontWidth: FontWidthStyle.Type {
        FontWidthStyle.self
    }
    
    public var bold: FontBoldStyle.Type {
        FontBoldStyle.self
    }
    public var italic: FontItalicStyle.Type {
        FontItalicStyle.self
    }
}
