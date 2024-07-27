
import Testing
import SwiftUI

@testable import Flair

@Suite struct StyleTests {
    
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
    func stylesCanBeSubtracted() {
        let s1 = Style {
            $0.fontName = .body
            $0.fontWeight = .black
        }
        
        let s2 = Style {
            $0.fontName = .body
            $0.fontWeight = .thin
        }
        
        let minimumDifference = s2.subtractingValues(in: s1)
        
        
        #expect(minimumDifference.fontName == FontNameStyle.initial)
        
//        #expect(minimumDifference[\.fontWeight] == .thin)
        
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
}
