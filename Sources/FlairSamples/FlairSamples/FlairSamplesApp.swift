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
    @State private var text: String = "The Rain In Spain..."
    var body: some Scene {
        WindowGroup {
            VStack {
                FlairText($text)
                
                InspectorList {
                    FontInspector()
                }
            }
            .padding()
                .frame(maxWidth: 300)
        }
    }
}
