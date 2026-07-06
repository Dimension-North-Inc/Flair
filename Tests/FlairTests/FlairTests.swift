
import Testing
import SwiftUI

@testable import Flair

@Suite struct StyleTests {
    struct DefaultReplacementStyle: StyleKeys {
        static let name = "test.default-replacement"
        static let initial = [String: Int]()
    }

    struct MergingDictionaryStyle: StyleKeys {
        static let name = "test.merging-dictionary"
        static let initial = [String: Int]()

        static func cascade(parent: [String: Int], child: [String: Int]) -> [String: Int] {
            parent.merging(child) { _, child in child }
        }
    }
    
    @Test func stylesCanBeEncoded() {
        let pre = Style {
            $0.fontName     = .body
            $0.fontWeight   = .black
            
            $0.fontWidth    = .standard
        }
        
        let data = try! JSONEncoder().encode(pre)
        let post = try! JSONDecoder().decode(Style.self, from: data)
        
        #expect(pre == post)
    }
    
    @Test
    func stylesCanBeCascaded() {
        let s1 = Style {
            $0.fontName     = .body
            $0.fontWeight   = .black
            
            $0.fontWidth    = .standard
        }
        let s2 = Style {
            $0.textColor    = .blue
            
            $0.fontWidth    = .condensed
        }
        
        let cascade = Style(cascading: s1, s2)
        
        // s1 values
        #expect(cascade.fontName == .body)
        #expect(cascade.fontWeight == .black)
        
        // s2 values
        #expect(cascade.textColor == .blue)
        
        // override of s1 value with s2 value
        #expect(cascade.fontWidth == .condensed)
    }

    @Test
    func styleKeysReplaceChildOverrideByDefault() {
        Style.register(DefaultReplacementStyle.self)

        var parent = Style()
        parent[value: DefaultReplacementStyle.self] = ["body": 1, "caption": 2]
        var child = Style()
        child[value: DefaultReplacementStyle.self] = ["body": 3]

        let cascade = parent.appending(child)

        #expect(cascade[value: DefaultReplacementStyle.self] == ["body": 3])
    }

    @Test
    func styleKeysCanCustomizeOverrideCascade() {
        Style.register(MergingDictionaryStyle.self)

        var parent = Style()
        parent[value: MergingDictionaryStyle.self] = ["body": 1, "caption": 2]
        var child = Style()
        child[value: MergingDictionaryStyle.self] = ["body": 3, "headline": 4]

        let cascade = parent.appending(child)

        #expect(cascade[value: MergingDictionaryStyle.self] == [
            "body": 3,
            "caption": 2,
            "headline": 4
        ])
    }
    
    @Test
    func stylesCanBeSubtracted() {
        let s1 = Style {
            $0.fontName = .body
            $0.fontWeight = .black
        }
        
        let s2 = Style {
            $0.fontName = .body
            $0.fontWeight = .thin
        }
        
        let minimumDifference = s2.subtracting(s1)
        
        
        #expect(minimumDifference.fontName == FontNameStyle.initial)
        
//        #expect(minimumDifference[\.fontWeight] == .thin)
        
    }
}

@Suite struct StyleCatalogTests {
    @Test
    func styleNamesKeepStableIDWhenRenamed() {
        let id = UUID()
        var styleName = StyleName(id: id, name: "Heading 1")

        styleName.name = "Chapter Title"

        #expect(styleName.id == id)
        #expect(styleName.name == "Chapter Title")
    }

    @Test
    func styleCatalogEntriesBundleStableNameAndStyle() {
        let id = UUID()
        var style = Style()
        style.fontSize = 24

        let entry = StyleCatalog.Entry(id: id, name: "Heading 1", style: style)

        #expect(entry.id == id)
        #expect(entry.name.id == id)
        #expect(entry.name.name == "Heading 1")
        #expect(entry.style.fontSize == 24)
    }

    @Test
    func styleCatalogStoresEntriesByStableID() {
        let headingID = UUID()
        let bodyID = UUID()
        var heading = Style()
        heading.fontSize = 24
        var body = Style()
        body.fontSize = 12

        let catalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: headingID, name: "Heading", style: heading),
            StyleCatalog.Entry(id: bodyID, name: "Body", style: body)
        ])

        #expect(catalog.entries[headingID]?.name.name == "Heading")
        #expect(catalog.entries[headingID]?.style.fontSize == 24)
        #expect(catalog.entries[bodyID]?.name.name == "Body")
        #expect(catalog.entries[bodyID]?.style.fontSize == 12)
    }

    @Test
    func emptyStyleCarriesEmptyStyleCatalogByDefault() {
        let style = Style()

        #expect(style.styleCatalog == StyleCatalog())
    }

    @Test
    func missingCatalogIDReturnsEmptyStyle() {
        let catalog = StyleCatalog()

        #expect(catalog[UUID()] == Style())
    }

    @Test
    func missingCatalogNameReturnsEmptyStyle() {
        let catalog = StyleCatalog()

        #expect(catalog["Body"] == Style())
    }

    @Test
    func settingCatalogStyleByMissingNameCreatesEntry() throws {
        var catalog = StyleCatalog()
        var body = Style()
        body.fontName = .named("Arial")

        catalog["Body"] = body

        let entry = try #require(catalog.entries.values.first)
        #expect(entry.name.name == "Body")
        #expect(entry.style.fontName == .named("Arial"))
        #expect(catalog["Body"].fontName == .named("Arial"))
    }

    @Test
    func settingCatalogStyleByMissingIDCreatesEntry() {
        let id = UUID()
        var catalog = StyleCatalog()
        var body = Style()
        body.fontSize = 14

        catalog[id] = body

        #expect(catalog.entries[id]?.id == id)
        #expect(catalog.entries[id]?.name.name == id.uuidString)
        #expect(catalog[id].fontSize == 14)
    }

    @Test
    func styleCatalogSupportsNestedStyleMutationByName() {
        var style = Style()

        style.styleCatalog["Body"].fontName = .named("Arial")
        style.styleCatalog["Body"].fontSize = 14

        #expect(style.styleCatalog["Body"].fontName == .named("Arial"))
        #expect(style.styleCatalog["Body"].fontSize == 14)
        #expect(style.styleCatalog.entries.values.first?.name.name == "Body")
    }

    @Test
    func styleCatalogSupportsNestedStyleMutationByID() {
        let id = UUID()
        var style = Style()

        style.styleCatalog[id].fontSize = 18

        #expect(style.styleCatalog[id].fontSize == 18)
        #expect(style.styleCatalog.entries[id]?.name.id == id)
    }

    @Test
    func styleCatalogRemovesStyleByName() {
        var catalog = StyleCatalog()
        catalog["Body"].fontSize = 14

        catalog.removeStyle(named: "Body")

        #expect(catalog.entries.isEmpty)
        #expect(catalog["Body"] == Style())
    }

    @Test
    func styleCatalogRemoveStyleByNameNoOpsForAmbiguousName() {
        let firstID = UUID()
        let secondID = UUID()
        var catalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: firstID, name: "Body"),
            StyleCatalog.Entry(id: secondID, name: "Body")
        ])

        catalog.removeStyle(named: "Body")

        #expect(catalog.entries.keys.sorted { $0.uuidString < $1.uuidString } == [firstID, secondID].sorted { $0.uuidString < $1.uuidString })
    }

    @Test
    func styleCatalogRemovesStyleByID() {
        let id = UUID()
        var catalog = StyleCatalog()
        catalog[id].fontSize = 18

        catalog.removeStyle(id: id)

        #expect(catalog.entries[id] == nil)
        #expect(catalog[id] == Style())
    }

    @Test
    func styleCatalogReportsAvailableStyleNames() {
        let catalog = StyleCatalog(entries: [
            StyleCatalog.Entry(name: "Body"),
            StyleCatalog.Entry(name: "Heading")
        ])

        #expect(catalog.styleNames == ["Body", "Heading"])
    }

    @Test
    func styleReportsAvailableBaseStyleNamesFromItsCatalog() {
        var style = Style()
        style.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(name: "Body"),
            StyleCatalog.Entry(name: "Heading")
        ])

        #expect(style.baseStyleNames == ["Body", "Heading"])
    }

    @Test
    func styleCatalogRoundTripsThroughCodable() throws {
        let id = UUID()
        var style = Style()
        style.fontName = .body
        style.fontSize = 18
        let catalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: id, name: "Heading", style: style)
        ])

        let data = try JSONEncoder().encode(catalog)
        let restored = try JSONDecoder().decode(StyleCatalog.self, from: data)

        #expect(restored == catalog)
        #expect(restored.entries[id]?.name.name == "Heading")
        #expect(restored.entries[id]?.style.fontSize == 18)
    }

    @Test
    func styleCatalogIsAvailableAsABuiltInStyleKey() {
        let id = UUID()
        var namedStyle = Style()
        namedStyle.fontSize = 18
        var style = Style()

        style.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: id, name: "Heading", style: namedStyle)
        ])

        #expect(style.styleCatalog.entries[id]?.name.name == "Heading")
        #expect(style.styleCatalog.entries[id]?.style.fontSize == 18)
    }

    @Test
    func styleCatalogStyleCascadesEntriesByStableID() {
        let headingID = UUID()
        let bodyID = UUID()
        let captionID = UUID()
        var parentHeading = Style()
        parentHeading.fontSize = 20
        var parentBody = Style()
        parentBody.fontSize = 12
        var childHeading = Style()
        childHeading.fontSize = 24
        var childCaption = Style()
        childCaption.fontSize = 10
        var parent = Style()
        parent.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: headingID, name: "Heading", style: parentHeading),
            StyleCatalog.Entry(id: bodyID, name: "Body", style: parentBody)
        ])
        var child = Style()
        child.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: headingID, name: "Title", style: childHeading),
            StyleCatalog.Entry(id: captionID, name: "Caption", style: childCaption)
        ])

        let cascade = parent.appending(child)

        #expect(cascade.styleCatalog.entries[headingID]?.name.name == "Title")
        #expect(cascade.styleCatalog.entries[headingID]?.style.fontSize == 24)
        #expect(cascade.styleCatalog.entries[bodyID]?.name.name == "Body")
        #expect(cascade.styleCatalog.entries[bodyID]?.style.fontSize == 12)
        #expect(cascade.styleCatalog.entries[captionID]?.name.name == "Caption")
        #expect(cascade.styleCatalog.entries[captionID]?.style.fontSize == 10)
    }

    @Test
    func baseStyleIDResolvesFromEffectiveCatalogDuringCascade() {
        let bodyID = UUID()
        var bodyStyle = Style()
        bodyStyle.fontSize = 14
        bodyStyle.fontWeight = .regular
        var parent = Style()
        parent.fontName = .body
        parent.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: bodyID, name: "Body", style: bodyStyle)
        ])
        var child = Style()
        child.baseStyleID = bodyID

        let cascade = parent.appending(child)

        #expect(cascade.fontName == .body)
        #expect(cascade.fontSize == 14)
        #expect(cascade.fontWeight == .regular)
        #expect(cascade.baseStyleID == bodyID)
    }

    @Test
    func childValuesOverrideResolvedBaseStyle() {
        let headingID = UUID()
        var headingStyle = Style()
        headingStyle.fontSize = 24
        headingStyle.fontWeight = .bold
        var parent = Style()
        parent.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: headingID, name: "Heading", style: headingStyle)
        ])
        var child = Style()
        child.baseStyleID = headingID
        child.fontSize = 28

        let cascade = parent.appending(child)

        #expect(cascade.fontSize == 28)
        #expect(cascade.fontWeight == .bold)
    }

    @Test
    func missingBaseStyleIDIsNoOpDuringCascade() {
        let missingID = UUID()
        var parent = Style()
        parent.fontSize = 12
        var child = Style()
        child.baseStyleID = missingID
        child.fontWeight = .bold

        let cascade = parent.appending(child)

        #expect(cascade.fontSize == 12)
        #expect(cascade.fontWeight == .bold)
        #expect(cascade.baseStyleID == missingID)
    }

    @Test
    func baseStyleIDRoundTripsThroughCodable() throws {
        let bodyID = UUID()
        var style = Style()
        style.baseStyleID = bodyID

        let data = try JSONEncoder().encode(style)
        let restored = try JSONDecoder().decode(Style.self, from: data)

        #expect(restored.baseStyleID == bodyID)
    }

    @Test
    func baseStyleNameResolvesCurrentCatalogEntryName() {
        let bodyID = UUID()
        var style = Style()
        style.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: bodyID, name: "Body")
        ])
        style.baseStyleID = bodyID

        #expect(style.baseStyleName == "Body")
    }

    @Test
    func settingBaseStyleNameUpdatesBaseStyleIDFromCatalog() {
        let bodyID = UUID()
        let headingID = UUID()
        var style = Style()
        style.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: bodyID, name: "Body"),
            StyleCatalog.Entry(id: headingID, name: "Heading")
        ])

        style.baseStyleName = "Heading"

        #expect(style.baseStyleID == headingID)
        #expect(style.baseStyleName == "Heading")
    }

    @Test
    func settingMissingBaseStyleNameIsNoOp() {
        let bodyID = UUID()
        var style = Style()
        style.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: bodyID, name: "Body")
        ])
        style.baseStyleID = bodyID

        style.baseStyleName = "Heading"

        #expect(style.baseStyleID == bodyID)
        #expect(style.baseStyleName == "Body")
    }

    @Test
    func namedStyleDoesNotVaryWhenItsValuesMatchTheCatalogEntry() {
        let bodyID = UUID()
        var bodyStyle = Style()
        bodyStyle.fontSize = 14
        bodyStyle.fontWeight = .regular
        var style = Style()
        style.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: bodyID, name: "Body", style: bodyStyle)
        ])
        style.baseStyleID = bodyID
        style.fontSize = 14

        #expect(style.baseStyleEntry?.id == bodyID)
        #expect(style.isPureBaseStyleRepresentation)
        #expect(!style.variesFromBaseStyle)
        #expect(style.styleOverridesRelativeToBaseStyle() == Style())
    }

    @Test
    func namedStyleVariesWhenItsValuesDifferFromTheCatalogEntry() {
        let bodyID = UUID()
        var bodyStyle = Style()
        bodyStyle.fontSize = 14
        bodyStyle.fontWeight = .regular
        var style = Style()
        style.styleCatalog = StyleCatalog(entries: [
            StyleCatalog.Entry(id: bodyID, name: "Body", style: bodyStyle)
        ])
        style.baseStyleID = bodyID
        style.fontSize = 14
        style.fontWeight = .bold

        let overrides = style.styleOverridesRelativeToBaseStyle()

        #expect(!style.isPureBaseStyleRepresentation)
        #expect(style.variesFromBaseStyle)
        #expect(overrides.fontSize == FontSizeStyle.initial)
        #expect(overrides.fontWeight == .bold)
    }
}


@Suite struct SendableTests {
    @Test func testStyleIsSendable() {
        func requireSendable<T: Sendable>(_ value: T) -> T { value }
        var style = Style()
        style[value: ForegroundColorStyle.self] = .red
        _ = requireSendable(style)
    }
}

@Suite struct FontStyleTests {
    @Test
    func allStylesHaveADefaultFont() {
        let style = Style()
        #expect(style.font != nil)
    }
    
    @Test
    func stylesCanBeConvertedToFonts() {
        var style = Style()

        #expect(style.font?.pointSize == 12)
        #expect(style.font?.fontName == "Helvetica")

        style.fontSize = 14
        style.fontWeight = .bold
        #expect(style.font?.fontName == "Helvetica-Bold")

        style.fontAngle = .italic
        #expect(style.font?.fontName == "Helvetica-BoldOblique")
        
        style.fontName = .named("Helvetica Neue")
        #expect(style.font?.fontName == "HelveticaNeue-BoldItalic")
        
        #expect(style.font?.pointSize == 14)

        style.fontSize = 36
        #expect(style.font?.pointSize == 36)
    }

    @Test
    func stylesCanBeConvertedToAttributedStringRefs() {
        var style = Style()
        style.fontSize = 14
        style.fontWeight = .bold
        style.lineSpacing = 3

        let attributedString = style.attributedStringRef("Styled")
        let font = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? FontRef
        let paragraph = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle

        #expect(font?.fontName == "Helvetica-Bold")
        #expect(font?.pointSize == 14)
        #expect(paragraph?.lineSpacing == 3)
    }

    @Test
    func fontVariantCapsAppliesDescriptorFeatures() {
        var style = Style()
        style.fontVariantCaps = .allSmallCaps

        let settings = style.fontDescriptor.ref.fontAttributes[.featureSettings] as? [[FontDescriptorRef.FeatureKey: Int]]

        #expect(settings?.contains([
            .typeIdentifier: kLowerCaseType,
            .selectorIdentifier: kLowerCaseSmallCapsSelector
        ]) == true)
        #expect(settings?.contains([
            .typeIdentifier: kUpperCaseType,
            .selectorIdentifier: kUpperCaseSmallCapsSelector
        ]) == true)
    }
}
