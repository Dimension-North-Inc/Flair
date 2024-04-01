//
//  TextStyles.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Foundation

public enum AlignmentStyle: StyleKeys, Codable, Hashable {
    case leading
    case trailing
    case centered
    case justified
    
    public static var name      = "flair.alignment"
    public static var initial   = Self.leading
}

public struct LineSpacingStyle: StyleKeys {
    public static var name      = "flair.line-spacing"
    public static var initial   = CGFloat(0)
}

public struct LineHeightMultipleStyle: StyleKeys {
    public static var name      = "flair.line-height-multiple"
    public static var initial   = CGFloat(0)
}

public struct ParagraphSpacingStyle: StyleKeys {
    public static var name      = "flair.paragraph-spacing"
    public static var initial   = CGFloat(0)
}

public struct ParagraphSpacingBeforeStyle: StyleKeys {
    public static var name      = "flair.paragraph-spacing-before"
    public static var initial   = CGFloat(0)
}

public struct ForegroundColorStyle: StyleKeys {
    public static var name      = "flair.foreground-color"
    public static var initial   = Style.Color.primary
}

public struct BackgroundColorStyle: StyleKeys {
    public static var name      = "flair.background-color"
    public static var initial   = Style.Color.clear
}


public enum Pattern: Codable, Hashable {
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

public enum Stroke: Codable, Hashable {
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

public struct UnderlineStyle: StyleKeys, Codable, Hashable {
    public var pattern: Pattern      = .solid
    public var stroke: Stroke        = .single
    public var words: Bool           = false
    
    public var color: Style.Color?   = nil
    
    public static var name           = "flair.underline"
    public static var initial: Self? = nil
    
    public var style: NSUnderlineStyle {
        [pattern.style, stroke.style, words ? .byWord : []]
    }
    
    public init() {}
}

public struct StrikethroughStyle: StyleKeys, Codable, Hashable {
    public var pattern: Pattern      = .solid
    public var stroke: Stroke        = .single
    public var words: Bool           = false

    public var color: Style.Color?   = nil

    public static var name           = "flair.strikethrough"
    public static var initial: Self? = nil
    
    public var style: NSUnderlineStyle {
        [pattern.style, stroke.style, words ? .byWord : []]
    }

    public init() {}
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
    
    public var underline: UnderlineStyle.Type {
        UnderlineStyle.self
    }
    public var strikethrough: StrikethroughStyle.Type {
        StrikethroughStyle.self
    }
}
