# Color Names Design

## Goal

Add a compact, localized color naming system to Flair. Given a concrete color,
Flair should produce a short display name suitable for style inspectors, menus,
popovers, labels, and other UI surfaces.

The first version names opaque colors using:

```text
[brightness modifier?] [saturation modifier?] [base color name]
```

Opacity is intentionally out of scope for the first version. A later option can
append an alpha phrase such as `66% opaque`, but the default name should remain
short.

## Source Palette

Use macOS's `NSColorList(named: "Crayons")` as the reference palette.

The crayon list is extracted once during development and committed as a package
resource. Flair must not depend on `NSColorList` at runtime, because the package
supports iOS, tvOS, and macOS.

The checked-in resource should be a property list containing one entry per
crayon color:

- stable identifier
- English source name
- sRGB red, green, blue, and alpha components
- any Apple-provided localized names that can be reliably extracted

The runtime naming system should treat the plist as the authoritative palette.

## Public Shape

Add the naming API near `Style.Color`, because that is Flair's existing
cross-platform color abstraction.

The first API is small and deterministic:

```swift
extension Style.Color {
    public var localizedName: String

    public func localizedName(locale: Locale) -> String
}
```

The common call site stays simple and does not expose extraction details.

The API only guarantees useful names for concrete RGBA colors and built-in
colors that can be resolved through `Style.Color.ref`. Dynamic semantic colors
such as `.primary`, `.secondary`, and `.accentColor` may be named from their
resolved platform color value, not from their semantic role.

## Matching

Find the nearest crayon color using perceptual distance, not raw RGB distance.

The implementation should:

1. Convert the input color from sRGB to OKLab.
2. Convert each crayon color from sRGB to OKLab.
3. Choose the crayon with the smallest OKLab distance.

OKLab is preferred because it is compact to implement, dependency-free, and a
better approximation of visual similarity than direct RGB comparison.

## Modifiers

Derive brightness and saturation modifiers from how the input color differs
from the matched crayon. The matched crayon is the midpoint for both axes.

Brightness should use HSV-style value/brightness. Saturation should use
HSV-style saturation. Compare each input value to the matched crayon's value on
the same axis.

The neutral bucket for each axis should omit that modifier. Exact crayon colors
and nearby colors should therefore use only the base crayon name. Modifiers
should appear only when the input color meaningfully varies from the base color.
This keeps the name anchored to the catalog color instead of describing every
color in absolute terms.

Modifiers should also respect whether the matched crayon already sits at an
extreme on that axis. If the base color is already very dark, do not add a
lightness/brightness modifier that would read as an opposition to the base
name. If the base color is already very light, do not add a darkness modifier
that would produce the same kind of contradiction. The same guard applies to
saturation: if the base color is already low-saturation, do not add a relative
saturation modifier on that axis. When an axis would produce a contradictory
phrase, omit that axis's modifier and let the nearest base name carry the label.

V1 buckets:

Brightness:

- much darker than base
- darker than base
- near base, omitted
- lighter than base
- much lighter than base

Saturation:

- less saturated than base
- near base, omitted
- more saturated than base

Initial thresholds:

- much darker: brightness delta below -0.30
- darker: brightness delta from -0.30 up to -0.12
- default brightness: brightness delta from -0.12 up to 0.12
- lighter: brightness delta from 0.12 up to 0.30
- much lighter: brightness delta 0.30 and above
- less saturated: saturation delta below -0.20
- default saturation: saturation delta from -0.20 up to 0.20
- more saturated: saturation delta 0.20 and above
- suppress brightness modifiers when the base brightness is below 0.20 and the
  input is lighter than the base
- suppress brightness modifiers when the base brightness is above 0.92 and the
  input is darker than the base
- suppress saturation modifiers when the base saturation is below 0.20

Threshold changes after implementation should be driven by failing or awkward
fixture names, not by ad hoc tuning.

## Localization

Flair owns runtime localization. Apple-provided crayon localizations may be
captured in the plist when available, but the display formatter should not rely
on `NSColorList` returning localized names at runtime.

Add string catalog keys for:

- crayon base names, keyed by stable palette identifier
- brightness modifiers
- saturation modifiers
- phrase formats

Phrase formats are required because languages may not use English adjective
ordering. Do not build names by blindly joining words with spaces.

The formatter should support these phrase shapes:

- base only
- brightness + base
- saturation + base
- brightness + saturation + base

For example:

```text
ColorName.Format.BaseOnly
ColorName.Format.BrightnessBase
ColorName.Format.SaturationBase
ColorName.Format.BrightnessSaturationBase
```

## Extraction Tool

Add a development-only extractor that reads `NSColorList(named: "Crayons")` on
macOS and writes the checked-in plist.

The extractor should be deterministic:

- stable output ordering
- normalized sRGB component values
- stable identifiers derived from source names
- no machine-specific paths or timestamps in output

The extractor should live under `Scripts/` as a standalone Swift script so the
runtime package does not gain an extra product solely for generation.

## Testing

Add tests for:

- loading the crayon plist
- converting known sRGB values to OKLab consistently
- nearest-crayon matching for exact crayon colors
- modifier bucketing at threshold boundaries
- compact phrase construction
- localized phrase construction for the languages currently represented in
  Flair's string catalog: English, French, German, Spanish, Italian, Polish,
  and Ukrainian

Localization tests should verify that names can be produced in each tested
language without missing-key fallbacks. They should also verify phrase ordering
through localized format strings, not through English-only string joining.

## Non-Goals

- Do not build a color picker or any UX component in this step.
- Do not add dependencies for color science.
- Do not name arbitrary opacity levels in v1.
- Do not introduce a user-editable palette model yet.
- Do not refactor existing style catalog or text styling APIs.

## Success Criteria

- Flair can load a checked-in crayon palette plist on every supported platform.
- A concrete `Style.Color` can produce a short localized display name.
- The nearest base color is chosen using perceptual OKLab distance.
- Exact and near-exact crayon colors produce the localized base color name
  without brightness or saturation modifiers.
- Brightness and saturation modifiers are applied only when the input color
  meaningfully differs from the matched crayon on that axis.
- Modifiers are suppressed when the matched crayon already sits at an axis
  extreme and the modifier would create a contradictory phrase.
- Tests cover matching, bucketing, phrase construction, and representative
  localizations.
