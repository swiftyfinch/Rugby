//
//  Collection+ModifyIf.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 07.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Collection {
    @discardableResult
    func modifyIf(
        _ condition: Bool,
        _ transform: (inout Self) throws -> Void
    ) rethrows -> Self {
        guard condition else { return self }
        var copy = self
        try transform(&copy)
        return copy
    }
}
