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

## Text Styling
A fundamental target for a styling system is styled text. Flair provides
comprehensive support for text styling with custom AttributedString attributes
and a custom TextKit2 text stack for style rendering.

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

## FlairText SwiftUI View
`FlairText` is a SwiftUI text `View` that is aware of `Flair` text attributes.

The view is generally more capable dealing with rich text than `SwiftUI.TextField` or
`SwiftUI.TextView` and is a more capable implementation of a text editing component.

## Inspectors
Flair provides support for `Style` inspection in SwiftUI applications.

A `focusable()` component whose style selection is meant to be inspected can declare a
list of selected styles in its `body` definition, for inspectors to inspect. The declaration
includes both the list of selected styles, as well as a function used to merge new styles into 
this selection:

```swift
    var body: some View {
        List {
            ForEach(rows) {
                row in 
                RowView(row)
                    .focusable()
                    .selectedStyles([row.styles]) {
                        style in // perform some action to merge this style into the selection
                    }   
            }
        }
    }
```

Inspectors themselves are meant to be displayed within an `InspectorList` component:


```swift
import Flair
import SwiftUI

struct AppInspector: View {
    var body: some View {
        InspectorList {
            // Flair font inspector
            FontInspector()

            AppCustomInspector()
        }
    }
}

struct AppCustomInspector: View {
    // fetch the current focused selection
    @FocusedValue(\.styles) var style: StyleSelection
    
    var body: some View {
        Inspector("Document") {
            // interact with styles here - 
        }
    }
}
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

