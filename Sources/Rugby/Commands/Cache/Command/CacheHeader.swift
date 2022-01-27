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
    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Build sdks: sim/ios or both.") var sdk: [SDK] = [.sim]
    @Option(name: .shortAndLong,
            parsing: .upToNextOption,
            help: "Build architectures. (default: sim \(ARCH.x86_64), ios \(ARCH.arm64))") var arch: [String] = []
    @Option(name: .shortAndLong, help: "Build configuration.") var config = CONFIG.debug
    @Flag(name: .long, help: "Add bitcode for archive builds.") var bitcode = false
    @Flag(name: .shortAndLong, help: "Keep Pods group in project.") var keepSources = false
    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Exclude pods from cache.") var exclude: [String] = []
    @Option(parsing: .upToNextOption, help: "Include local pods.") var include: [String] = []
    @Option(parsing: .upToNextOption, help: "Keep selected local pods and cache others.") var focus: [String] = []
    @Flag(inversion: .prefixedNo, help: "Build changed pods parents.") var graph = true
    @Flag(help: "Ignore already cached pods checksums.\n") var ignoreChecksums = false

    @OptionGroup var flags: CommonFlags

    static var configuration: CommandConfiguration = .init(
        abstract: """
        • Convert pods to prebuilt dependencies.
        Call it after each \("pod install".yellow).
        """,
        discussion: """
        Checkout documentation for more info:
        📖 \("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Cache.md".cyan)
        """
    )

    mutating func run() throws {
        try WrappedError.wrap(playBell: flags.bell) {
            try wrappedRun()
        }
    }
}
