//
//  Dictionary+MapDictionary.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 23.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

extension Dictionary {
    /// Transforms dictionary to another one with different type keys and values.
    func mapDictionary<NewKey, NewValue>(
        transform: ((key: Key, value: Value)) throws -> (NewKey, NewValue)
    ) rethrows -> [NewKey: NewValue] {
        .init(uniqueKeysWithValues: try map(transform))
    }
}
