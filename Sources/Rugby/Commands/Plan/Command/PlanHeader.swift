//
//  Plan.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 25.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser

struct Plans: ParsableCommand {
    @Option(help: "Plan name. (default: the first plan)\n") var plan: String?

    @OptionGroup(_hiddenFromHelp: true) var cacheOptions: Cache

    static var configuration = CommandConfiguration(
        abstract: """
        • Run selected plan from \(".rugby/plans.yml".yellow)
        or use cache command if file not found.
        """,
        discussion: """
        Checkout documentation for more info:
        📖 \("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Plans.md".cyan)
        """,
        subcommands: [PlansExample.self]
    )

    func run() throws {
        try WrappedError.wrap(playBell: cacheOptions.bell) {
            try tryUsePlans()
        }
    }

    private func tryUsePlans() throws {
        let plans = try PlanParser().parsePlans()
        guard !plans.isEmpty else { return try runCache() }
        try runPlans(plans)
    }

    private func runCache() throws {
        var cache = Cache()
        cache.arch = cacheOptions.arch
        cache.config = cacheOptions.config
        cache.sdk = cacheOptions.sdk
        cache.keepSources = cacheOptions.keepSources
        cache.exclude = cacheOptions.exclude
        cache.hideMetrics = cacheOptions.hideMetrics
        cache.ignoreChecksums = cacheOptions.ignoreChecksums
        cache.include = cacheOptions.include
        cache.focus = cacheOptions.focus
        cache.graph = cacheOptions.graph
        cache.verbose = cacheOptions.verbose
        try cache.wrappedRun()
    }
}
