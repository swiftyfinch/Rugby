//
//  RugbyPrinter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Foundation

struct RugbyPrinter: Printer {
    private let begin = ProcessInfo.processInfo.systemUptime
    private let formatter: Formatter
    private let printers: [Printer]
    private let skipSpinner: Bool

    init(formatter: Formatter, printers: [Printer], skipSpinner: Bool) {
        self.formatter = formatter
        self.printers = printers
        self.skipSpinner = skipSpinner
    }

    func print(_ value: String, level: Int) {
        printers.forEach {
            $0.print(formatter.format(text: value, chop: $0.chop), level: level)
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

    @discardableResult
    func spinner<Result>(_ text: String, job: @escaping () throws -> Result) rethrows -> Result {
        defer { print("\(text) \("✓".white)".yellow, level: .vv) }
        if skipSpinner { return try job() }
        let result = try Spinner().show(text: text, job)
        return result
    }
}

extension RugbyPrinter {
    init(title: String? = nil, logFile: File? = nil, verbose: Int = 0, quiet: Bool) {
        var printers: [Printer] = []
        if !quiet {
            printers.append(verbose.bool ? DefaultPrinter(verbose: verbose) : OneLinePrinter())
        }
        logFile.map { printers.append(FilePrinter(file: $0)) }
        self.init(formatter: RugbyFormatter(title: title), printers: printers, skipSpinner: quiet)
    }
}
