//
//  Array.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 19/05/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

public extension Array where Element: LaunchArgumentValue {

    /// Elements of the array formatter as a launch argument.
    var launchArgument: String {
        return "(\(map({ $0.value }).joined(separator: ", ")))"
    }

    /**
     Combines together two arrays of objects implementing `LaunchArgumentValue` protocol.

     - note: This works different to `+` operation, because types of arrays may differ.
     - parameter other: Other array to use in join.
     - returns: Array of combined elements.
     */
    func combine<T: LaunchArgumentValue>(values: [T]) -> [LaunchArgumentValue] {
        var combinedValues = [LaunchArgumentValue]()
        forEach { combinedValues.append($0) }
        values.forEach { combinedValues.append($0) }
        return combinedValues
    }
}

public extension Array where Element: LaunchEnvironmentValue {

    /// Elements of the array formatted as a launch environment value.
    var launchEnvironment: String {
        return map({ $0.value }).joined(separator: ",")
    }
}

public extension Array {

    /// Reduce array of tuples `(Any: Hashable, Any)` to dictionary.
    func reduceToDictionary<Key: Hashable, Value>(mapToTuple: (Element) -> (Key, Value)) -> [Key: Value] {
        return reduce([:]) {
            let tuple = mapToTuple($1)
            return $0.union([tuple.0: tuple.1])
        }
    }
}
