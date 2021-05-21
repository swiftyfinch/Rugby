//
//  DefaultPrinter.swift
//  
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//

struct DefaultPrinter: Printer {
    let verbose: Int
    func print(_ value: String, level: Int) {
        guard level <= verbose else { return }
        Swift.print(value)
    }
    func done() {}
}
