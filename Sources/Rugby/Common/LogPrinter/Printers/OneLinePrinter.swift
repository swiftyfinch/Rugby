//
//  OneLinePrinter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 19.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

final class OneLinePrinter {
    private var firstPrint = true
}

extension OneLinePrinter: Printer {
    var chop: Int? { 50 }

    func print(_ value: String, level: Int) {
        if firstPrint { Swift.print(); firstPrint = false }
        Swift.print("\u{1B}[1A\u{1B}[K\(value)")
    }

    func done() {}
}
