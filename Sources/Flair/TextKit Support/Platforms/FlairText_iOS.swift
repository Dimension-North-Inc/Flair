//
//  RichText_iOS.swift
//  Flair
//
//  Created by Mark Onyschuk on 10/10/23.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

#if os(iOS)
public typealias FlairTextDelegate = UITextViewDelegate

extension FlairText: UIViewRepresentable {
    public func makeUIView(context: Context) -> Wrapper {
        let view = Wrapper(text: text, options: options, setUpdate: { value in text = value })
        view.isOpaque = false
        return view
    }
    public func updateUIView(_ view: Wrapper, context: Context) {
        view.text = text
        view.options = options
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView view: Wrapper, context: Context) -> CGSize? {
        guard let width = proposal.width, width != 0 else {
            return nil
        }
        
        let size = CGSize(width, .infinity)
        let boundingRect = view.text.boundingRect(
            with: size, options: [.usesLineFragmentOrigin], context: view.context
        )
        
        return CGSize(width: ceil(width), height: ceil(boundingRect.height))
    }

    public final class Wrapper: UIView, UITextViewDelegate {
        var text: NSAttributedString {
            didSet {
                if !text.isEqual(to: oldValue) {
                    setNeedsDisplay()
                }
            }
        }
        
        var options: FlairTextOptions {
            didSet {
                editor?.setOptions(options)
            }
        }

        var setUpdate: (NSAttributedString) -> Void
        
        public override var frame: CGRect {
            didSet {
                if frame.size != oldValue.size {
                    setNeedsDisplay()
                }
            }
        }
        var context = NSStringDrawingContext()
        
        init(text: NSAttributedString, options: FlairTextOptions, setUpdate: @escaping (NSAttributedString) -> Void) {
            self.text = text
            self.setUpdate = setUpdate

            self.options = options
            
            super.init(frame: .zero)
        }
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        public override func draw(_ rect: CGRect) {
            text.draw(with: bounds, options: [.usesLineFragmentOrigin], context: context)
        }
        
        public override var canBecomeFirstResponder: Bool { true  }
        public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            beginEditing(touches, with: event)
        }

        var editor: TextView? {
            subviews.compactMap({ $0 as? TextView }).first
        }
        
        func beginEditing(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let editor {
                if let event {
                    editor.touchesBegan(touches, with: event)
                }
                return
            }
            
            let editor = TextView(frame: .zero)
            
            editor.frame = self.bounds
            autoresizesSubviews = true
            editor.autoresizingMask = .flexibleWidth

            editor.textStorage.setAttributedString(text)
            editor.textContainerInset = .zero

            editor.textContainer.lineFragmentPadding = 0
            editor.textContainer.size.width = bounds.width
            editor.textContainer.size.height = .infinity
                        
            editor.delegate = self

            self.addSubview(editor)
            editor.becomeFirstResponder()

            // FIXME: passthrough of touches in iOS doesn't behave as it does in Cocoa
            editor.selectAll(nil)
            
            setNeedsDisplay()
        }
        
        
        private func updateValue(_ value: NSAttributedString) {
            text = value
            setUpdate(value)
        }
        
        func endEditing(textView: UITextView) {
            guard textView.isDescendant(of: self) else {
                return
            }
            
            updateValue(textView.attributedText)

            textView.delegate = nil
            textView.removeFromSuperview()
        }

        public func textViewDidChange(_ textView: UITextView) {
            updateValue(textView.attributedText)
        }
        
        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let isNewline = text == "\n"
            
            if options.endsEditingOnNewline && isNewline {
                endEditing(textView: textView)
                return false
            } else {
                return true
            }
        }
        
        public func textViewDidEndEditing(_ textView: UITextView) {
            endEditing(textView: textView)
        }
        
    }
}

final class TextView: UITextView {
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // Run backward or forward when the user presses a left or right arrow key.
        
        var didHandleEvent = false
        for press in presses {
            guard let key = press.key else { continue }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
                didHandleEvent = false
            }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
                didHandleEvent = false
            }
        }
        
        if didHandleEvent == false {
            // Didn't handle this key press, so pass the event to the next responder.
            super.pressesBegan(presses, with: event)
        }
    }
}
extension TextView {
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

    func setOptions(_ options: FlairTextOptions) {
        self.isEditable = options.interactivity == .editable
        self.isSelectable = options.interactivity != .display
    }
}

private var flairLock = NSLock()
private var flairTextViewIDs: [ObjectIdentifier:Any] = [:]

protocol TextViewDelegate: UITextViewDelegate {
    
}

#endif

#Preview {
    FlairText<Void>("Hello World").padding()
}
