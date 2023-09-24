//
//  String+RegexGroups.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 18.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

extension String {
    /// Returns RegEx capture groups matches.
    public func groups(regex: String) throws -> [String] {
        try groups(regex.regex())
    }
}
