//
//  Printer.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

protocol Printer {
    var chop: Int? { get }
    func print(_ value: String, level: Int)
    func done()

    @discardableResult
    func spinner<Result>(_ text: String, job: @escaping () throws -> Result) rethrows -> Result
}

extension Printer {
    var chop: Int? { nil }
    func print(_ value: String) {
        print(value, level: .verbose)
    }
}
