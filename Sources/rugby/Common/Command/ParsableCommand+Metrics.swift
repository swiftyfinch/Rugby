//
//  ParsableCommand+Metrics.swift
//  
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//

import ArgumentParser
import Files

extension ParsableCommand {
    func output(_ metrics: Metrics?, time: Double, logFile: File, extended: Bool) {
        guard let metrics = metrics else { return }
        outputShort(metrics, time: time, logFile: logFile)
        if extended { outputMore(metrics, logFile: logFile) }
    }

    func outputShort(_ metrics: Metrics?, time: Double, logFile: File) {
        guard let metrics = metrics else { return }
        let logger = RugbyPrinter(logFile: logFile, verbose: .verbose)
        if let short = metrics.short() {
            logger.print(time.output() + " " + short)
        }
    }

    func outputMore(_ metrics: Metrics, logFile: File) {
        let logger = RugbyPrinter(logFile: logFile, verbose: .verbose)
        metrics.more().forEach {
            logger.print("[!] ".yellow + $0)
        }
    }
}
