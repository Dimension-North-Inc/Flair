//
//  FlairText_iOS.swift
//  Flair
//
//  Created by Mark Onyschuk on 10/10/23.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

#if os(iOS)

// TODO: update iOS implementation

#endif

#Preview {
    @Previewable @State var text = "Hello World!"
    @Previewable @State var selection: [NSRange] = []
    FlairText(text: $text, selection: $selection).padding()
}
