//
//  Cache.swift
//  
//
//  Created by v.khorkov on 29.01.2021.
//

import ArgumentParser
import Files
import Foundation
import Rainbow

private extension String {
    static let buildTarget = "RemotePods"
}

struct Cache: ParsableCommand {
    @Option(name: .shortAndLong, help: "Build architechture.") var arch: String?
    @Option(name: .shortAndLong,
            help: "Build sdk: sim or ios.\nUse --rebuild after switch.") var sdk: SDK = .sim
    @Flag(name: .shortAndLong, help: "Keep Pods group in project.") var keepSources = false
    @Option(name: .shortAndLong,
            parsing: .upToNextOption,
            help: "Exclude pods from cache.") var exclude: [String] = []
    @Flag(name: .shortAndLong, help: "Ignore already cached pods checksums.\n") var rebuild = false

    @Flag(name: .shortAndLong, help: "Print more information.") var verbose = false

    enum Context {
        static let buildTarget: String = .buildTarget
    }

    static var configuration: CommandConfiguration = .init(
        abstract: "Remove remote pods, build them and integrate as frameworks and bundles."
    )

    func run() throws {
        try WrappedError.wrap(privateRun)
    }

    private func privateRun() throws {
        var outputMessage: String = ""
        let totalTime = try measure {
            let logFile = try Folder.current.createFile(at: .log)

            let prepareStep = CachePrepareStep(logFile: logFile, verbose: verbose)
            let info = try prepareStep.run(buildTarget: Context.buildTarget, command: self)

            let buildStep = CacheBuildStep(logFile: logFile, verbose: verbose)
            try buildStep.run(scheme: info.buildPods.isEmpty ? nil : Context.buildTarget,
                              checksums: info.checksums,
                              command: self)

            let integrateStep = CacheIntegrateStep(logFile: logFile, verbose: verbose)
            try integrateStep.run(remotePods: info.remotePods, cacheFolder: .cacheFolder(sdk: sdk))

            let cleanupStep = CacheCleanupStep(logFile: logFile, verbose: verbose)
            try cleanupStep.run(remotePods: info.remotePods,
                                buildTarget: Context.buildTarget,
                                keepSources: keepSources,
                                products: info.products)

            let (podsCount, cachedPodsCount) = (info.podsCount, info.checksums.count)
            outputMessage = "Cached \(cachedPodsCount)/\(podsCount) pods. Let's roll 🏈".green
        }
        print("[\(totalTime.formatTime())] ".yellow + outputMessage)
    }
}
