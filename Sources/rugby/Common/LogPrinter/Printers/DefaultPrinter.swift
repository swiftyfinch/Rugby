//
//  DefaultPrinter.swift
//  
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//

struct DefaultPrinter: Printer {
    func print(_ value: String) { Swift.print(value) }
    func done() {}
}
