//
//  Dictionary.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 19/05/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

extension Dictionary {

    /**
     Inserts element from another dictionary, removing old elements in case of matching keys.

     - parameter dictionary: dictionary to copy values from.
     */
    mutating func unionInPlace(_ dictionary: [Key: Value]) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }

    /**
     Inserts element from another dictionary, removing old elements in case of matching keys.

     - parameter dictionary: dictionary to copy elements from.
     - returns: Dictionary with merged elements.
     */
    func union(_ dictionary: [Key: Value]) -> [Key: Value] {
        var copy = self
        copy.unionInPlace(dictionary)
        return copy
    }
}

extension Dictionary {

    /// Creates new `Dictionary` from array of `Dictionary.Element`s.
    ///
    /// - Parameter elements: `[Dictionary.Element]` array.
    public init(elements: [Element]) {
        self = elements.reduceToDictionary { $0 }
    }

    /// Creates new `Dictionary` by transforming values of passed `Dictionary` with given closure.
    ///
    /// - Parameters:
    ///   - original: `[OriginalKey: OriginalValue]` dictionary to transform.
    ///   - transformation: closure mapping original `Dictionary.Element` into new one.
    public init<OriginalKey, OriginalValue>(original: [OriginalKey: OriginalValue], transformation: (OriginalKey, OriginalValue) -> (Element)) {
        self.init(elements: original.map(transformation))
    }
}
