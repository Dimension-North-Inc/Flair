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
            CommandGroup(replacing: .textFormatting) {
                FontMenu().options
            }
        }
    }
}

struct FlairSampleView: View {
    struct Row: Equatable, Identifiable {
        var id = UUID()
        
        var text: AttributedString = ""
        var selection: [NSRange] = []
        
        var selectedStyles: [Style] {
            selection.isEmpty ? [text.documentStyle].compactMap({ $0 }) : text.styles(in: selection)
        }
        
        mutating func mergeStyle(style: Style, operation: Style.Merge) {
            if selection.isEmpty {
                let documentStyle = text.documentStyle ?? Style()
                text.documentStyle = documentStyle.merge(style, operation)
            } else {
                text.setStyle(style, selection)
            }
            
            text = text.native
        }
    }

    @State private var rows: [Row] =
    (1...25)
        .map({ "Line \($0): Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin felis neque, semper a diam a, porttitor luctus tellus. Praesent vulputate lacus vel imperdiet consectetur. Fusce neque elit, elementum et ipsum a, tristique fringilla diam. Sed et risus ipsum. Nulla facilisi. Interdum et malesuada fames ac ante ipsum primis in faucibus." })
        .map(AttributedString.init)
        .map{
            var str = $0
            str.documentStyle = Style {
                $0.fontSize = 14
                $0.fontName = .body
                $0.lineHeightMultiple = 1.5
            }
            return Row(text: str)
        }

    @State private var selection: Set<Row.ID> = []

    var body: some View {
        List($rows, selection: $selection) {
            $row in
            FlairText(
                text: $row.text,
                selection: $row.selection,
                options: textOptions(for: row)
            )
            .focusedSceneStyles(row.selectedStyles) {
                // FIXME: this is in the wrong place...
                row.mergeStyle(style: $0, operation: $1)
            }
            .padding(.horizontal)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.white)
        }
        .focusable(true)
        .preferredColorScheme(.light)
    }
    
    func endEditing(for row: Row) -> Bool {
        guard let idx = rows.firstIndex(where: { $0.id == row.id }) else {
            return false
        }
        rows[idx].selection = []
        return true
    }
    
    func textOptions(for row: Row) -> FlairText.Options {
        return FlairText.Options {
            $0.isEditable = true
            $0.isSelectable = true
            
            $0.isRichText = true
            $0.isFieldEditor = false
            
            $0.usesRuler = true
            $0.usesFontPanel = true
            
            $0.doCommand = {
                switch $0 {
                case #selector(NSResponder.insertNewline(_:)):
                    return endEditing(for: row)
                    
                case #selector(NSResponder.insertNewlineIgnoringFieldEditor(_:)):
                    return endEditing(for: row)
                default:
                    print($0)
                }
                return false
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
