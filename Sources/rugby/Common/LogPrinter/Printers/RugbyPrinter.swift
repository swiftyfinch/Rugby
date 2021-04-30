//
//  RugbyPrinter.swift
//  
//
//  Created by v.khorkov on 09.01.2021.
//

import Files
import Foundation

struct RugbyPrinter: Printer {
    private let begin = ProcessInfo.processInfo.systemUptime
    private let formatter: Formatter
    private let printers: [Printer]

    init(formatter: Formatter, printers: [Printer]) {
        self.formatter = formatter
        self.printers = printers
    }

    func print(_ value: String) {
        printers.forEach {
            $0.print(formatter.format(text: value, chop: $0.chop))
        }
    }

    func done() {
        let time = ProcessInfo.processInfo.systemUptime - begin
        printers.forEach {
            let value = formatter.format(text: "✓", time: time.output(), chop: $0.chop)
            $0.print(value)
            $0.done()
        }
    }
}

extension RugbyPrinter {
    init(title: String? = nil, logFile: File? = nil, verbose: Bool = false) {
        var printers: [Printer] = [verbose ? DefaultPrinter() : OneLinePrinter()]
        logFile.map { printers.append(FilePrinter(file: $0)) }
        self.init(formatter: RugbyFormatter(title: title), printers: printers)
    }
}
