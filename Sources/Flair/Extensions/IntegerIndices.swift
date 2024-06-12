//
//  IntegerIndices.swift
//  Flair
//
//  Created by Mark Onyschuk on 05/29/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import Foundation

extension Collection {
    public subscript(offset: Int) -> Element {
        // Calculate the index by offsetting from startIndex
        let index = self.index(self.startIndex, offsetBy: offset)
        return self[index]
    }
    
    public subscript(range: Range<Int>) -> SubSequence {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: range.count)
        return self[startIndex..<endIndex]
    }
    
    public subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: range.count - 1)
        return self[startIndex...endIndex]
    }
    
    public subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex...]
    }
    
    public subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return self[..<endIndex]
    }
    
    public subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return self[...endIndex]
    }
}
