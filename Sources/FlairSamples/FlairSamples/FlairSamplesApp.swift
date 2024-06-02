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
    }
}

struct FlairSampleView: View {
    @State private var style = Style()
    @State private var selection: [NSRange] = []
    @State private var text: AttributedString = "The Rain In Spain..."
    
    private func merge(component: Style)  {
        let merged = style.appending(component)
        
        style = merged
        
        print("UPDATED STYLE: \(self.style)")
        
        var newText = text
        newText.characterStyle = self.style
        text = newText.native
        
        print("UPDATED STYLE: \(self.style)")
    }
    var body: some View {
        VStack {
            InspectorList {
                VStack(alignment: .leading) {
                    FlairText($text, selection: $selection)
                    Text("Text = \(text)")
                    Text("Selection = \(selection.debugDescription)")
                    Button("End Editing") {
                        selection = []
                    }
                    Button("Start Editing") {
                        selection = [NSRange(location: 0, length: text.characters.count)]
                    }
                }.padding(.trailing)
                FontInspector(selection: StyleSelection([style], merge: merge))
            }
            .padding()
            .frame(maxWidth: 300)
        }.preferredColorScheme(.light)
    }

}
