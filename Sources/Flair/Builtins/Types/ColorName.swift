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

    struct NameCandidate: Hashable, Sendable {
        let components: NameComponents
        let rgba: RGBA

        func score(for input: OKLab) -> Double {
            var score = rgba.okLab.distance(to: input)
            switch components.brightness {
            case .muchDarker, .muchLighter:
                break
            case .darker, .lighter:
                score += 0.02
            case nil:
                break
            }
            if components.saturation != nil { score += 0.02 }
            return score
        }
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

        func adjusted(brightness: Double? = nil, saturation: Double? = nil) -> RGBA {
            let adjustedBrightness = max(0, min(brightness ?? self.brightness, 1))
            let adjustedSaturation = max(0, min(saturation ?? self.saturation, 1))

            guard adjustedSaturation > 0, let hue else {
                return RGBA(
                    red: adjustedBrightness,
                    green: adjustedBrightness,
                    blue: adjustedBrightness,
                    alpha: alpha
                )
            }

            let sector = hue * 6
            let integerSector = floor(sector)
            let fraction = sector - integerSector
            let p = adjustedBrightness * (1 - adjustedSaturation)
            let q = adjustedBrightness * (1 - adjustedSaturation * fraction)
            let t = adjustedBrightness * (1 - adjustedSaturation * (1 - fraction))

            switch Int(integerSector) % 6 {
            case 0:
                return RGBA(red: adjustedBrightness, green: t, blue: p, alpha: alpha)
            case 1:
                return RGBA(red: q, green: adjustedBrightness, blue: p, alpha: alpha)
            case 2:
                return RGBA(red: p, green: adjustedBrightness, blue: t, alpha: alpha)
            case 3:
                return RGBA(red: p, green: q, blue: adjustedBrightness, alpha: alpha)
            case 4:
                return RGBA(red: t, green: p, blue: adjustedBrightness, alpha: alpha)
            default:
                return RGBA(red: adjustedBrightness, green: p, blue: q, alpha: alpha)
            }
        }

        private var hue: Double? {
            let maximum = max(red, green, blue)
            let minimum = min(red, green, blue)
            let chroma = maximum - minimum
            guard chroma > 0 else { return nil }

            let rawHue: Double
            if maximum == red {
                rawHue = ((green - blue) / chroma).truncatingRemainder(dividingBy: 6)
            } else if maximum == green {
                rawHue = ((blue - red) / chroma) + 2
            } else {
                rawHue = ((red - green) / chroma) + 4
            }

            let normalized = rawHue / 6
            return normalized < 0 ? normalized + 1 : normalized
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
        let inputOKLab = input.okLab
        let nearestBase = CrayonPalette.nearestColor(to: input)

        if Self.shouldPreserveExtremeBase(input: input, base: nearestBase.rgba) {
            return NameComponents(base: nearestBase, brightness: nil, saturation: nil)
        }

        guard let candidate = Self.nameCandidates.min(by: { lhs, rhs in
            lhs.score(for: inputOKLab) < rhs.score(for: inputOKLab)
        }) else {
            preconditionFailure("CrayonColors.plist must contain at least one color")
        }

        return candidate.components
    }

    private static func shouldPreserveExtremeBase(input: RGBA, base: RGBA) -> Bool {
        let isExtreme = base.brightness < 0.20
            || base.brightness > 0.92
            || base.saturation < 0.20
            || base.saturation > 0.85

        guard isExtreme else { return false }

        return abs(input.brightness - base.brightness) < 0.08
            && abs(input.saturation - base.saturation) < 0.15
    }

    private static let nameCandidates: [NameCandidate] = {
        CrayonPalette.entries.flatMap { base in
            let baseRGBA = base.rgba
            let brightnessModifiers = brightnessCandidateModifiers(for: baseRGBA)
            let saturationModifiers = saturationCandidateModifiers(for: baseRGBA)

            return brightnessModifiers.flatMap { brightness in
                saturationModifiers.map { saturation in
                    NameCandidate(
                        components: NameComponents(base: base, brightness: brightness, saturation: saturation),
                        rgba: baseRGBA.adjusted(
                            brightness: brightness.map { brightnessTarget(for: $0, base: baseRGBA) },
                            saturation: saturation.map { saturationTarget(for: $0, base: baseRGBA) }
                        )
                    )
                }
            }
        }
    }()

    private static func brightnessCandidateModifiers(for base: RGBA) -> [BrightnessModifier?] {
        if base.brightness < 0.20 {
            return [nil]
        }

        if base.brightness > 0.92 {
            return [nil]
        }

        return [nil, .muchDarker, .darker, .lighter, .muchLighter]
    }

    private static func saturationCandidateModifiers(for base: RGBA) -> [SaturationModifier?] {
        if base.saturation < 0.20 {
            return [nil]
        }

        if base.saturation > 0.85 {
            return [nil]
        }

        return [nil, .lessSaturated, .moreSaturated]
    }

    private static func brightnessTarget(for modifier: BrightnessModifier, base: RGBA) -> Double {
        switch modifier {
        case .muchDarker:
            return base.brightness - 0.38
        case .darker:
            return base.brightness - 0.20
        case .lighter:
            return base.brightness + 0.20
        case .muchLighter:
            return base.brightness + 0.38
        }
    }

    private static func saturationTarget(for modifier: SaturationModifier, base: RGBA) -> Double {
        switch modifier {
        case .lessSaturated:
            return base.saturation - 0.35
        case .moreSaturated:
            return base.saturation + 0.35
        }
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
