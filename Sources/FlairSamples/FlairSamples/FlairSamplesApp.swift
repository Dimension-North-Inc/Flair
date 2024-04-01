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
            InspectorList {
                FontInspector()
            }
            .padding()
            .frame(maxWidth: 300)
        }
    }
}
