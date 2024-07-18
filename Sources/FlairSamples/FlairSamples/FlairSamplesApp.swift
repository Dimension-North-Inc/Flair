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
    }
    
    @State private var rows: [Row] =
    (1...25)
        .map({ "Line \($0): Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin felis neque, semper a diam a, porttitor luctus tellus. Praesent vulputate lacus vel imperdiet consectetur. Fusce neque elit, elementum et ipsum a, tristique fringilla diam. Sed et risus ipsum. Nulla facilisi. Interdum et malesuada fames ac ante ipsum primis in faucibus." })
        .map(AttributedString.init)
        .map({ Row(text: $0) })
    
    var body: some View {
        List($rows) {
            $row in
            FlairText(
                text: $row.text,
                selection: $row.selection,
                options: textOptions(for: row)
            )
            .listRowSeparator(.hidden)
            
        }
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
