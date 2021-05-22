//
//  Dictionary+MapDictionary.swift
//  
//
//  Created by Vyacheslav Khorkov on 23.05.2021.
//

extension Dictionary {
    /// Transforms dictionary to another one with different type keys and values.
    func mapDictionary<NewKey, NewValue>(
        transform: ((key: Key, value: Value)) throws -> (NewKey, NewValue)
    ) rethrows -> Dictionary<NewKey, NewValue> {
        .init(uniqueKeysWithValues: try map(transform))
    }
}
