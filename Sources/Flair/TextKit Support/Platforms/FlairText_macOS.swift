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
        View(host: self)
    }
    
    public func updateNSView(_ view: View, context: Context) {
        view.host = self
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, nsView view: View, context: Context) -> CGSize? {
        guard let width = proposal.width else {
            return nil
        }
        
        let height = text.boundingRect(
            with: NSMakeSize(width, 1e6),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        ).height
                
        return CGSizeMake(width, height)
    }
}

extension FlairText {
    public final class View: NSClipView, NSTextViewDelegate {
        var host: FlairText {
            didSet {
                if !text.isEqual(to: host.text) {
                    text = host.text
                }
                if selection != host.selection {
                    selection = host.selection
                }
            }
        }
        
        func updateHost() {
            if !host.text.isEqual(to: text) {
                host.text = text
            }
            if host.selection != selection {
                host.selection = selection
            }
        }

        private var selection: [NSRange] = [] {
            didSet {
                if selection.isEmpty {
                    if editor != nil {
                        endEditing()
                    }
                } else {
                    if editor == nil {
                        beginEditing(event: nil, selection: selection)
                    }
                }
            }
        }
        
        private var text: NSAttributedString = NSAttributedString() {
            didSet {
                if !text.isEqual(to: oldValue) {
                    needsDisplay = true
                }
            }
        }
        
        public init(host: FlairText) {
            self.host       = host
            
            self.text       = host.text
            self.selection  = host.selection
            
            super.init(frame: .zero)
            
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("\(#function) unimplemented")
        }
        
        // MARK: - Lifecycle
        public override func viewDidMoveToWindow() {
            if superview != nil && !selection.isEmpty {
                beginEditing(event: nil, selection: selection)
            }
        }
        
        // MARK: - Events
        public override var acceptsFirstResponder: Bool {
            true
        }
        
        public override func mouseDown(with event: NSEvent) {
            beginEditing(event: event, selection: selection)
        }
        
        // MARK: - Editing
        public var editor: Editor? {
            subviews
                .compactMap { $0 as? Editor }
                .first
        }
        
        public func beginEditing(event: NSEvent?, selection: [NSRange]) {
            // update existing editor, if any
            if let editor {
                if let event {
                    editor.mouseDown(with: event)
                } else if !selection.isEmpty {
                    editor.selectedRanges = selection.map(NSValue.init)
                }
                
            } else if let window {
                let textEditor = Editor(frame: bounds)
                let textContainer = textEditor.textContainer
                
                textContainer?.lineFragmentPadding = .zero
                
                textEditor.wantsLayer           = true
                
                autoresizesSubviews             = true
                textEditor.autoresizingMask     = [.width, .height]
                
                textEditor.isRichText           = host.options.isRichText
                
                textEditor.isEditable           = host.options.isEditable
                textEditor.isSelectable         = host.options.isSelectable
                
                textEditor.usesRuler            = host.options.usesRuler
                textEditor.usesFontPanel        = host.options.usesFontPanel
                
                textEditor.isFieldEditor        = host.options.isFieldEditor
                
                textEditor.importsGraphics      = host.options.importsGraphics
                textEditor.allowsImageEditing   = host.options.allowsImageEditing
                
                textEditor.usesAdaptiveColorMappingForDarkAppearance = host.options.usesAdaptiveColorMappingForDarkAppearance
                
                textEditor.text                 = text
                textEditor.delegate             = self
                
                addSubview(textEditor)
                window.makeFirstResponder(textEditor)
                
                if selection.isEmpty {
                    textEditor.selectAll(nil)
                } else  {
                    textEditor.selectedRanges = selection.map(NSValue.init)
                }
            }
        }
                
        public func endEditing() {
            guard let editor else {
                return
            }
            
            editor.delegate = nil
            editor.removeFromSuperview()
            
            text = editor.text
            selection = []
            updateHost()
            
            setNeedsDisplay(bounds)
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let editor else {
                return
            }
            
            text = editor.text
            updateHost()
        }
        
        public func textViewDidChangeSelection(_ notification: Notification) {
            guard let editor else {
                return
            }
            
            selection = editor.selectedRanges.map(\.rangeValue)
            updateHost()
        }
        
        public func textDidEndEditing(_ notification: Notification) {
            endEditing()
        }
        
        public func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            return host.options.doCommand?(commandSelector) ?? false
        }
        
        // MARK: - Drawing
        public override var isOpaque: Bool {
            false
        }
        public override var isFlipped: Bool {
            true
        }
        
        public override func draw(_ dirtyRect: NSRect) {
            if editor != nil {
                return
            }
            text.draw(
                with: bounds,
                options: [.usesFontLeading, .usesLineFragmentOrigin],
                context: nil
            )
        }
    }
}

extension FlairText {
    public final class Editor: NSTextView {
        public var text: NSAttributedString {
            get {
                attributedString()
            }
            set {
                if let textStorage {
                    textStorage.edit {
                        textStorage.setAttributedString(newValue)
                    }
                }
            }
        }
        
        public override func alignLeft(_ sender: Any?) {
            align(.left)
        }
        public override func alignRight(_ sender: Any?) {
            align(.right)
        }
        public override func alignCenter(_ sender: Any?) {
            align(.center)
        }
        public override func alignJustified(_ sender: Any?) {
            align(.justified)
        }
        
        private func align(_ alignment: NSTextAlignment) {
            guard let textStorage else {
                return
            }
            
            textStorage.edit {
                let paragraphStyle = NSMutableParagraphStyle(); paragraphStyle.alignment = alignment
                textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: selectedRange)
            }
            
            setNeedsDisplay(self.bounds)
        }
    }
}

extension NSTextStorage {
    public func edit(transaction: () -> Void) {
        beginEditing()
        transaction()
        endEditing()
    }
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
                
                FlairText(text: $text, selection: $selection)
            }
            .padding()
            .preferredColorScheme(.light)
        }
    }
    
    return FlairTextPreview()
}
