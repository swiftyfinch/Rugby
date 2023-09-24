//
//  Collection+CompactMap.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 03.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Collection {
    func compactMap<Wrapped>() -> [Wrapped] where Element == Wrapped? {
        compactMap { $0 }
    }
}
