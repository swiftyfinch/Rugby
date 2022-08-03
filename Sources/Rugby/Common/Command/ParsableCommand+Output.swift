//
//  ParsableCommand+Output.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Files

extension ParsableCommand {
    func done(logFile: File, time: Double, quiet: Bool) {
        let logger = RugbyPrinter(logFile: logFile, verbose: .verbose, quiet: quiet, nonInteractive: false)
        logger.print(time.output() + " " + .finalMessage)
    }
}
