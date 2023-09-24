//
//  Sequence+AsyncReduce.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 16.10.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Sequence {
    func reduce<Result>(
        into initialResult: Result,
        _ updateAccumulatingResult: ((inout Result, Element) async throws -> Void)
    ) async rethrows -> Result {
        var result = initialResult
        for element in self {
            try await updateAccumulatingResult(&result, element)
        }
        return result
    }
}
