//
//  Command.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 29.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Files

protocol Command {
    var project: String { get }
    var hideMetrics: Bool { get }
    var quiet: Bool { get }
    var nonInteractive: Bool { get }

    mutating func run(logFile: File) throws -> Metrics?
}

extension Command {
    var project: String { .podsProject }
    var hideMetrics: Bool { false }
}

extension Command where Self: ParsableCommand {
    mutating func wrappedRun() throws {
        defer { try? HistoryWriter().save() }

        var metrics: Metrics?
        let logFile = try Folder.current.createFile(at: .log)
        EnvironmentCollector().write(to: logFile)
        let time = try measure { metrics = try run(logFile: logFile) }
        output(metrics, time: time, logFile: logFile, extended: !hideMetrics, quiet: quiet)
        done(logFile: logFile, time: time, quiet: quiet)
    }
}
