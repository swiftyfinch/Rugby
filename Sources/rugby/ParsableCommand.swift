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
    func printFinalMessage(logFile: File, time: Double, metrics: String) {
        RugbyPrinter(logFile: logFile, verbose: true)
            .print(time.output() + " " + metrics + .finalMessage)
    }
}
