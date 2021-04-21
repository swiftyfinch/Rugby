//
//  Printer.swift
//  
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//

import Foundation

protocol Printer {
    var chop: Int? { get }
    func print(_ value: String)
    func done()
}

extension Printer {
    var chop: Int? { nil }
}
