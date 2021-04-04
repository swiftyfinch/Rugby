//
//  String+Regex.swift
//  
//
//  Created by Vyacheslav Khorkov on 16.02.2021.
//

extension String {
    func escapeForRegex() -> String {
        ["+", "."].reduce(into: self) {
            $0 = $0.replacingOccurrences(of: $1, with: "\\\($1)")
        }
    }
}
