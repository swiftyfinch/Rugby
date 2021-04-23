//
//  CacheHeader.swift
//  
//
//  Created by v.khorkov on 29.01.2021.
//

import ArgumentParser
import Rainbow

struct Cache: ParsableCommand {
    @Option(name: .shortAndLong, help: "Build architechture.") var arch: String?
    @Option(name: .shortAndLong,
            help: "Build sdk: sim or ios.\nUse --rebuild after switch.") var sdk: SDK = .sim
    @Flag(name: .shortAndLong, help: "Keep Pods group in project.") var keepSources = false
    @Option(name: .shortAndLong,
            parsing: .upToNextOption,
            help: "Exclude pods from cache.") var exclude: [String] = []
    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Show more metrics.") var metrics = true
    @Flag(name: .shortAndLong, help: "Ignore already cached pods checksums.\n") var rebuild = false

    @Flag(name: .shortAndLong, help: "Print more information.") var verbose = false

    static var configuration: CommandConfiguration = .init(
        abstract: "Remove remote pods, build them and integrate as frameworks and bundles."
    )

    func run() throws {
        try WrappedError.wrap(wrappedRun)
    }
}
