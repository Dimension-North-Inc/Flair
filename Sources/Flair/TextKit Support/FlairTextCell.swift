//
//  RichTextCell.swift
//  Flair
//
//  Created by Mark Onyschuk on 10/10/23.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

#if os(iOS)
import UIKit
typealias DrawingOptions = NSStringDrawingOptions
#elseif os(macOS)
import Cocoa
typealias DrawingOptions = NSString.DrawingOptions
#endif


extension FlairText {
    final class Cell {
        private var storage: NSAttributedString
        private var context = NSStringDrawingContext()
        
        init(_ text: AttributedString = "") {
            self.storage = text.object()
        }

        init(_ storage: NSAttributedString) {
            self.storage = storage
        }
        
        var text: AttributedString {
            get { storage.value() }
            set { storage = newValue.object() }
        }

        func size(width: CGFloat = .infinity) -> CGSize {
            let layoutSize = CGSize(
                width: width, height: .infinity
            )
            let layoutRect = storage.boundingRect(
                with: layoutSize, options: [.usesLineFragmentOrigin], context: context
            )
            
            return CGSize(
                width: ceil(layoutRect.width),
                height: ceil(layoutRect.height)
            )
        }
        
        func draw(
            at origin: CGPoint, width: CGFloat,
            context cgContext: CGContext? = nil, flipped isFlipped: Bool = true
        ) {
            let layoutSize = CGSize(
                width: width, height: .infinity
            )
            let layoutRect = CGRect(
                origin: origin, size: layoutSize
            )
            
            draw(in: layoutRect, context: cgContext, flipped: isFlipped)
        }
        
        func draw(
            in layoutRect: CGRect,
            context cgContext: CGContext? = nil, flipped: Bool = true
        ) {
            let layoutOptions: DrawingOptions = (layoutRect.height == .infinity)
            ? [.usesLineFragmentOrigin] : [.usesLineFragmentOrigin, .truncatesLastVisibleLine]
            
            if let cgContext {
#if os(iOS)
                UIGraphicsPushContext(cgContext)
                defer { UIGraphicsPopContext() }
#elseif os(macOS)
                let prev = NSGraphicsContext.current
                let next = NSGraphicsContext(cgContext: cgContext, flipped: flipped)
                
                NSGraphicsContext.current = next
                defer { NSGraphicsContext.current = prev }
#endif
                storage.draw(
                    with: layoutRect, options: layoutOptions, context: self.context
                )
            } else {
                storage.draw(
                    with: layoutRect, options: layoutOptions, context: self.context
                )
            }
        }
        
    }
}

extension FlairText.Cell: Equatable {
    static func == (lhs: FlairText.Cell, rhs: FlairText.Cell) -> Bool {
        lhs === rhs
    }
}

