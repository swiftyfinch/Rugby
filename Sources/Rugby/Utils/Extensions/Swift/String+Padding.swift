//
//  String+Padding.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.11.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension String {
    func padding(toSize size: Int) -> String {
        guard rawCount < size else { return self }
        let remaining = size - rawCount
        return "\(self)\(String(repeating: " ", count: remaining))"
    }
}
