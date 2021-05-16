//
//  Set+Inserts.swift
//  
//
//  Created by Vyacheslav Khorkov on 16.05.2021.
//

extension Set {
    /// Inserts other collection to current. It works like the `insert` method, but not like the `union`.
    func inserts<S: Sequence>(_ other: S) -> Self where S.Element == Element {
        var new = self
        other.forEach { new.insert($0) }
        return new
    }
}
