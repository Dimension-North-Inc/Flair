//
//  RichText_macOS.swift
//  Flair
//
//  Created by Mark Onyschuk on 10/10/23.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Geometry

#if os(macOS)
public typealias FlairTextDelegate = NSTextViewDelegate

extension FlairText: NSViewRepresentable {
    public func makeNSView(context: Context) -> View {
        let view = View(text: text, id: id, options: options, delegate: delegate) {
            value in
            if text != value {
                text = value
            }
        }
        
        view.wantsLayer = true
        view.layerContentsPlacement = .topLeft
        view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        return view
    }
    
    public func updateNSView(_ view: View, context: Context) {
        view.text = text
        view.options = options
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, nsView view: View, context: Context) -> CGSize? {
        guard let width = proposal.width, width != 0 else {
            return nil
        }
        
        let size = CGSize(width, .infinity)
        let boundingRect = view.text.boundingRect(
            with: size, options: .usesLineFragmentOrigin, context: view.context
        )
        
        return CGSize(width: width, height: ceil(boundingRect.height))
    }

    public final class View: NSView, NSTextViewDelegate {
        var id: ID
        var text: NSAttributedString {
            didSet {
                if !text.isEqual(to: oldValue) {
                    needsDisplay = true
                }
            }
        }
                
        var options: FlairTextOptions {
            didSet {
                editor?.setOptions(options)
            }
        }
        
        var delegate: FlairTextDelegate?
        
        var setUpdate: (NSAttributedString) -> Void
        
        public override func setFrameSize(_ newSize: NSSize) {
            let oldSize = frame.size
            super.setFrameSize(newSize)
            
            if newSize != oldSize {
                needsDisplay = true
            }
        }
        
        var context = NSStringDrawingContext()
        
        init(text: NSAttributedString, id: ID, options: FlairTextOptions, delegate: FlairTextDelegate? = nil, setUpdate: @escaping (NSAttributedString) -> Void) {
            self.id = id
            self.text = text
            self.setUpdate = setUpdate
            
            self.options = options
            
            super.init(frame: .zero)
            self.wantsLayer = true
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        public override var isOpaque: Bool {
            false
        }
        public override var isFlipped: Bool {
            true
        }
        public override func draw(_ dirtyRect: NSRect) {
            if editor != nil { return }

            text.draw(with: bounds, options: .usesLineFragmentOrigin, context: context)
        }
        
        public override var acceptsFirstResponder: Bool {
            true
        }

        public override func mouseDown(with event: NSEvent) {
            startEditing(event: event)
        }
        
        
        var editor: NSTextView? {
            subviews.compactMap({ $0 as? NSTextView }).first
        }
        
        func startEditing(event: NSEvent?, range: NSRange? = nil) {
            guard
                let window,
                options.interactivity != .display
            else {
                return
            }
            
            if let editor {
                if let event {
                    editor.mouseDown(with: event)
                }
                return
            }

            let editor = NSTextView(frame: .zero)
            
            editor.flairID = id
            
            // NOTE: We use `runInAnimationGroup`  instead of
            // old NSWindow API `window.disableFlushWindow()` &
            // `window.reenableFlushWindow(); window.flushWindow()`

            NSAnimationContext.runAnimationGroup {
                context in
                
                context.duration = 0
                context.allowsImplicitAnimation = false
                
                autoresizesSubviews = true

                editor.frame = bounds
                editor.autoresizingMask = .width

                editor.setOptions(options)
                
                editor.drawsBackground = false
                
                editor.textStorage?.setAttributedString(text)
                editor.textContainerInset = .zero
                
                editor.textContainer?.lineFragmentPadding = 0
                editor.textContainer?.size.width = bounds.width
                editor.textContainer?.size.height = .infinity
                
                editor.isVerticallyResizable = true
                editor.isHorizontallyResizable = false

                self.addSubview(editor)
                window.makeFirstResponder(editor)

                // editor.delegate = self
                editor.delegate = delegate

                // FIXME: hack
                delegate?.textDidBeginEditing?(
                    Notification(name: NSText.didBeginEditingNotification, object: editor)
                )
                
                let nc = NotificationCenter.default
                nc.addObserver(
                    self, selector: #selector(textDidChange(_:)),
                    name: NSText.didChangeNotification, object: editor
                )
                nc.addObserver(
                    self, selector: #selector(textDidEndEditing(_:)),
                    name: NSText.didEndEditingNotification, object: editor
                )

                if let range {
                    editor.setSelectedRange(range)
                }
                
                needsDisplay = true
            }

            if let event {
                editor.mouseDown(with: event)
            } else {
                editor.selectAll(nil)
            }
            
        }
        
        func endEditing(textView: NSTextView) {
            guard textView.isDescendant(of: self) else {
                return
            }
            
            //textView.delegate = nil
            textView.delegate = nil

            let nc = NotificationCenter.default
            nc.removeObserver(self, name: nil, object: textView)
            
            textView.removeFromSuperview()
            
            needsDisplay = true
        }
        
        private func updateText(_ attributedString: NSAttributedString) {
            self.text = attributedString
            self.setUpdate(attributedString)
        }
        

        public func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            updateText(textView.attributedString())
            endEditing(textView: textView)
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            updateText(textView.attributedString())

            textView.sizeToFit()
            needsDisplay = true
        }
    }
}

extension NSTextView {
    public fileprivate(set) var flairID: Any? {
        get {
            flairLock.withLock {
                flairTextViewIDs[ObjectIdentifier(self)]
            }
        }
        set {
            flairLock.withLock {
                flairTextViewIDs[ObjectIdentifier(self)] = newValue
            }
        }
    }

    public func setOptions(_ options: FlairTextOptions) {
        self.allowsUndo = options.allowsUndo

        self.isRichText = options.isRichText
        self.isFieldEditor = options.endsEditingOnNewline

        self.isEditable = options.interactivity == .editable
        self.isSelectable = options.interactivity != .display
    }
}

private var flairLock = NSLock()
private var flairTextViewIDs: [ObjectIdentifier:Any] = [:]

#endif

#Preview {
    FreeFlairText("Hello World", selectable: true).padding()
}
