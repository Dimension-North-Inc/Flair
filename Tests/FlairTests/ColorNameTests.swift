import Foundation
import Testing

@testable import Flair

@Suite struct ColorNameTests {
    @Test
    func crayonPaletteResourceLoads() throws {
        let entries = try Style.Color.CrayonPalette.loadResourceEntries()

        #expect(entries.count == 48)
        #expect(entries.first?.id == "aluminum")
        #expect(entries.first?.sourceName == "Aluminum")
        #expect(entries.contains { $0.id == "sky" && $0.sourceName == "Sky" })
    }

    @Test
    func styleColorExposesNormalizedRGBAComponents() {
        let rgba = Style.Color.rgba(0.25, 0.5, 0.75, 0.8).rgbaComponents

        #expect(rgba.red == 0.25)
        #expect(rgba.green == 0.5)
        #expect(rgba.blue == 0.75)
        #expect(rgba.alpha == 0.8)
    }

    @Test
    func oklabConversionMatchesKnownWhiteAndBlackValues() {
        let black = Style.Color.RGBA(red: 0, green: 0, blue: 0, alpha: 1).okLab
        let white = Style.Color.RGBA(red: 1, green: 1, blue: 1, alpha: 1).okLab

        #expect(abs(black.lightness - 0.0) < 0.000001)
        #expect(abs(black.a - 0.0) < 0.000001)
        #expect(abs(black.b - 0.0) < 0.000001)
        #expect(abs(white.lightness - 1.0) < 0.000001)
        #expect(abs(white.a - 0.0) < 0.000001)
        #expect(abs(white.b - 0.0) < 0.000001)
    }

    @Test
    func oklabDistanceIsZeroForIdenticalColors() {
        let color = Style.Color.RGBA(red: 0.25, green: 0.5, blue: 0.75, alpha: 1).okLab

        #expect(color.distance(to: color) == 0)
    }
}
