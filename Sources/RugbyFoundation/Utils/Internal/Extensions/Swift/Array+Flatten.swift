//
//  Array+Flatten.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 04.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Array where Element: Any {
    func flatten() -> [Any] {
        flatMap { element -> [Any] in
            if let anyarray = element as? [Any] {
                return anyarray.map { $0 as Any }.flatten()
            }
            return [element]
        }
    }
}
