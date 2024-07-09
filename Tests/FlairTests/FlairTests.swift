
import Testing
import SwiftUI

@testable import Flair

@Suite struct FontStyleTests {
    @Test
    func allStylesHaveADefaultFont() {
        let style = Style()
        #expect(style.font != nil)
    }

    @Test
    func fontsCanBeConvertedToStyles() {
        var style = Style()
        
        let font  = NSFont(name: "HelveticaNeue-BoldItalic", size: 24)
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
}
