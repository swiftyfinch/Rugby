//
//  Optional+Unwrap.swift
//  
//
//  Created by v.khorkov on 17.01.2021.
//

protocol OptionalType {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    var optional: Self { self }
}

extension Optional {
    func unwrap(orThrow error: Error) throws -> Wrapped {
        guard let unwrapped = self else { throw error }
        return unwrapped
    }
}

extension Optional where Wrapped: OptionalType {
    func unwrap(orThrow error: Error) throws -> Wrapped.Wrapped {
        guard let unwrapped = self as? Wrapped.Wrapped else { throw error }
        return unwrapped
    }
}
