//
//  FontStyles.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import SwiftUI


public struct FontNameStyle: StyleKeys {
    
    public static let name = "flair.font-name"
    public static let initial: FontName = {
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
    public static let name = "flair.font-size"
    public static let initial: CGFloat = 12
}

public struct FontAngleStyle: StyleKeys {
    public static let name = "flair.font-angle"
    public static let initial: FontAngle = .standard
}

public struct FontWidthStyle: StyleKeys {
    public static let name = "flair.font-width"
    public static let initial: FontWidth = .standard
}

public struct FontWeightStyle: StyleKeys {
    public static let name = "flair.font-weight"
    public static let initial: FontWeight = .regular
}

public struct FontVariantCapsStyle: StyleKeys {
    public static let name = "flair.font-variant-caps"
    public static let initial = FontVariantCaps.normal
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
    
    public var fontWidth: FontWidthStyle.Type {
        FontWidthStyle.self
    }

    public var fontWeight: FontWeightStyle.Type {
        FontWeightStyle.self
    }

    public var fontVariantCaps: FontVariantCapsStyle.Type {
        FontVariantCapsStyle.self
    }
}
