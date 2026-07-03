import Foundation
#if os(macOS)
import AppKit
#endif

extension Style.Color {
    public var localizedName: String {
        localizedName(locale: .current)
    }

    public func localizedName(locale: Locale) -> String {
        let components = nameComponents
        let base = Self.localizedString("ColorName.Base.\(components.base.id)", locale: locale)
        let brightness = components.brightness.map { modifier in
            Self.localizedString("ColorName.Brightness.\(modifier.rawValue)", locale: locale)
        }
        let saturation = components.saturation.map { modifier in
            Self.localizedString("ColorName.Saturation.\(modifier.rawValue)", locale: locale)
        }

        switch (brightness, saturation) {
        case let (.some(brightness), .some(saturation)):
            let format = Self.localizedString("ColorName.Format.BrightnessSaturationBase", locale: locale)
            return String(format: format, locale: locale, brightness, saturation, base)
        case let (.some(brightness), .none):
            let format = Self.localizedString("ColorName.Format.BrightnessBase", locale: locale)
            return String(format: format, locale: locale, brightness, base)
        case let (.none, .some(saturation)):
            let format = Self.localizedString("ColorName.Format.SaturationBase", locale: locale)
            return String(format: format, locale: locale, saturation, base)
        case (.none, .none):
            let format = Self.localizedString("ColorName.Format.BaseOnly", locale: locale)
            return String(format: format, locale: locale, base)
        }
    }

    private static func localizedString(_ key: String, locale: Locale) -> String {
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        return LocalizedCatalog.value(for: key, languageCode: languageCode) ?? key
    }

    enum BrightnessModifier: String, Hashable, Sendable {
        case muchDarker
        case darker
        case lighter
        case muchLighter
    }

    enum SaturationModifier: String, Hashable, Sendable {
        case lessSaturated
        case moreSaturated
    }

    struct NameComponents: Hashable, Sendable {
        let base: CrayonColorResource
        let brightness: BrightnessModifier?
        let saturation: SaturationModifier?
    }

    struct RGBA: Hashable, Sendable {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        var brightness: Double {
            max(red, green, blue)
        }

        var saturation: Double {
            let maximum = max(red, green, blue)
            let minimum = min(red, green, blue)
            guard maximum > 0 else { return 0 }
            return (maximum - minimum) / maximum
        }

        var okLab: OKLab {
            func linearized(_ value: Double) -> Double {
                if value <= 0.04045 {
                    return value / 12.92
                }

                return pow((value + 0.055) / 1.055, 2.4)
            }

            let r = linearized(red)
            let g = linearized(green)
            let b = linearized(blue)

            let l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
            let m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
            let s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

            let lRoot = cbrt(l)
            let mRoot = cbrt(m)
            let sRoot = cbrt(s)

            return OKLab(
                lightness: 0.2104542553 * lRoot + 0.7936177850 * mRoot - 0.0040720468 * sRoot,
                a: 1.9779984951 * lRoot - 2.4285922050 * mRoot + 0.4505937099 * sRoot,
                b: 0.0259040371 * lRoot + 0.7827717662 * mRoot - 0.8086757660 * sRoot
            )
        }
    }

    struct OKLab: Hashable, Sendable {
        let lightness: Double
        let a: Double
        let b: Double

        func distance(to other: OKLab) -> Double {
            let lightnessDelta = lightness - other.lightness
            let aDelta = a - other.a
            let bDelta = b - other.b
            return sqrt(lightnessDelta * lightnessDelta + aDelta * aDelta + bDelta * bDelta)
        }
    }

    var rgbaComponents: RGBA {
        switch self {
        case let .rgba(red, green, blue, alpha):
            return RGBA(
                red: Double(red),
                green: Double(green),
                blue: Double(blue),
                alpha: Double(alpha)
            )

        default:
            return ref.flairRGBAComponents
        }
    }

    var nameComponents: NameComponents {
        let input = rgbaComponents
        let base = CrayonPalette.nearestColor(to: input)
        return NameComponents(
            base: base,
            brightness: Self.brightnessModifier(input: input, base: base.rgba),
            saturation: Self.saturationModifier(input: input, base: base.rgba)
        )
    }

    private static func brightnessModifier(input: RGBA, base: RGBA) -> BrightnessModifier? {
        let delta = input.brightness - base.brightness

        if base.brightness < 0.20 {
            return nil
        }

        if base.brightness > 0.92 {
            return nil
        }

        if delta < -0.30 { return .muchDarker }
        if delta < -0.12 { return .darker }
        if delta < 0.12 { return nil }
        if delta < 0.30 { return .lighter }
        return .muchLighter
    }

    private static func saturationModifier(input: RGBA, base: RGBA) -> SaturationModifier? {
        let delta = input.saturation - base.saturation

        if base.saturation < 0.20 {
            return nil
        }

        if base.saturation > 0.85 {
            return nil
        }

        if delta < -0.20 { return .lessSaturated }
        if delta < 0.20 { return nil }
        return .moreSaturated
    }
}

enum LocalizedCatalog {
    struct Resource: Decodable {
        let strings: [String: Entry]
    }

    struct Entry: Decodable {
        let localizations: [String: Localization]?
    }

    struct Localization: Decodable {
        let stringUnit: StringUnit?
    }

    struct StringUnit: Decodable {
        let value: String
    }

    static let resource: Resource = {
        do {
            guard let url = Bundle.module.url(forResource: "Localizable", withExtension: "xcstrings") else {
                throw CocoaError(.fileNoSuchFile)
            }

            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Resource.self, from: data)
        } catch {
            preconditionFailure("Failed to load Localizable.xcstrings: \(error)")
        }
    }()

    static func value(for key: String, languageCode: String) -> String? {
        let entry = resource.strings[key]
        return entry?.localizations?[languageCode]?.stringUnit?.value
            ?? entry?.localizations?["en"]?.stringUnit?.value
    }
}

extension Style.Color.CrayonColorResource {
    var rgba: Style.Color.RGBA {
        Style.Color.RGBA(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension ColorRef {
    var flairRGBAComponents: Style.Color.RGBA {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        #if os(macOS)
        guard let color = usingColorSpace(.sRGB) else {
            preconditionFailure("Unable to resolve color components in sRGB")
        }
        red = color.redComponent
        green = color.greenComponent
        blue = color.blueComponent
        alpha = color.alphaComponent
        #else
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            preconditionFailure("Unable to resolve color components in sRGB")
        }
        #endif

        return Style.Color.RGBA(
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            alpha: Double(alpha)
        )
    }
}

extension Style.Color {
    struct CrayonColorResource: Codable, Hashable, Sendable {
        let id: String
        let sourceName: String
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
        let localizedNames: [String: String]
    }

    enum CrayonPalette {
        static let entries: [CrayonColorResource] = {
            do {
                return try loadResourceEntries()
            } catch {
                preconditionFailure("Failed to load CrayonColors.plist: \(error)")
            }
        }()

        static func loadResourceEntries() throws -> [CrayonColorResource] {
            guard let url = Bundle.module.url(forResource: "CrayonColors", withExtension: "plist") else {
                throw CocoaError(.fileNoSuchFile)
            }

            let data = try Data(contentsOf: url)
            return try PropertyListDecoder().decode([CrayonColorResource].self, from: data)
        }

        static func nearestColor(to color: Style.Color.RGBA) -> CrayonColorResource {
            let input = color.okLab
            guard let nearest = entries.min(by: { lhs, rhs in
                lhs.rgba.okLab.distance(to: input) < rhs.rgba.okLab.distance(to: input)
            }) else {
                preconditionFailure("CrayonColors.plist must contain at least one color")
            }
            return nearest
        }
    }
}
