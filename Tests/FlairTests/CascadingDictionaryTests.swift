//
//  CascadingDictionaryTests.swift
//  Flair
//
//  Created by Mark Onyschuk on 04/16/26.
//  Copyright © 2026 Dimension North Inc. All rights reserved.
//

import Testing
@testable import Flair

@Suite struct CascadingDictionaryTests {

    // MARK: - Initializers

    @Test
    func emptyInit() {
        let dict = CascadingDictionary<String, String>()
        #expect(dict.values.isEmpty)
    }

    @Test
    func cascadingInitFromTwo() {
        var parent = CascadingDictionary<String, String>()
        parent["name"] = .override("Alice")
        parent["age"] = .override("30")

        var child = CascadingDictionary<String, String>()
        child["age"] = .override("31")
        child["city"] = .override("Boston")

        let combined = CascadingDictionary<String, String>(cascading: parent, child)

        #expect(combined["name"] == .override("Alice"))
        #expect(combined["age"] == .override("31"))  // child wins
        #expect(combined["city"] == .override("Boston"))
    }

    @Test
    func cascadingInitFromVariadic() {
        var d1 = CascadingDictionary<String, String>()
        d1["a"] = .override("1")

        var d2 = CascadingDictionary<String, String>()
        d2["b"] = .override("2")

        var d3 = CascadingDictionary<String, String>()
        d3["c"] = .override("3")

        let result = CascadingDictionary(cascading: d1, d2, d3)

        #expect(result["a"] == .override("1"))
        #expect(result["b"] == .override("2"))
        #expect(result["c"] == .override("3"))
    }

    // MARK: - Subscripts

    @Test
    func subscriptReadReturnsInheritWhenAbsent() {
        let dict = CascadingDictionary<String, String>()
        #expect(dict["missing"] == .inherit)
    }

    @Test
    func subscriptWriteAndRead() {
        var dict = CascadingDictionary<String, String>()
        dict["name"] = .override("Bob")
        #expect(dict["name"] == .override("Bob"))
    }

    @Test
    func subscriptWriteInitialAndInherit() {
        var dict = CascadingDictionary<String, String>()
        dict["a"] = .initial
        dict["b"] = .inherit
        #expect(dict["a"] == .initial)
        #expect(dict["b"] == .inherit)
    }

    // MARK: - Append

    @Test
    func appendTwo() {
        var parent = CascadingDictionary<String, String>()
        parent["name"] = .override("Alice")
        parent["age"] = .override("30")

        var child = CascadingDictionary<String, String>()
        child["age"] = .override("31")
        child["city"] = .override("Boston")

        let result = parent.appending(child)

        #expect(result["name"] == .override("Alice"))
        #expect(result["age"] == .override("31"))  // child wins
        #expect(result["city"] == .override("Boston"))
    }

    @Test
    func appendThree() {
        var d1 = CascadingDictionary<String, String>()
        d1["a"] = .override("1")

        var d2 = CascadingDictionary<String, String>()
        d2["b"] = .override("2")

        var d3 = CascadingDictionary<String, String>()
        d3["c"] = .override("3")

        let result = d1.appending(d2).appending(d3)

        #expect(result["a"] == .override("1"))
        #expect(result["b"] == .override("2"))
        #expect(result["c"] == .override("3"))
    }

    @Test
    func appendPreservesInitialAndInherit() {
        var parent = CascadingDictionary<String, String>()
        parent["a"] = .initial
        parent["b"] = .inherit

        var child = CascadingDictionary<String, String>()
        child["a"] = .override("x")

        let result = parent.appending(child)

        #expect(result["a"] == .override("x"))
        // initial/inherit absent from result
        #expect(result["b"] == .inherit)
    }

    // MARK: - Prepend

    @Test
    func prependTwo() {
        var parent = CascadingDictionary<String, String>()
        parent["name"] = .override("Alice")
        parent["age"] = .override("30")

        var child = CascadingDictionary<String, String>()
        child["age"] = .override("31")
        child["city"] = .override("Boston")

        let result = parent.prepending(child)

        // child prepended means parent wins on conflict
        #expect(result["name"] == .override("Alice"))
        #expect(result["age"] == .override("30"))  // parent wins
        #expect(result["city"] == .override("Boston"))
    }

    // MARK: - Extracting

    @Test
    func extracting() {
        var dict = CascadingDictionary<String, String>()
        dict["a"] = .override("1")
        dict["b"] = .override("2")
        dict["c"] = .override("3")

        let result = dict.extracting(["a", "c"])

        #expect(result["a"] == .override("1"))
        #expect(result["c"] == .override("3"))
        #expect(result["b"] == .inherit)  // absent
    }

    // MARK: - Subtracting

    @Test
    func subtractingWithEquatable() {
        var d1 = CascadingDictionary<String, String>()
        d1["a"] = .override("1")
        d1["b"] = .override("2")
        d1["c"] = .override("3")

        var d2 = CascadingDictionary<String, String>()
        d2["a"] = .override("1")  // matches d1
        d2["b"] = .override("X")  // different value

        let result = d1.subtracting(d2)

        // a was removed (matched)
        #expect(result["a"] == .inherit)
        // b remains (different value)
        #expect(result["b"] == .override("2"))
        // c remains (not in d2)
        #expect(result["c"] == .override("3"))
    }

    @Test
    func subtractingWithCustomEquals() {
        var d1 = CascadingDictionary<String, String>()
        d1["a"] = .override("alpha")
        d1["b"] = .override("beta")
        d1["c"] = .override("gamma")

        var d2 = CascadingDictionary<String, String>()
        d2["a"] = .override("ALPHA")  // same letters, different case
        d2["b"] = .override("beta")   // exact match

        // Case-insensitive comparison
        let result = d1.subtracting(d2) { $0.lowercased() == $1.lowercased() }

        // a removed (case-insensitive match)
        #expect(result["a"] == .inherit)
        // b removed (exact match)
        #expect(result["b"] == .inherit)
        // c remains (not in d2)
        #expect(result["c"] == .override("gamma"))
    }

    @Test
    func subtractingWithInheritAndInitial() {
        var d1 = CascadingDictionary<String, String>()
        d1["a"] = .inherit
        d1["b"] = .initial

        var d2 = CascadingDictionary<String, String>()
        d2["a"] = .inherit
        d2["b"] = .initial

        let result = d1.subtracting(d2)

        // a: d2 has .inherit, so d1's .inherit is removed
        #expect(result["a"] == .inherit)
        // b: both .initial, so removed
        #expect(result["b"] == .inherit)
    }
}
