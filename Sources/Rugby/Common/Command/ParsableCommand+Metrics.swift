//
//  ParsableCommand+Metrics.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Files

extension ParsableCommand {
    func output(_ metrics: Metrics?, time: Double, logFile: File, extended: Bool, quiet: Bool) {
        guard let metrics = metrics else { return }
        outputShort(metrics, time: time, logFile: logFile, quiet: quiet)
        if extended { outputMore(metrics, logFile: logFile, quiet: quiet) }
    }

    func outputShort(_ metrics: Metrics?, time: Double, logFile: File, quiet: Bool) {
        guard let metrics = metrics else { return }
        let logger = RugbyPrinter(logFile: logFile, verbose: .verbose, quiet: quiet, nonInteractive: false)
        if let short = metrics.short() {
            logger.print(time.output() + " " + short)
        }
    }

    func outputMore(_ metrics: Metrics, logFile: File, quiet: Bool) {
        let logger = RugbyPrinter(logFile: logFile, verbose: .verbose, quiet: quiet, nonInteractive: false)
        metrics.more().forEach {
            logger.print("[!] ".yellow + $0)
        }
    }
}
