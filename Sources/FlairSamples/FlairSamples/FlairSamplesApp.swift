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
    
    @State private var rows: [Row] = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin felis neque, semper a diam a, porttitor luctus tellus. Praesent vulputate lacus vel imperdiet consectetur. Fusce neque elit, elementum et ipsum a, tristique fringilla diam. Sed et risus ipsum. Nulla facilisi. Interdum et malesuada fames ac ante ipsum primis in faucibus. Praesent dictum vestibulum luctus. Ut vel venenatis ipsum. Aliquam vel faucibus enim. Nam porta id enim eu mattis. Suspendisse ac blandit ex. Sed velit lacus, venenatis id scelerisque sed, tempus ac nunc. Integer laoreet eros sed ipsum pulvinar feugiat. Morbi sagittis vehicula augue, non semper nisi dignissim nec.

        Vivamus efficitur augue in nisl porta eleifend ac vitae elit. Quisque eget nisi elit. Sed molestie augue eget diam sagittis consequat quis in massa. Donec eros orci, egestas eget eleifend nec, bibendum id quam. Nam rutrum pharetra purus, vitae posuere lectus hendrerit feugiat. Etiam quis turpis odio. Duis eget turpis ac lacus porttitor pellentesque id a nisi. Phasellus dictum felis in lacus rhoncus euismod.

        Mauris quis est sit amet justo laoreet faucibus. Ut semper fermentum placerat. In efficitur, lacus id tincidunt gravida, orci ante interdum urna, eget porttitor eros nisi non turpis. In consequat luctus erat. Nulla volutpat ac tortor at gravida. Donec dapibus ligula leo. Cras vestibulum, massa a vulputate tristique, velit massa interdum lorem, vel sollicitudin neque mi sit amet dolor.

        Mauris magna eros, dictum non ultrices sed, viverra sed nisi. Integer ullamcorper, neque eget mattis dictum, tortor nulla volutpat nisl, at elementum urna ante at ex. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam vitae libero libero. Maecenas mattis ante dolor, in tempus est sodales et. Fusce ut sapien mattis eros faucibus mollis. Aenean blandit dolor ac massa volutpat, sed finibus magna sodales. Donec eleifend elit ipsum, quis dapibus dolor posuere vitae. Phasellus vehicula libero at tortor hendrerit, et tristique est cursus. Cras vitae velit varius, scelerisque enim sit amet, viverra quam. Donec eget laoreet orci. Nullam sit amet tortor non eros pharetra interdum in eget diam. Curabitur feugiat massa eu congue rhoncus. Curabitur eget interdum massa, tempus sagittis justo.

        Etiam quis dolor vitae libero gravida volutpat a at diam. Curabitur non ex ullamcorper, rhoncus massa a, hendrerit sapien. Morbi rutrum congue diam, et porttitor orci dapibus et. Pellentesque eget neque nec nunc gravida consectetur. Aenean interdum quam ac convallis congue. Aenean auctor, augue in porttitor faucibus, nisl urna ultrices magna, non mollis ante dolor gravida ipsum. Nunc vitae aliquam diam. Donec vitae vulputate ante, ac condimentum mauris. Aenean massa purus, venenatis in ligula ut, blandit vestibulum tellus. Vestibulum egestas tristique porta. Aenean elementum porta lorem, vitae iaculis augue. Aenean ultricies orci non dolor volutpat, sit amet vulputate lectus tempor. Cras molestie gravida euismod. Cras augue tellus, aliquam in felis in, rhoncus posuere lacus.

        Vivamus mollis dolor id magna tincidunt, quis sodales felis venenatis. Nunc quis lacinia felis. Donec dignissim metus mollis eros sagittis lobortis. Suspendisse sit amet nunc cursus, vehicula purus nec, vulputate nibh. Praesent dictum lectus ac dictum auctor. Integer faucibus augue ac imperdiet facilisis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Fusce mattis lacus dapibus, fermentum eros eu, cursus arcu. Donec pulvinar faucibus turpis at ullamcorper. Phasellus vitae augue sodales, tincidunt urna sit amet, ullamcorper turpis. Nunc sed sodales tellus. Nulla consequat ante sit amet justo lacinia sodales. Ut ac eros in lectus eleifend molestie vitae eget ante.

        Aenean semper aliquet dolor eget elementum. Vivamus quis leo ut nulla posuere aliquet vel vitae sem. Proin porttitor lobortis elementum. Aliquam ut commodo arcu. Aliquam vel mattis metus. Sed molestie rutrum nulla in sagittis. Mauris neque eros, imperdiet et cursus et, dapibus ut eros. Aliquam sem dolor, mattis eget nisi eget, tincidunt commodo massa.

        Duis at eros viverra turpis ullamcorper porttitor. Praesent eget suscipit mi, non lobortis nibh. Duis quis dictum odio, aliquet iaculis ante. Pellentesque in velit eu tellus tristique maximus sed vel quam. Nulla consectetur neque ac ipsum dignissim, quis cursus tellus dapibus. Nunc nulla risus, varius vitae quam non, gravida accumsan ex. Maecenas malesuada tempor augue, sit amet rutrum dui egestas vitae. In pretium nisi vel lectus tincidunt commodo. Donec nec tempus orci. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae;

        Suspendisse a hendrerit nibh, ac lacinia justo. Vivamus scelerisque vestibulum dolor, et hendrerit ante ullamcorper vel. Morbi tellus ante, dignissim ut volutpat eu, laoreet condimentum ex. Donec molestie nibh vitae urna sagittis, et ultrices urna blandit. Suspendisse accumsan viverra orci, a efficitur nisi interdum nec. Praesent nibh risus, mattis sed neque a, venenatis pulvinar ligula. Donec dictum lorem porttitor nisi varius sodales. Fusce bibendum erat ligula, quis suscipit est fringilla at. Donec euismod lacus eget nunc posuere sodales. Nulla eu blandit orci. Duis vitae est luctus, egestas augue id, euismod ex.
        """
        .split(separator:"\n")
        .map(String.init)
        .map(AttributedString.init)
        .map({ Row(text: $0) })
    
    var body: some View {
        ScrollView(.vertical) {
            ForEach($rows) {
                $row in
                FlairText(
                    $row.text,
                    selection: $row.selection,
                    options: textOptions(for: row)
                )
            }.padding()
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
