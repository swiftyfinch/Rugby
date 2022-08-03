//
//  CommonFlags.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 23.10.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser

struct CommonFlags: ParsableCommand {
    @Flag(name: .long, inversion: .prefixedNo, help: "Play bell sound on finish.") var bell = true
    @Flag(help: "Hide metrics.") var hideMetrics = false
    @Flag(name: .shortAndLong, help: "Print more information.") var verbose: Int
    @Flag(name: .shortAndLong, help: "Print nothing.") var quiet = false
    @Flag(help: "Format output for non-interactive terminal sessions (reduce loading spinner output).")
    var nonInteractive = false
}
