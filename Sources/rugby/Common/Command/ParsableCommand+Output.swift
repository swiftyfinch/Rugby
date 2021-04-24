//
//  ParsableCommand+Output.swift
//  
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//

import ArgumentParser
import Files

extension ParsableCommand {
    func done(logFile: File, time: Double) {
        let logger = RugbyPrinter(logFile: logFile, verbose: true)
        logger.print(time.output() + " " + .finalMessage)
    }
}
