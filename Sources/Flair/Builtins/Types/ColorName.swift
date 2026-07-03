import Foundation

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
        static func loadResourceEntries() throws -> [CrayonColorResource] {
            guard let url = Bundle.module.url(forResource: "CrayonColors", withExtension: "plist") else {
                throw CocoaError(.fileNoSuchFile)
            }

            let data = try Data(contentsOf: url)
            return try PropertyListDecoder().decode([CrayonColorResource].self, from: data)
        }
    }
}
