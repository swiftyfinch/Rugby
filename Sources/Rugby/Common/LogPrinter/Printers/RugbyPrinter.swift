//
//  RugbyPrinter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Foundation

final class RugbyPrinter: Printer {
    private let begin = ProcessInfo.processInfo.systemUptime
    private let formatter: Formatter
    private let screenPrinters: [Printer]
    private let logPrinters: [Printer]
    private let spinnerMode: SpinnerMode
    private var isSpinnerAnimating = false

    enum SpinnerMode {
        case quiet
        case simple
        case standard
    }

    init(formatter: Formatter, screenPrinters: [Printer], logPrinters: [Printer], spinnerMode: SpinnerMode) {
        self.formatter = formatter
        self.screenPrinters = screenPrinters
        self.logPrinters = logPrinters
        self.spinnerMode = spinnerMode
    }

    func print(_ value: String, level: Int) {
        if !isSpinnerAnimating {
            screenPrinters.forEach {
                $0.print(formatter.format(text: value, chop: $0.chop), level: level)
            }
        }
        logPrinters.forEach {
            $0.print(formatter.format(text: value, chop: $0.chop), level: level)
        }
    }

    func done() {
        let time = ProcessInfo.processInfo.systemUptime - begin
        (screenPrinters + logPrinters).forEach {
            let value = formatter.format(text: "✓", time: time.output(), chop: $0.chop)
            $0.print(value)
            $0.done()
        }
    }

    @discardableResult
    func spinner<Result>(_ text: String, job: @escaping () throws -> Result) rethrows -> Result {
        defer { print("\(text) \("✓".white)".yellow, level: .vv) }
        switch spinnerMode {
        case .quiet:
            return try job()
        case .simple:
            print(text)
            return try job()
        case .standard:
            isSpinnerAnimating = true
            let result = try Spinner().show(text: text, job)
            isSpinnerAnimating = false
            return result
        }
    }
}

extension RugbyPrinter {
    convenience init(title: String? = nil, logFile: File? = nil, verbose: Int = 0, quiet: Bool, nonInteractive: Bool) {
        self.init(formatter: RugbyFormatter(title: title),
                  screenPrinters: quiet ? [] : [verbose.bool ? DefaultPrinter(verbose: verbose) : OneLinePrinter()],
                  logPrinters: logFile.map { [FilePrinter(file: $0)] } ?? [],
                  spinnerMode: quiet ? .quiet : nonInteractive ? .simple : .standard)
    }
}
