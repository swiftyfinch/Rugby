//
//  DefaultPrinter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

struct DefaultPrinter: Printer {
    let verbose: Int
    func print(_ value: String, level: Int) {
        guard level <= verbose else { return }
        Swift.print(value)
    }
    func done() {}
}
