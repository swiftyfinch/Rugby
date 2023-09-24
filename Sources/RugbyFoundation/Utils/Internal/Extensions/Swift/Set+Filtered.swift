//
//  Set+Filtered.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 20.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Set {
    mutating func filtered(_ isIncluded: (Element) throws -> Bool) rethrows {
        self = try filter(isIncluded)
    }
}
