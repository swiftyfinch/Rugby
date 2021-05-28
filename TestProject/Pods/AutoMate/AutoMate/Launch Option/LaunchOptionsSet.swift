//
//  LaunchOptionsSet.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 30/05/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

import Foundation

/// Set for LaunchOption objects, using `uniqueIdentifier` property for hashing and comparison.
public struct LaunchOptionsSet {
    fileprivate var options: [LaunchOption]

    /// Create empty option set.
    public init() {
        options = []
    }
}

// MARK: SetAlgebra
extension LaunchOptionsSet: SetAlgebra {
    public typealias Element = LaunchOption

    /**
     Checks if set contains given element.
     - parameter member: Element to search for
     - returns: Boolean value indicating whether set contains given element.
     */
    public func contains(_ member: LaunchOption) -> Bool {
        return options.contains { $0.uniqueIdentifier == member.uniqueIdentifier }
    }

    /**
     Inserts the given element in the set if it is not already present.
     - parameter newMember: An element to insert into the set.
     - returns: `(true, newMember)` if `newMember` was not contained in the set.
     */
    public mutating func insert(_ newMember: LaunchOption) -> (inserted: Bool, memberAfterInsert: LaunchOption) {
        if let oldMember = contains(andReturns: newMember) {
            return (false, oldMember)
        }
        options.append(newMember)
        return (true, newMember)
    }

    /**
     Inserts the given element into the set unconditionally.
     - parameter newMember: An element to insert into the set.
     - returns: For ordinary sets, an element equal to `newMember` if the set already contained such a member; otherwise, `nil`.
     */
    public mutating func update(with newMember: LaunchOption) -> LaunchOption? {
        let old = remove(newMember)
        options.append(newMember)
        return old
    }

    /**
     Performs XOR operation.
     - parameter other: Set to combine with.
     - returns: Result of the operation.
     */
    public func symmetricDifference(_ other: LaunchOptionsSet) -> LaunchOptionsSet {
        var copy = self
        copy.formSymmetricDifference(other)
        return copy
    }

    /**
     Performs XOR operation.
     - parameter other: Set to combine with.
     */
    public mutating func formSymmetricDifference(_ other: LaunchOptionsSet) {
        var diff = options.filter { return !other.contains($0) }
        diff += other.filter { return !contains($0) }
        options = diff
    }

    /**
     Remove element from set.
     - parameter member: Element to remove.
     - returns: Removed element (or nil if it didn't exist).
     */
    public mutating func remove(_ member: LaunchOption) -> LaunchOption? {
        guard let index = options.firstIndex(where: { member.uniqueIdentifier == $0.uniqueIdentifier }) else { return nil }
        return options.remove(at: index)
    }

    /**
     Performs AND operation.
     - parameter other: Set to combine with.
     - returns: Result of the operation.
     */
    public func intersection(_ other: LaunchOptionsSet) -> LaunchOptionsSet {
        var copy = self
        copy.formIntersection(other)
        return copy
    }

    /**
     Performs AND operation.
     - parameter other: Set to combine with.
     */
    public mutating func formIntersection(_ other: LaunchOptionsSet) {
        options = options.filter { return other.contains($0) }
    }

    /**
     Performs OR operation.
     - parameter other: Set to combine with.
     - returns: Result of the operation.
     */
    public func union(_ other: LaunchOptionsSet) -> LaunchOptionsSet {
        var copy = self
        copy.formUnion(other)
        return copy
    }

    /**
     Performs OR operation.
     - parameter other: Set to combine with.
     */
    public mutating func formUnion(_ other: LaunchOptionsSet) {
        other.forEach({
            _ = insert($0)
        })
    }
}

// MARK: Sequence
extension LaunchOptionsSet: Sequence {
    public typealias Iterator = IndexingIterator<[LaunchOption]>

    /**
     Creates generator for collection.
     - returns: Generator to walk over elements of the set.
     */
    public func makeIterator() -> Iterator {
        return options.makeIterator()
    }
}

// MARK: Helpers
extension LaunchOptionsSet {
    /**
     Checks if set contains given element and returns it.
     - parameter member: Element to search for
     - returns: Matching elements or nil if it doesn't exists in set.
     */
    fileprivate func contains(andReturns member: LaunchOption) -> LaunchOption? {
        guard let index = options.firstIndex(where: { $0.uniqueIdentifier == member.uniqueIdentifier }) else {
            return nil
        }
        return options[index]
    }
}

// MARK: Equatable
/**
 Compares whether two option sets contain the same elements.
 - parameter lhs: Compared element.
 - parameter rhs: Compared element.
 - returns: Result of the operation.
 */
public func == (lhs: LaunchOptionsSet, rhs: LaunchOptionsSet) -> Bool {
    return lhs.elementsEqual(rhs, by: { $0.uniqueIdentifier == $1.uniqueIdentifier })
}
