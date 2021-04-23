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
    func printFinalMessage(logFile: File, time: Double, metrics: MetricsOutput, more: Bool) {
        let logger = RugbyPrinter(logFile: logFile, verbose: true)
        if more {
            metrics.more().forEach { logger.print("[!] ".yellow + $0) }
        }
        logger.print(time.output() + " " + metrics.short() + " " + .finalMessage)
    }
}
