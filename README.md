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
    associatedtype Value: Codable
    
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
enum CardStyle: StyleKeys, Codable {
    case imageOnly
    case imageLeading
    case imageTrailing
    
    static var name = "flairsamples.cardstyle"
    static var initial = Self.imageLeading
}
```

To fetch the effective `CardStyle` within the current `Style`,  subscript with the
StyleKey conforming type itself:

```swift
// fetch the current style within your app,
// or use default style settings with an empty `Style`
let style = Style()

// use a type-based subscript to get the style value...
let cardStyle = style[CardStyle.self] 
```

To make this all a bit less verbose, extend the `Style.Key` type 
with your `StyleKeys`-conforming type:

```swift
extension Style.Key {
    /// use \.card as an alias for `CardStyle.self`
    var card: CardStyle.Type { return CardStyle.self }
}

var s = Style()
s.card = .imageTrailing
```

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
