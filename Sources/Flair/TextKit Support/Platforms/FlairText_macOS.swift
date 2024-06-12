//
//  FlairText_macOS.swift
//  Flair
//
//  Created by Mark Onyschuk on 10/10/23.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI
import Combine

import Geometry

#if os(macOS)

open class FlairTextDelegate: NSObject, NSTextViewDelegate {
    public func textDidBeginEditing(_ notification: Notification) {
    }
}

extension FlairText: NSViewRepresentable {
    public func makeNSView(context: Context) -> View {
        let view = View(text: text, selection: selection, options: options) {
            (text, selection) in
            DispatchQueue.main.async {
                if !self.text.isEqual(to: text) {
                    self.text = text
                }
                if self.selection != selection {
                    self.selection = selection
                }
            }
        }
        
        view.wantsLayer = true
        view.layerContentsPlacement = .topLeft
        view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        return view
    }
    
    public func updateNSView(_ view: View, context: Context) {
        view.text       = text
        view.selection  = selection
        
        view.options    = options
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, nsView view: View, context: Context) -> CGSize? {
        guard let width = proposal.width, width != 0 else {
            return nil
        }
        
        let size = CGSize(width, .infinity)
        let boundingRect = text.boundingRect(
            with: size, options: .usesLineFragmentOrigin, context: view.context
        )
        
        return CGSize(width: width, height: ceil(boundingRect.height))
    }
}

extension FlairText {
    public final class View: NSView, NSTextViewDelegate {
        public var text: NSAttributedString {
            didSet {
                if text.isEqual(to: oldValue) {
                    return
                }
            
                // forward text to our editor, while editing...
                if let editor, let textStorage = editor.textStorage {
                    // don't set if our editor contains same - it's likely the source of the update
                    if text.isEqual(to: textStorage) {
                        return
                    }
                    
                    textStorage.beginEditing()
                    textStorage.setAttributedString(text)
                    textStorage.endEditing()

                } else {
                    setNeedsDisplay(bounds)
                }
            }
        }
        
        public var selection: [NSRange] {
            didSet {
                if selection == oldValue {
                    return
                }

                // forward selection to our editor, while editing...
                if let editor {
                    // if selection is empty - interpret as wanting to end editing
                    if selection.isEmpty {
                        endEditing(textView: editor)
                    } else {
                        // don't set if our editor's selection is same - it's likely the source of the update
                        if selection == editor.selectedRanges.map(\.rangeValue) {
                            return
                        }
                        
                        editor.selectedRanges = selection.map(NSValue.init)
                    }
                } else {
                    // if selection is non-empty - interpret as wanting to begin editing
                    if !selection.isEmpty {
                        startEditing(event: nil)
                        
                        guard let editor else { return }
                        
                        editor.selectedRanges = selection.map(NSValue.init)
                    }
                }
            }
        }

        public var options: FlairTextOptions {
            didSet {
                editor?.setOptions(options)
            }
        }
        
        public var update: (NSAttributedString, [NSRange]) -> Void
        
        public override func setFrameSize(_ newSize: NSSize) {
            let oldSize = frame.size
            super.setFrameSize(newSize)
            
            if newSize != oldSize {
                needsDisplay = true
            }
        }
        
        var context = NSStringDrawingContext()
        
        init(text: NSAttributedString,
             selection: [NSRange],
             
             options: FlairTextOptions,
             
             update: @MainActor @escaping (NSAttributedString, [NSRange]) -> Void
        ) {
            self.text = text
            self.selection = selection
            
            self.options = options
            self.update = update
            
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
            guard editor == nil else {
                return
            }

            text.draw(with: bounds, options: .usesLineFragmentOrigin, context: context)
        }
        
        // once we're installed as a view, if we have an associated selection, then begin editing...
        public override func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            
            if superview != nil, let selection = self.selection.first {
                DispatchQueue.main.async {
                    self.startEditing(event: nil, range: selection)
                }
            }
        }
        
        public override var acceptsFirstResponder: Bool {
            true
        }

        public override func mouseDown(with event: NSEvent) {
            startEditing(event: event)
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
                
                if let range {
                    editor.selectedRanges = [range].map(NSValue.init)
                }
                return
            }

            let editor = NSTextView(frame: .zero)
                        
            // make field editor display seamless
            NSAnimationContext.runAnimationGroup {
                context in
                
                context.duration = 0
                context.allowsImplicitAnimation = false
                
                autoresizesSubviews = true

                editor.frame = bounds
                editor.autoresizingMask = .width

                editor.setOptions(options)
                
                editor.drawsBackground = false
                
                editor.textContentStorage?.performEditingTransaction {
                    editor.textContentStorage?.textStorage?.setAttributedString(text)
                }
                editor.textContainerInset = .zero
                
                editor.textContainer?.lineFragmentPadding = 0
                editor.textContainer?.size.width = bounds.width
                editor.textContainer?.size.height = .infinity
                
                editor.isVerticallyResizable = true
                editor.isHorizontallyResizable = false

                self.addSubview(editor)
                window.makeFirstResponder(editor)

                editor.delegate = self

                if let range {
                    editor.setSelectedRange(range)
                }
                
                needsDisplay = true
            }
            
            if let event, options.clickSelects == .location {
                editor.mouseDown(with: event)
            } else {
                editor.selectAll(nil)
            }
        }
        
        func endEditing(textView: NSTextView) {
            assert(textView == editor)
            
            textView.delegate = nil
            textView.removeFromSuperview()
            
            needsDisplay = true
        }
        
        var editor: NSTextView? {
            subviews.compactMap({ $0 as? NSTextView }).first
        }
        
        private func updateText(_ text: NSAttributedString) {
            if !self.text.isEqual(to: text) {
                self.text = text
                self.update(text, selection)
            }
        }
        
        private func updateSelection(_ selection: [NSRange]) {
            if self.selection != selection {
                self.selection = selection
                self.update(text, selection)
            }
        }
        
        // MARK: - NSTextDelegate
        
        @objc public func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView, textView == editor else {
                return
            }

            endEditing(textView: textView)
            
            updateText(textView.attributedString())
            updateSelection([])
        }
        
        @objc public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView, textView == editor else {
                return
            }

            updateText(textView.attributedString())

            textView.sizeToFit()
            needsDisplay = true
        }
        
        // MARK: - NSTextViewDelegate

        @objc public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView, textView == editor else {
                return
            }

            updateSelection(textView.selectedRanges.map(\.rangeValue))
        }
     
        @objc public func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            guard textView == editor else {
                return false
            }
            
            return options.editor.performAction?(textView, commandSelector) ?? false
        }
    }
}

extension NSTextView {
    public func setOptions(_ options: FlairTextOptions) {
        self.allowsUndo = options.allowsUndo

        self.isRichText = options.isRichText
        self.isFieldEditor = options.endsEditingOnNewline

        self.isEditable = options.interactivity == .editable
        self.isSelectable = options.interactivity != .display
    }
}


/// A collection of optional behaviours executed while an instance of `FlairText` is being edited.
///
/// When configuring `FlairTextOptions`, access the `editor` property to add behavours
/// executed while `FlairText` is being edited.
public struct FlairTextEditingOptions {
    /// Allows `FlairTextView` users to override common editor behaviours including
    /// cursor actions, newline, tab, and backtab actions 
    public var performAction: ((NSTextView, Selector) -> Bool)?
}

#endif

#Preview {
    struct FlairTextPreview: View {
        @State var text: String = "Hello World!"
        @State var selection: [NSRange] = []
        
        var body: some View {
            VStack {
                Text("Text = \(text)")
                Text("Selection = \(selection.debugDescription)")
                
                FlairText($text, selection: $selection)
            }
                .padding()
                .preferredColorScheme(.light)
        }
    }
    
    return FlairTextPreview()
}
