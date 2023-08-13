//
//  FontStyles.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import Foundation

extension Style.Key {
    public struct BoldStyle: StyleKeys {
        public static var name      = "flair.font.bold"
        public static var initial   = false
    }
    public struct ItalicStyle: StyleKeys {
        public static var name      = "flair.font.italic"
        public static var initial   = false
    }
    public struct UnderlineStyle: StyleKeys {
        public static var name      = "flair.font.underline"
        public static var initial   = false
    }
    public struct StrikethroughStyle: StyleKeys {
        public static var name      = "flair.font.strikethrough"
        public static var initial   = false
    }
    
    public var font: Font {
        return Font()
    }
    public struct Font {
        fileprivate init() {}
        
        public var bold: BoldStyle.Type {
            BoldStyle.self
        }
        public var italic: ItalicStyle.Type {
            ItalicStyle.self
        }
        public var underline: UnderlineStyle.Type {
            UnderlineStyle.self
        }
        public var strikethrough: StrikethroughStyle.Type {
            StrikethroughStyle.self
        }
    }
}
