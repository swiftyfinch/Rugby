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

            let metrics = Metrics()
            let prepare = CachePrepareStep(command: self, metrics: metrics, logFile: logFile)
            let build = CacheBuildStep(command: self, logFile: logFile)
            let integrate = CacheIntegrateStep(command: self, logFile: logFile)
            let cleanup = CacheCleanupStep(command: self, logFile: logFile)
            try (prepare.run | build.run | integrate.run | cleanup.run)(Context.buildTarget)

            if let podsCount = metrics.podsCount, let cachedPodsCount = metrics.checksums {
                outputMessage = "Cached \(cachedPodsCount)/\(podsCount) pods. ".green
            }
            outputMessage += "Let's roll 🏈".green
        }
        print("[\(totalTime.formatTime())] ".yellow + outputMessage)
    }
}

// MARK: - Metrics

extension Cache {
    final class Metrics {
        var podsCount: Int?
        var checksums: Int?

        init(podsCount: Int? = nil, checksums: Int? = nil) {
            self.podsCount = podsCount
            self.checksums = checksums
        }
    }
}
