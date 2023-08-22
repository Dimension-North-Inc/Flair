//
//  TextStyles.swift
//  Flair
//
//  Created by Mark Onyschuk on 07/26/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import Foundation

extension Style.Key {
    public enum AlignmentStyle: StyleKeys, Codable {
        case leading
        case trailing
        case centered
        case justified

        public static var name      = "flair.text.alignment"
        public static var initial   = Self.leading
    }
    
    public struct ForegroundColorStyle: StyleKeys {
        public static var name      = "flair.text.color"
        public static var initial   = Color.primary
    }
    
    public struct BackgroundColorStyle: StyleKeys {
        public static var name      = "flair.text.background-color"
        public static var initial   = Color.clear
    }
    
    public var text: Text {
        return Text()
    }
    public struct Text {
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
    }
}
