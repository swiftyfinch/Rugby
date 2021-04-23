//
//  ParsableCommand.swift
//  
//
//  Created by Vyacheslav Khorkov on 21.04.2021.
//

import ArgumentParser
import Files

extension ParsableCommand {
    // swiftlint:disable:next identifier_name
    static var _errorLabel: String {
        "⛔️ \u{1B}[31mError"
    }
}

extension ParsableCommand {
    func printFinalMessage(logFile: File, time: Double, metrics: MetricsOutput, more: Bool = false) {
        let logger = RugbyPrinter(logFile: logFile, verbose: true)
        logger.print(time.output() + " " + metrics.short() + " " + .finalMessage)
        if more {
            let shift = String(repeating: " ", count: time.output().raw.count)
            metrics.more().forEach { logger.print("\(shift + " " + $0)") }
        }
    }
}
