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

    @Test
    func exactCrayonColorMatchesItselfWithoutModifiers() throws {
        let skyBlue = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "sky" })
        let components = Style.Color.rgba(
            Float(skyBlue.red),
            Float(skyBlue.green),
            Float(skyBlue.blue),
            Float(skyBlue.alpha)
        ).nameComponents

        #expect(components.base.id == "sky")
        #expect(components.brightness == nil)
        #expect(components.saturation == nil)
    }

    @Test
    func nearbyCrayonColorKeepsBaseNameWithoutModifiers() throws {
        let skyBlue = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "sky" })
        let components = Style.Color.rgba(
            Float(min(skyBlue.red + 0.03, 1.0)),
            Float(min(skyBlue.green + 0.03, 1.0)),
            Float(min(skyBlue.blue + 0.03, 1.0)),
            Float(skyBlue.alpha)
        ).nameComponents

        #expect(components.base.id == "sky")
        #expect(components.brightness == nil)
        #expect(components.saturation == nil)
    }

    @Test
    func brightnessModifiersAreRelativeToMatchedBase() throws {
        let clover = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "clover" })
        let darker = Style.Color.rgba(
            Float(max(clover.red - 0.18, 0.0)),
            Float(max(clover.green - 0.18, 0.0)),
            Float(max(clover.blue - 0.18, 0.0)),
            1
        ).nameComponents

        #expect(darker.base.id == "clover")
        #expect(darker.brightness == .muchDarker || darker.brightness == .darker)
    }

    @Test
    func saturationModifiersAreRelativeToMatchedBase() throws {
        let skyBlue = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "sky" })
        let base = Style.Color.rgba(
            Float(skyBlue.red),
            Float(skyBlue.green),
            Float(skyBlue.blue),
            Float(skyBlue.alpha)
        ).nameComponents
        let vivid = Style.Color.rgba(
            Float(max(skyBlue.red - 0.25, 0.0)),
            Float(max(skyBlue.green - 0.10, 0.0)),
            Float(max(skyBlue.blue - 0.15, 0.0)),
            1
        ).nameComponents

        #expect(vivid.base.id == base.base.id)
        #expect(base.saturation == nil)
        #expect(vivid.saturation == .moreSaturated)
    }

    @Test
    func brightnessModifierIsSuppressedForDarkBaseColorMadeLighter() throws {
        let licorice = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "licorice" })
        let components = Style.Color.rgba(
            Float(min(licorice.red + 0.02, 1.0)),
            Float(min(licorice.green + 0.02, 1.0)),
            Float(min(licorice.blue + 0.02, 1.0)),
            1
        ).nameComponents

        #expect(components.base.id == "licorice")
        #expect(components.brightness == nil)
    }

    @Test
    func brightnessModifierIsSuppressedForLightBaseColorMadeDarker() throws {
        let snow = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "snow" })
        let components = Style.Color.rgba(
            Float(max(snow.red - 0.02, 0.0)),
            Float(max(snow.green - 0.02, 0.0)),
            Float(max(snow.blue - 0.02, 0.0)),
            1
        ).nameComponents

        #expect(components.base.id == "snow")
        #expect(components.brightness == nil)
    }

    @Test
    func brightnessModifierIsSuppressedForDarkBaseColorMadeDarker() throws {
        let licorice = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "licorice" })
        let components = Style.Color.rgba(
            Float(max(licorice.red - 0.05, 0.0)),
            Float(max(licorice.green - 0.05, 0.0)),
            Float(max(licorice.blue - 0.05, 0.0)),
            1
        ).nameComponents

        #expect(components.base.id == "licorice")
        #expect(components.brightness == nil)
    }

    @Test
    func saturationModifierIsSuppressedForLowSaturationBaseColor() throws {
        let silver = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "silver" })
        let components = Style.Color.rgba(
            Float(min(silver.red + 0.10, 1.0)),
            Float(silver.green),
            Float(max(silver.blue - 0.10, 0.0)),
            1
        ).nameComponents

        #expect(components.base.id == "silver")
        #expect(components.saturation == nil)
    }

    @Test
    func saturationModifierIsSuppressedForHighSaturationBaseColor() throws {
        let lemon = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "lemon" })
        let components = Style.Color.rgba(
            Float(max(lemon.red - 0.10, 0.0)),
            Float(lemon.green),
            Float(min(lemon.blue + 0.10, 1.0)),
            1
        ).nameComponents

        #expect(components.base.id == "lemon")
        #expect(components.saturation == nil)
    }

    @Test
    func exactCrayonLocalizedNameUsesBaseOnly() {
        let name = Style.Color.rgba(0, 0, 0, 1).localizedName(locale: Locale(identifier: "en"))

        #expect(name == "Licorice")
    }

    @Test
    func modifiedColorLocalizedNameUsesRelativeModifiers() throws {
        let clover = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "clover" })
        let name = Style.Color.rgba(
            Float(max(clover.red - 0.18, 0.0)),
            Float(max(clover.green - 0.18, 0.0)),
            Float(max(clover.blue - 0.18, 0.0)),
            1
        ).localizedName(locale: Locale(identifier: "en"))

        #expect(!name.isEmpty)
        #expect(!name.contains("ColorName."))
    }

    @Test
    func localizedNamesExistForSupportedLanguages() {
        let locales = ["en", "fr", "de", "es", "it", "pl", "uk"].map(Locale.init(identifier:))

        for locale in locales {
            let name = Style.Color.rgba(0, 0, 0, 1).localizedName(locale: locale)

            #expect(!name.isEmpty)
            #expect(!name.contains("ColorName."))
        }
    }

    @Test
    func formatterUsesLocalizedPhraseTemplates() throws {
        let clover = try #require(Style.Color.CrayonPalette.loadResourceEntries().first { $0.id == "clover" })
        let modified = Style.Color.rgba(
            Float(max(clover.red - 0.18, 0.0)),
            Float(max(clover.green - 0.18, 0.0)),
            Float(max(clover.blue - 0.18, 0.0)),
            1
        )
        let english = modified.localizedName(locale: Locale(identifier: "en"))
        let french = modified.localizedName(locale: Locale(identifier: "fr"))

        #expect(english == "darker Clover")
        #expect(french == "Clover plus foncé")
    }
}
