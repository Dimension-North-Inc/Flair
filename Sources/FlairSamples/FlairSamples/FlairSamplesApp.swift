//
//  FlairSamplesApp.swift
//  FlairSamples
//
//  Created by Mark Onyschuk on 07/24/23.
//

import SwiftUI
import Flair

@main
struct FlairSamplesApp: App {
    var body: some Scene {
        WindowGroup {
            FlairSampleView()
        }
        .commands {
            TextFormattingCommands()
        }
    }
}

struct FlairSampleView: View {
    struct Row: Equatable, Identifiable {
        var id = UUID()
        
        var text: AttributedString = ""
        var selection: [NSRange] = []
    }
    
    @State private var rows: [Row] =
    (1...250)
        .map({ "Line \($0): Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin felis neque, semper a diam a, porttitor luctus tellus. Praesent vulputate lacus vel imperdiet consectetur. Fusce neque elit, elementum et ipsum a, tristique fringilla diam. Sed et risus ipsum. Nulla facilisi. Interdum et malesuada fames ac ante ipsum primis in faucibus. Praesent dictum vestibulum luctus. Ut vel venenatis ipsum. Aliquam vel faucibus enim. Nam porta id enim eu mattis. Suspendisse ac blandit ex. Sed velit lacus, venenatis id scelerisque sed, tempus ac nunc. Integer laoreet eros sed ipsum pulvinar feugiat. Morbi sagittis vehicula augue, non semper nisi dignissim nec." })
        .map(AttributedString.init)
        .map({ Row(text: $0) })
    
    var body: some View {
        List($rows) {
            $row in
            FlairText(
                $row.text,
                selection: $row.selection,
                options: textOptions(for: row)
            )        
            .listRowSeparator(.hidden)

        }
        .preferredColorScheme(.light)
    }

    func textOptions(for row: Row) -> FlairTextOptions {
        return FlairTextOptions.editable {
            option in
                        
            // we'll handle end editing ourselves...
            option.endsEditingOnNewline = false
            
            option.editor.performAction = {
                editor, selector in
                
                switch selector {
                    
                /// cancel editing
                case #selector(NSResponder.cancelOperation(_:)):
                    editor.window?.makeFirstResponder(editor.superview)
                    return true
                    
                /// newline handling
                case #selector(NSResponder.insertNewline(_:)):
                    if let index = rows.firstIndex(where: { row.id == $0.id }) {
                        // end editing
                        rows[index].selection = []
                        
                        // insert a new row...
                        var inserted = Row()
                        
                        inserted.text = ""
                        inserted.selection = [NSRange(location: 0, length: 0)]

                        rows.insert(inserted, at: index + 1)

                        return true
                    }
                    
                    return false
                   
                case #selector(NSResponder.insertNewlineIgnoringFieldEditor(_:)):
                    return false
                    
                /// tab handling - tab: indent, shift-tab: outdent
                case #selector(NSResponder.insertTab(_:)):
                    return true
                case #selector(NSResponder.insertBacktab(_:)):
                    return true
                default:
                    print("got \(selector)")
                    return false
                }
            }
        }
    }
}

extension FlairSampleView.Row: ExpressibleByStringLiteral {
    typealias StringLiteralType = String
    
    init(stringLiteral value: String) {
        self.init(text: AttributedString(value))
    }
}
