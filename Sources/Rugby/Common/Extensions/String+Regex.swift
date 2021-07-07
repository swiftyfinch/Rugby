//
//  String+Regex.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 16.02.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

extension String {
    func escapeForRegex() -> String {
        ["+", "."].reduce(into: self) {
            $0 = $0.replacingOccurrences(of: $1, with: "\\\($1)")
        }
    }
}
