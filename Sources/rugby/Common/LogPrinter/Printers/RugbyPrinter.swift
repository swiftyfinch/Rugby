//
//  RugbyPrinter.swift
//  
//
//  Created by v.khorkov on 09.01.2021.
//

import Files
import Foundation

final class RugbyPrinter: Printer {
    private let begin = ProcessInfo.processInfo.systemUptime
    private let formatter: Formatter
    private let printers: [Printer]

    init(formatter: Formatter, printers: [Printer]) {
        self.formatter = formatter
        self.printers = printers
    }

    func print(_ value: String) {
        let formattedValue = formatter.format(text: value)
        printers.forEach {
            $0.print(formattedValue)
        }
    }

    func done() {
        let time = ProcessInfo.processInfo.systemUptime - begin
        let value = formatter.format(text: "✓", time: time.output())
        printers.forEach {
            $0.print(value)
            $0.done()
        }
    }
}

extension RugbyPrinter {
    convenience init(title: String, logFile: File? = nil, verbose: Bool = false) {
        var printers: [Printer] = [verbose ? DefaultPrinter() : OneLinePrinter()]
        logFile.map { printers.append(FilePrinter(file: $0)) }
        self.init(formatter: RugbyFormatter(title: title), printers: printers)
    }
}
