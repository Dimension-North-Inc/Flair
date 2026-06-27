//
//  StyleCatalog.swift
//  Flair
//
//  Created by Mark Onyschuk on 2026-06-27.
//  Copyright © 2026 Dimension North Inc. All rights reserved.
//

import Foundation

public struct StyleName: Codable, Hashable, Identifiable, Sendable {
    public typealias ID = UUID

    public var id: ID
    public var name: String

    public init(id: ID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

public struct StyleCatalog: Codable, Hashable, Sendable {
    public struct Entry: Codable, Hashable, Identifiable, Sendable {
        public var name: StyleName
        public var style: Style

        public var id: StyleName.ID {
            name.id
        }

        public init(name: StyleName, style: Style = Style()) {
            self.name = name
            self.style = style
        }

        public init(id: ID = UUID(), name: String, style: Style = Style()) {
            self.init(name: StyleName(id: id, name: name), style: style)
        }
    }

    public var entries: [Entry.ID: Entry]

    public init(entries: [Entry.ID: Entry] = [:]) {
        self.entries = entries
    }

    public init(entries: some Sequence<Entry>) {
        self.entries = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
    }

    public subscript(id: Entry.ID) -> Style {
        get {
            entries[id]?.style ?? Style()
        }
        set {
            let name = entries[id]?.name ?? StyleName(id: id, name: id.uuidString)
            entries[id] = Entry(name: name, style: newValue)
        }
    }

    public subscript(name: String) -> Style {
        get {
            entry(named: name)?.style ?? Style()
        }
        set {
            let matches = entries.values.filter { $0.name.name == name }
            switch matches.count {
            case 0:
                let styleName = StyleName(name: name)
                entries[styleName.id] = Entry(name: styleName, style: newValue)
            case 1:
                guard let match = matches.first else {
                    return
                }
                entries[match.id] = Entry(name: match.name, style: newValue)
            default:
                return
            }
        }
    }

    public func entry(named name: String) -> Entry? {
        let matches = entries.values.filter { $0.name.name == name }
        guard matches.count == 1 else {
            return nil
        }

        return matches.first
    }

    public var styleNames: Set<String> {
        Set(entries.values.map(\.name.name))
    }

    public func appending(_ catalog: Self) -> Self {
        var result = self
        for (id, entry) in catalog.entries {
            result.entries[id] = entry
        }
        return result
    }
}

public struct StyleCatalogStyle: StyleKeys {
    public static let name = "flair.style-catalog"
    public static let initial = StyleCatalog()

    public static func cascade(parent: StyleCatalog, child: StyleCatalog) -> StyleCatalog {
        parent.appending(child)
    }
}

public struct BaseStyleIDStyle: StyleKeys {
    public static let name = "flair.base-style-id"
    public static let initial: StyleName.ID? = nil
}

extension Style.Keys {
    public var styleCatalog: StyleCatalogStyle.Type {
        StyleCatalogStyle.self
    }

    public var baseStyleID: BaseStyleIDStyle.Type {
        BaseStyleIDStyle.self
    }
}
