//
//  Optional+AsyncMap.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 30.10.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Optional {
    func map<U>(_ transform: (Wrapped) async throws -> U) async rethrows -> U? {
        switch self {
        case .some(let wrapped):
            return try await transform(wrapped)
        case .none:
            return nil
        }
    }
}
