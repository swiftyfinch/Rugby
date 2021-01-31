//
//  ProgressBar.swift
//  
//
//  Created by v.khorkov on 09.01.2021.
//

import Foundation
import Rainbow

protocol ProgressBarFormatter {
    func format(index: Int, count: Int) -> String
}

final class ProgressBar {
    private(set) var index = 0
    var count: Int {
        didSet { index = 0 }
    }
    private let formatter: ProgressBarFormatter
    private let printers: [ProgressBarPrinter]
    private var value: String { formatter.format(index: index, count: count) }

    init(count: Int, formatter: ProgressBarFormatter, printers: [ProgressBarPrinter]) {
        self.count = count
        self.formatter = formatter
        self.printers = printers
    }

    func next() {
        guard index + 1 < count else { return }
        index += 1
        printers.forEach { $0.display(value, isEnd: false) }
    }

    func setValue(_ index: Int) {
        guard index <= count && index >= 0 else { return }
        self.index = index
        printers.forEach { $0.display(value, isEnd: index == count) }
    }
}
