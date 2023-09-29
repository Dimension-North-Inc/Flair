//
//  TextStyles.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Foundation

extension Style.Key {
    public enum AlignmentStyle: StyleKeys, Codable {
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
        public static var initial   = Color.primary
    }
    
    public struct BackgroundColorStyle: StyleKeys {
        public static var name      = "flair.background-color"
        public static var initial   = Color.clear
    }
    
    public var text: TextKeys {
        return TextKeys()
    }
    public struct TextKeys {
        fileprivate init() {}
        
        public var alignment: AlignmentStyle.Type {
            AlignmentStyle.self
        }
        
        public var color: ForegroundColorStyle.Type {
            ForegroundColorStyle.self
        }
        public var backgroundColor: BackgroundColorStyle.Type {
            BackgroundColorStyle.self
        }

        public var lineSpacing: LineSpacingStyle.Type {
            LineSpacingStyle.self
        }
        public var lineHeightMultiple: LineHeightMultipleStyle.Type {
            LineHeightMultipleStyle.self
        }

        public var paragraphSpacing: ParagraphSpacingStyle.Type {
            ParagraphSpacingStyle.self
        }
        public var paragraphiSpacingBefore: ParagraphSpacingBeforeStyle.Type {
            ParagraphSpacingBeforeStyle.self
        }
    }
}

extension Style {
    var paragraphStyle: NSParagraphStyle {
        let result = NSMutableParagraphStyle()
        
        switch self[\.text.alignment] {
        case .leading:   result.alignment = .left
        case .trailing:  result.alignment = .right
        case .centered:  result.alignment = .center
        case .justified: result.alignment = .justified
        }
        
        result.lineSpacing = self[\.text.lineSpacing]
        result.paragraphSpacing = self[\.text.paragraphSpacing]
        result.paragraphSpacingBefore = self[\.text.paragraphiSpacingBefore]
        
        result.lineHeightMultiple = self[\.text.lineHeightMultiple]

        return result
    }
}
