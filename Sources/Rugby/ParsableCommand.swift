//
//  ParsableCommand.swift
//  
//
//  Created by Vyacheslav Khorkov on 21.04.2021.
//

import ArgumentParser
import Files

extension ParsableCommand {
    // swiftlint:disable:next identifier_name
    static var _errorLabel: String {
        "⛔️ \u{1B}[31mError"
    }
}

extension Int {
    static var verbose = 1
    static var vv = 2
}
