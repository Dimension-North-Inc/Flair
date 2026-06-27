# Flair

A Swift implementation of extensible, cascading styles. Flair includes a
`Style` type, a `StyleKeys` protocol, and several prepackaged `StyleKeys` 
implementations which can be used in SwiftUI applications.

## Style
`Style` is a collection of style element keys and their associated values.
Style keys represent distinct style elements such as foreground or background
colors, font weights, border widths, or application specific display or behavioural
settings. Values are their corresponding values for the given style.

## StyleKeys
The `StyleKeys` protocol defines types which represent distinct style elements.
To implement a custom style element, declare a String `name` used to store the 
element in `Codable` containers, and an `initial` Codable value used for the style
element when it is left undefined within a style.

```swift
public protocol StyleKeys<Value> {
    associatedtype Value: Codable & Equatable
    
    /// a name used to store the element in `Codable` containers.
    static var name: String { get }
    
    /// an  initial - or default - value for the element used when it is left undefined within a style.
    static var initial: Value { get }
}

// a style whose value is a common codable type... 
struct Indentation: StyleKeys {
    static var name = "flairsamples.indentation"
    static var initial = CGFloat(42)
}

// a fully custom style value type can act as its own key...
enum CardStyle: Codable, Equatable, StyleKeys {
    case imageOnly
    case imageLeading
    case imageTrailing
    
    static var name = "flairsamples.cardstyle"
    static var initial = Self.imageLeading
}
```

### 2. Best Practice: Use `Value` for Non-Standard Types

When a style key's value type is a custom type that isn't a built-in Swift type (e.g., `Bool`, `Int`, `String`, `Double`), name the type `Value` nested inside the style struct. This avoids conflicts with SwiftUI types that share common names like `ColorScheme`, `Alignment`, `Edge`, etc., and makes the pattern consistent across all custom types.

**Example — a `ColorScheme` style without the naming convention:**
```swift
// Conflict: ColorScheme exists in SwiftUI
public enum ColorScheme: Codable, Hashable {
    case system, light, dark
}
public struct ColorSchemeStyle {
    public var scheme: ColorScheme  // compiles but shadows SwiftUI.ColorScheme
}
```

**Correct approach — use `Value` for the nested type:**
```swift
public struct ColorSchemeStyle: StyleKeys, Codable, Hashable {
    public enum Value: Codable, Hashable {
        case system, light, dark
    }
    public var value: Value
    public init(_ value: Value = .system) {
        self.value = value
    }
    public static var name: String { "outline.colorScheme" }
    public static var initial: Value { .system }
}

extension Style.Keys {
    var colorScheme: DefaultKey<ColorSchemeStyle> {
        DefaultKey(ColorSchemeStyle.name, value: ColorSchemeStyle.initial)
    }
}
```

This convention ensures that when a `DefaultKey<ColorSchemeStyle>` is used, `ColorSchemeStyle.Value` is unambiguous and doesn't shadow `SwiftUI.ColorScheme`. Apply the same pattern for any custom non-built-in type — the `Value` wrapper avoids name collisions regardless of whether the underlying type is an enum, a struct, or any other custom type.

The convention also makes call-sites natural: `IndentationStyle.Value` reads clearly and is concise. It also makes call sites searchable — searching for `.Value` across a codebase surfaces usages of custom style values without noise from generic `Any`/`AnyObject` casts.

To fetch the effective `CardStyle` within the current `Style`, use the
dynamic member lookup syntax:

```swift
// fetch the current style within your app,
// or use default style settings with an empty `Style`
let style = Style()

// use dynamic member lookup to get the style value...
let cardStyle = style.card
```

To enable this, extend `Style.Keys` with a property that returns your
`StyleKeys`-conforming type. This is the preferred pattern:

```swift
extension Style.Keys {
    /// use \.card as an alias for `CardStyle.self`
    var card: CardStyle.Type { CardStyle.self }
}

var s = Style()
s.card = .imageTrailing    // write: s[value: CardStyle.self] = .imageTrailing
let cardStyle = s.card    // read:  s[value: CardStyle.self]
```

**Note:** The `style[key: T.self]` subscript syntax also works but is
more verbose. Use dynamic member lookup (`style.card`) for clarity and
readability.

## Registration
When you define custom styles within your own application, make sure to 
register them early in the lifecycle of the application. Registration allows
the `Style` type to support custom style key names you define for your own
application when decoding styles from `Codable` containers:

```swift
import Flair
import SwiftUI

@main
struct MyApp: App {
    init() {
        Style.register(
            CardStyle.self,
            CatalogStyle.self
        )
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Cascading Styles
Given two-or-more styles, cascade them to create new styles that inherit 
style elements from predecessors. Consider a table whose rows and columns are
styled independently. Individual cell styles are derived from both row 
and column styles, where column styles supercede row styles:

```swift
var rowStyle = Style() // default or fetch
var columnStyle = Style() // default or fetch

var cellStyle = Style(cascading: rowStyle, columnStyle)

// fetch the background color
let color = cellStyle.backgroundColor
```

When cascading a list of styles, later styles will take precedence over
earlier styles in the list.

## Named Styles and Style Catalogs
Flair supports named styles without introducing a separate stylesheet object
outside of normal `Style` values. A style can carry a `StyleCatalog`, and it can
also carry a reference to one entry in that catalog through `baseStyleID`.

A catalog entry combines a stable UUID-backed `StyleName` with a `Style`.
The textual name is safe to rename because references use the stable ID:

```swift
let bodyID = UUID()

var body = Style()
body.fontName = .body
body.fontSize = 14

let bodyEntry = StyleCatalog.Entry(
    id: bodyID,
    name: "Body",
    style: body
)
```

Catalogs are themselves style values. Store one directly in any style with the
built-in `styleCatalog` key:

```swift
var documentStyle = Style()
documentStyle.styleCatalog = StyleCatalog(entries: [
    bodyEntry
])
```

Catalogs cascade by entry ID. Parent entries remain available, child entries
replace entries with the same ID, and child-only entries are added. This lets an
application define standard styles at a document, notebook, page, or item level
using the same cascade model as every other style key.

A style can opt into a named catalog entry with `baseStyleID`, or with the
UI-friendly `baseStyleName` property:

```swift
var paragraphStyle = Style()
paragraphStyle.baseStyleName = "Body"
paragraphStyle.italic = true
```

During cascade, Flair resolves the current effective catalog and inserts the
referenced entry style between the parent and child style:

```swift
// Conceptually:
// parent -> catalog entry named "Body" -> paragraphStyle
let resolved = documentStyle.appending(paragraphStyle)
```

This keeps `Style` as the only value you need to pass around. A style carries
its catalog, its base-style reference, and any local overrides together.

Several convenience APIs are available for building inspectors and pop-up menus:

```swift
let currentName = paragraphStyle.baseStyleName
let possibleNames = paragraphStyle.baseStyleNames
let entry = paragraphStyle.baseStyleEntry

if paragraphStyle.variesFromBaseStyle {
    let localOverrides = paragraphStyle.styleOverridesRelativeToBaseStyle()
}
```

`isPureBaseStyleRepresentation` is true when the style has a valid base style
and its local values do not differ from that catalog entry. `variesFromBaseStyle`
is true when the style is based on a catalog entry but has local values that
change the result. These checks ignore the catalog and base-style metadata
themselves, so UI can distinguish "Body" from "Body with local overrides".

## CascadingDictionary
`CascadingDictionary<Key, Value>` is a generic dictionary type that implements the same
cascading behavior used by `Style`. It stores values in one of three states:

- `.initial` — use the type's default value
- `.inherit` — inherit from an ancestor (absent from result in cascade)
- `.override(Value)` — explicit value that wins in cascade

This makes it suitable as a foundation for any type that needs hierarchical, cascading
state with override semantics — such as `Stylesheet`, `Theme`, or application configuration.

```swift
var parent = CascadingDictionary<String, String>()
parent["name"] = .override("Alice")
parent["age"] = .override("30")

var child = CascadingDictionary<String, String>()
child["age"] = .override("31")  // overrides parent
child["city"] = .override("Boston")

let result = parent.appending(child)
// result["name"] == "Alice"
// result["age"]  == "31"  // child wins
// result["city"] == "Boston"
```

For dictionaries with non-Equatable values, use the custom equality variant:

```swift
let diff = result.subtracting(parent) { $0 == $1 }
```

## Text Styling
A fundamental target for a styling system is styled text. Flair provides
support for text styling through custom `AttributedString` attributes, along
with helpers that resolve those attributes into native (AppKit/UIKit) or
SwiftUI attributed-string attributes for rendering.

To apply Flair styles to an entire body of attributed text, use the custom
attributed string property `.flair.paragraphStyle`. You can cascade additional 
styles onto the paragraph style by using the custom attributed string property
`.flair.characterStyle`.

```swift
var string: AttributedString = "The Rain In Spain Falls Mainly on the Plain."

// assume we have some overall style meant to be applied to a body of text
var leftAlignedBody = Style() // default or fetch

string.flair.paragraphStyle = leftAlignedBody 

// now assume we want to adjust font width and underline in a range of this text:

guard let mainly = string.rangeOf("Mainly") else { return }

var blackUnderlined = Style() // default or fetch

string[mainly].characterStyle = blackUnderlined
```

To render styled text, resolve the Flair attributes into concrete attributes
for your UI layer: use `.native` for AppKit/UIKit attributes (e.g. when bridging
to an `NSAttributedString`) or `.swiftui` for SwiftUI attributes.

```swift
let nsString = NSAttributedString(string.native)   // AppKit / UIKit
let swiftUIString = string.swiftui                  // SwiftUI Text
```

## Drag & Drop Styles
Flair adds `Transferable` support to its `Style` type, allowing you to implement
drag-and-drop of styles between interface elements like inspectors and the content
they inspect.

To take advantage of this support, make sure to add the Flair Style UTI type - 
`com.ndimensionl.flair.style` - to your application bundle's Info.plist description 
of **imported** types.

```swift
extension UTType {
    /// a namespace for `Flair` specific types
    public enum flair {
        /// flair style content type - access UTType as `.flair.style`
        public static var style: UTType { UTType(importedAs: "com.ndimensionl.flair.style") }
    }
}
```
