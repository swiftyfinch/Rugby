//
//  BoolableIntDecodable.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 21.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

@propertyWrapper
struct BoolableIntDecodable: Decodable, OptionalCodingWrapper {

    let wrappedValue: Int?

    init(wrappedValue: Int?) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.intAsBool()
    }
}

private extension SingleValueDecodingContainer {
    func intAsBool() throws -> Int? {
        do {
            return try decode(Int.self)
        } catch DecodingError.typeMismatch {
            guard let bool = try? decode(Bool.self) else { return nil }
            return bool ? 1 : 0
        }
    }
}
