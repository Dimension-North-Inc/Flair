import Foundation
import SwiftUI
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

        #expect(abs(rgba.red - Double(Float(0.25))) < 0.000001)
        #expect(abs(rgba.green - Double(Float(0.5))) < 0.000001)
        #expect(abs(rgba.blue - Double(Float(0.75))) < 0.000001)
        #expect(abs(rgba.alpha - Double(Float(0.8))) < 0.000001)
    }

    @Test
    func swiftUIColorInitializerStoresSRGBComponents() {
        let environment = EnvironmentValues()
        let color = Style.Color(SwiftUI.Color(red: 0.25, green: 0.5, blue: 0.75, opacity: 0.8), environment: environment)
        let rgba = color.rgbaComponents

        #expect(abs(rgba.red - 0.25) < 0.000001)
        #expect(abs(rgba.green - 0.5) < 0.000001)
        #expect(abs(rgba.blue - 0.75) < 0.000001)
        #expect(abs(rgba.alpha - 0.8) < 0.000001)
    }

    @Test
    func styleColorExtractsReferenceRGBAComponents() {
        let rgba = Style.Color.blue.rgbaComponents

        #expect(rgba.blue > rgba.red)
        #expect(rgba.blue > rgba.green)
        #expect(rgba.alpha == 1)
    }

    @Test
    func rgbaReportsBrightnessAndSaturation() {
        let rgba = Style.Color.RGBA(red: 0.25, green: 0.5, blue: 0.75, alpha: 1)

        #expect(rgba.brightness == 0.75)
        #expect(abs(rgba.saturation - 0.6666666667) < 0.000001)
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
