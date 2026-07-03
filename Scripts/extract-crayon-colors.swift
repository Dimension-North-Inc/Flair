#!/usr/bin/env swift

import AppKit
import Foundation

struct CrayonColorResource: Codable {
    let id: String
    let sourceName: String
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    let localizedNames: [String: String]
}

func stableIdentifier(for name: String) -> String {
    let allowed = CharacterSet.alphanumerics
    var result = ""
    var previousWasSeparator = false

    for scalar in name.lowercased().unicodeScalars {
        if allowed.contains(scalar) {
            result.unicodeScalars.append(scalar)
            previousWasSeparator = false
        } else if !previousWasSeparator {
            result.append("-")
            previousWasSeparator = true
        }
    }

    return result.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
}

func component(_ value: CGFloat) -> Double {
    (Double(value) * 1_000_000).rounded() / 1_000_000
}

guard let list = NSColorList(named: "Crayons") else {
    fatalError("Could not load NSColorList named Crayons")
}

let entries = list.allKeys.compactMap { name -> CrayonColorResource? in
    guard let color = list.color(withKey: name)?.usingColorSpace(.sRGB) else {
        return nil
    }

    return CrayonColorResource(
        id: stableIdentifier(for: name),
        sourceName: name,
        red: component(color.redComponent),
        green: component(color.greenComponent),
        blue: component(color.blueComponent),
        alpha: component(color.alphaComponent),
        localizedNames: ["en": name]
    )
}

let encoder = PropertyListEncoder()
encoder.outputFormat = .xml
let data = try encoder.encode(entries)

let outputURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("Sources/Flair/Resources/CrayonColors.plist")
try data.write(to: outputURL, options: .atomic)
print("Wrote \(entries.count) crayon colors to \(outputURL.path)")
