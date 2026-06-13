//
//  TextStyles.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Foundation

public enum AlignmentStyle: String, StyleKeys, Codable, Hashable, CaseIterable, Sendable {
    case leading
    case trailing
    case centered
    case justified
    
    public static let name      = "flair.alignment"
    public static let initial   = Self.leading
}

public struct LineSpacingStyle: StyleKeys {
    public static let name      = "flair.line-spacing"
    public static let initial   = CGFloat(0)
}

public struct LineHeightMultipleStyle: StyleKeys {
    public static let name      = "flair.line-height-multiple"
    public static let initial   = CGFloat(0)
}

public struct ParagraphSpacingStyle: StyleKeys {
    public static let name      = "flair.paragraph-spacing"
    public static let initial   = CGFloat(0)
}

public struct ParagraphSpacingBeforeStyle: StyleKeys {
    public static let name      = "flair.paragraph-spacing-before"
    public static let initial   = CGFloat(0)
}

public struct ForegroundColorStyle: StyleKeys {
    public static let name      = "flair.foreground-color"
    public static let initial   = Style.Color.primary
}

public struct BackgroundColorStyle: StyleKeys {
    public static let name      = "flair.background-color"
    public static let initial   = Style.Color.clear
}


public enum Pattern: Codable, Hashable, Sendable {
    case solid
    
    case dashed
    case dotted
    case dashDotted
    case dashDotDotted
    
    var style: NSUnderlineStyle {
        switch self {
        case .solid:         []
        case .dashed:        .patternDash
        case .dotted:        .patternDot
        case .dashDotted:    .patternDashDot
        case .dashDotDotted: .patternDashDotDot
        }
    }
}

public enum Stroke: Codable, Hashable, Sendable {
    case thick

    case single
    case double
    
    var style: NSUnderlineStyle {
        switch self {
        case .thick:         .thick
        case .single:        .single
        case .double:        .double
        }
    }
}

public struct UnderlineStyle: StyleKeys, Codable, Hashable, Sendable {
    public var pattern: Pattern      = .solid
    public var stroke: Stroke        = .single
    public var words: Bool           = false
    
    public var color: Style.Color?   = nil
    
    public static let name           = "flair.underline"
    public static let initial: Self? = nil
    
    public var style: NSUnderlineStyle {
        [pattern.style, stroke.style, words ? .byWord : []]
    }
    
    public init() {}
}

public struct StrikethroughStyle: StyleKeys, Codable, Hashable, Sendable {
    public var pattern: Pattern      = .solid
    public var stroke: Stroke        = .single
    public var words: Bool           = false

    public var color: Style.Color?   = nil

    public static let name           = "flair.strikethrough"
    public static let initial: Self? = nil
    
    public var style: NSUnderlineStyle {
        [pattern.style, stroke.style, words ? .byWord : []]
    }

    public init() {}
}

public struct BoldStyle: StyleKeys, Codable, Hashable {
    public static let name      = "flair.bold"
    public static let initial   = false
}

public struct ItalicStyle: StyleKeys, Codable, Hashable {
    public static let name      = "flair.italic"
    public static let initial   = false
}

public struct OutlineStyle: StyleKeys, Codable, Hashable {
    public static let name      = "flair.outline"
    public static let initial   = false
}

extension Style.Keys {
    public var textAlignment: AlignmentStyle.Type {
        AlignmentStyle.self
    }
    
    public var textColor: ForegroundColorStyle.Type {
        ForegroundColorStyle.self
    }
    public var textBackgroundColor: BackgroundColorStyle.Type {
        BackgroundColorStyle.self
    }
    
    public var lineSpacing: LineSpacingStyle.Type {
        LineSpacingStyle.self
    }
    public var paragraphSpacing: ParagraphSpacingStyle.Type {
        ParagraphSpacingStyle.self
    }
    public var paragraphSpacingBefore: ParagraphSpacingBeforeStyle.Type {
        ParagraphSpacingBeforeStyle.self
    }
    public var lineHeightMultiple: LineHeightMultipleStyle.Type {
        LineHeightMultipleStyle.self
    }
    
    public var bold: BoldStyle.Type {
        BoldStyle.self
    }

    public var italic: ItalicStyle.Type {
        ItalicStyle.self
    }

    public var outline: OutlineStyle.Type {
        OutlineStyle.self
    }
    
    public var underline: UnderlineStyle.Type {
        UnderlineStyle.self
    }
    public var strikethrough: StrikethroughStyle.Type {
        StrikethroughStyle.self
    }
}
