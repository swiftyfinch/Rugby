//
//  CacheHeader.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 29.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Rainbow

struct Cache: ParsableCommand {
    @Option(name: .shortAndLong, help: "Build architechture. (default: \(ARCH.x86_64) for sim)") var arch: String?
    @Option(name: .shortAndLong, help: "Build sdk: sim or ios.") var sdk: SDK = .sim
    @Flag(name: .shortAndLong, help: "Keep Pods group in project.") var keepSources = false
    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Exclude pods from cache.") var exclude: [String] = []
    @Option(parsing: .upToNextOption, help: "Include local pods.") var include: [String] = []
    @Option(parsing: .upToNextOption, help: "Keep selected local pods and cache others.") var focus: [String] = []
    @Flag(inversion: .prefixedNo, help: "Build changed pods parents.") var graph = true
    @Flag(help: "Ignore already cached pods checksums.\n") var ignoreChecksums = false

    @Flag(name: .long, inversion: .prefixedNo, help: "Play bell sound on finish.") var bell = true
    @Flag(help: "Hide metrics.") var hideMetrics = false
    @Flag(name: .shortAndLong, help: "Print more information.") var verbose: Int

    static var configuration: CommandConfiguration = .init(
        abstract: """
        • Convert remote pods to prebuilt dependencies.
        Call it after each \("pod install".yellow).
        """,
        discussion: """
        Checkout documentation for more info:
        📖 \("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Cache.md".cyan)
        """
    )

    mutating func run() throws {
        try WrappedError.wrap(playBell: bell) {
            try wrappedRun()
        }
    }
}
