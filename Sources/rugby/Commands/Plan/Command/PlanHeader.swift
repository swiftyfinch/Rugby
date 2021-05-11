//
//  Plan.swift
//  
//
//  Created by Vyacheslav Khorkov on 25.04.2021.
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
        cache.sdk = cacheOptions.sdk
        cache.keepSources = cacheOptions.keepSources
        cache.exclude = cacheOptions.exclude
        cache.hideMetrics = cacheOptions.hideMetrics
        cache.ignoreCache = cacheOptions.ignoreCache
        cache.skipParents = cacheOptions.skipParents
        cache.verbose = cacheOptions.verbose
        try cache.wrappedRun()
    }
}
