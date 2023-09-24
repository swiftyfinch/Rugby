//
//  Collection+isNotEmpty.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 27.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}

extension Optional where Wrapped: Collection {
    var isNotEmpty: Bool {
        map(\.isNotEmpty) ?? false
    }
}
