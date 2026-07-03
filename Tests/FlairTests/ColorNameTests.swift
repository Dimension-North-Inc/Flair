import Foundation
import Testing

@testable import Flair

@Suite struct ColorNameTests {
    @Test
    func crayonPaletteResourceLoads() throws {
        let entries = try Style.Color.CrayonPalette.loadResourceEntries()

        #expect(entries.count == 48)
        #expect(entries.first?.id == "licorice")
        #expect(entries.first?.sourceName == "Licorice")
        #expect(entries.contains { $0.id == "sky" && $0.sourceName == "Sky" })
    }
}
