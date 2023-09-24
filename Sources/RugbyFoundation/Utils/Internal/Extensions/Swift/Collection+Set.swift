//
//  Collection+Set.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 27.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Collection where Element: Hashable {
    func set() -> Set<Element> {
        Set(self)
    }
}
