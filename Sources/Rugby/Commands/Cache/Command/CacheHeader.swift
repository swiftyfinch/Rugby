//
//  CacheHeader.swift
//  
//
//  Created by v.khorkov on 29.01.2021.
//

import ArgumentParser
import Rainbow

struct Cache: ParsableCommand {
    @Option(name: .shortAndLong, help: "Build architechture. (default: \(ARCH.x86_64) for sim)") var arch: String?
    @Option(name: .shortAndLong, help: "Build sdk: sim or ios.") var sdk: SDK = .sim
    @Flag(name: .shortAndLong, help: "Keep Pods group in project.") var keepSources = false
    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Exclude pods from cache.") var exclude: [String] = []
    @Flag(help: "Ignore already cached pods checksums.") var ignoreChecksums = false
    @Option(name: .long,
            parsing: .upToNextOption,
            help: ArgumentHelp("Include local pods.", shouldDisplay: false)) var include: [String] = []
    @Option(name: .long,
            parsing: .upToNextOption,
            help: ArgumentHelp("Keep selected pods.", shouldDisplay: false)) var focus: [String] = []
    @Flag(help: "Add parents of changed pods to build process.\n") var graph = false

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
