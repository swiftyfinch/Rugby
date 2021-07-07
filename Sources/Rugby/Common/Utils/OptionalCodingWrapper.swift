//
//  OptionalCodingWrapper.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 23.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

protocol OptionalCodingWrapper {
    associatedtype WrappedType: ExpressibleByNilLiteral
    var wrappedValue: WrappedType { get }
    init(wrappedValue: WrappedType)
}

extension KeyedDecodingContainer {
    // This is used to override the default decoding behavior for OptionalCodingWrapper
    // to allow a value to avoid a missing key Error
    func decode<T>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> T where T: Decodable, T: OptionalCodingWrapper {
        return try decodeIfPresent(T.self, forKey: key) ?? T(wrappedValue: nil)
    }
}
