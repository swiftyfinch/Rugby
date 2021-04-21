//
//  OneLinePrinter.swift
//  
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//

import Foundation

final class OneLinePrinter {
    private var firstPrint = true
}

extension OneLinePrinter: Printer {
    var chop: Int? { 50 }

    func print(_ value: String) {
        if firstPrint { Swift.print(); firstPrint = false }
        Swift.print("\u{1B}[1A\u{1B}[K\(value)")
    }

    func done() {}
}
