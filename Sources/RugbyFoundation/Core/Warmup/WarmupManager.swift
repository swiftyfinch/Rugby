//
//  WarmupManager.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 16.01.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

// MARK: - Interface

/// The protocol describing a manager to download remote built binaries based on CocoaPods project targets.
public protocol IWarmupManager {
    /// Downloads remote built binaries based on CocoaPods project targets.
    /// - Parameters:
    ///   - mode: A warmup mode.
    ///   - targetsRegex: A RegEx to select targets.
    ///   - exceptTargetsRegex: A RegEx to exclude targets.
    ///   - options: Xcode build options.
    ///   - maxInParallel: A count of parallel jobs.
    func warmup(mode: WarmupMode,
                targetsRegex: NSRegularExpression?,
                exceptTargetsRegex: NSRegularExpression?,
                options: XcodeBuildOptions,
                maxInParallel: Int) async throws
}

/// The enumeration of warmup modes.
public enum WarmupMode {
    /// The mode to download remote built binaries.
    case endpoint(String)
    /// The mode to analyse availability of binaries.
    case analyse(endpoint: String?)
}

enum WarmupManagerError: LocalizedError {
    case incorrectEndpoint(String)

    var errorDescription: String? {
        switch self {
        case .incorrectEndpoint(let endpoint):
            return "Incorrect endpoint: \(endpoint)"
        }
    }
}

// MARK: - Implementation

final class WarmupManager: Loggable {
    private typealias Error = WarmupManagerError

    let logger: ILogger
    private let rugbyXcodeProject: RugbyXcodeProject
    private let buildTargetsManager: BuildTargetsManager
    private let binariesManager: IBinariesStorage
    private let targetsHasher: TargetsHasher
    private let cacheDownloader: CacheDownloader
    private let metricsLogger: IMetricsLogger

    init(logger: ILogger,
         rugbyXcodeProject: RugbyXcodeProject,
         buildTargetsManager: BuildTargetsManager,
         binariesManager: IBinariesStorage,
         targetsHasher: TargetsHasher,
         cacheDownloader: CacheDownloader,
         metricsLogger: IMetricsLogger) {
        self.logger = logger
        self.rugbyXcodeProject = rugbyXcodeProject
        self.buildTargetsManager = buildTargetsManager
        self.binariesManager = binariesManager
        self.targetsHasher = targetsHasher
        self.cacheDownloader = cacheDownloader
        self.metricsLogger = metricsLogger
    }

    private func findLocalBinaries(targetsRegex: NSRegularExpression?,
                                   exceptTargetsRegex: NSRegularExpression?,
                                   options: XcodeBuildOptions) async throws -> Set<Target> {
        let targets = try await log(
            "Finding Build Targets",
            auto: try await buildTargetsManager.findTargets(targetsRegex, exceptTargets: exceptTargetsRegex)
        )
        guard targets.isNotEmpty else { throw BuildError.cantFindBuildTargets }

        try await log("Hashing Targets", auto: try await targetsHasher.hash(targets, xcargs: options.xcargs))
        let (_, notFound) = try await log(
            "Finding Binaries",
            auto: binariesManager.findBinaries(ofTargets: targets, buildOptions: options)
        )

        let notFoundPaths = try notFound.compactMap {
            "- \(try binariesManager.finderBinaryFolderPath($0, buildOptions: options))"
        }
        if notFoundPaths.isNotEmpty {
            let list = notFoundPaths.caseInsensitiveSorted().joined(separator: "\n")
            await log("Not Found:\n\(list)", level: .info)
        }

        let notFoundPercent = notFound.count.percent(total: targets.count)
        await log("Not Found Locally \(notFoundPercent)% Binaries (\(notFound.count)/\(targets.count))")

        return notFound
    }

    private func downloadRemoteBinaries(targets: Set<Target>,
                                        endpointURL: URL,
                                        options: XcodeBuildOptions,
                                        dryRun: Bool,
                                        maxInParallel: Int) async throws {
        let binariesInfo = try collectRemoteBinariesInfo(targets: targets,
                                                         endpoint: endpointURL,
                                                         options: options)
        let reachableBinariesInfo = await log("Checking binaries reachability") {
            await filterReachableURLs(binariesInfo: binariesInfo, maxInParallel: maxInParallel)
        }
        if reachableBinariesInfo.unreachable.isNotEmpty {
            let listUnreachable = reachableBinariesInfo.unreachable
                .map(\.url.absoluteString).sorted().joined(separator: "\n")
            await log("Unreachable:\n\(listUnreachable)", output: .file)
        }

        let reachable = reachableBinariesInfo.reachable
        let reachablePercent = reachable.count.percent(total: binariesInfo.count)
        await log("Found \(reachablePercent)% Remote Binaries (\(reachable.count)/\(binariesInfo.count))")
        metricsLogger.log(reachablePercent, name: "Found Remote Binaries Percent")

        if dryRun { return }
        let downloaded = await log("Downloading binaries (\(reachable.count))") {
            await downloadBinaries(binariesInfo: reachable, maxInParallel: maxInParallel)
        }
        let downloadedPercent = downloaded.count.percent(total: reachable.count)
        await log("Downloaded \(downloadedPercent)% Binaries (\(downloaded.count)/\(reachable.count))")
    }

    private func makeEndpoint(_ endpoint: String) throws -> URL {
        let fullEndpoint = "https://\(endpoint)"
        guard let endpointURL = URL(string: fullEndpoint) else {
            throw Error.incorrectEndpoint(fullEndpoint)
        }
        return endpointURL
    }
}

private extension WarmupManager {
    typealias RemoteBinaryInfo = ((url: URL, localPath: URL))

    private func collectRemoteBinariesInfo(
        targets: Set<Target>,
        endpoint: URL,
        options: XcodeBuildOptions
    ) throws -> [RemoteBinaryInfo] {
        try targets.map { target in
            let binaryPath = try binariesManager.finderBinaryFolderPath(target, buildOptions: options)
            let binaryConfigFolder = URL(fileURLWithPath: binaryPath).deletingLastPathComponent()

            let relativePath = try binariesManager.binaryRelativePath(target, buildOptions: options)
            let url = endpoint.appendingPathComponent(relativePath).appendingPathExtension("zip")

            return (url, binaryConfigFolder)
        }
    }

    private func filterReachableURLs(
        binariesInfo: [RemoteBinaryInfo],
        maxInParallel: Int
    ) async -> (reachable: [RemoteBinaryInfo], unreachable: [RemoteBinaryInfo]) {
        await binariesInfo.concurrentCompactMap(
            maxInParallel: maxInParallel
        ) { [weak self] binaryInfo -> (succeed: Bool, info: RemoteBinaryInfo) in
            guard let self else { return (false, binaryInfo) }
            let succeed = await self.cacheDownloader.checkIfBinaryIsReachable(url: binaryInfo.url)
            return (succeed, binaryInfo)
        }.reduce(into: (reachable: [RemoteBinaryInfo], unreachable: [RemoteBinaryInfo])([], [])) { result, current in
            if current.succeed {
                result.reachable.append(current.info)
            } else {
                result.unreachable.append(current.info)
            }
        }
    }

    private func downloadBinaries(
        binariesInfo: [RemoteBinaryInfo],
        maxInParallel: Int
    ) async -> [RemoteBinaryInfo] {
        await binariesInfo.concurrentCompactMap(maxInParallel: maxInParallel) { [weak self] binaryInfo in
            guard let self else { return nil }
            let (url, localPath) = binaryInfo
            let succeed = await self.cacheDownloader.downloadBinary(url: url, to: localPath)
            return succeed ? binaryInfo : nil
        }
    }
}

private extension WarmupMode {
    var dryRun: Bool {
        if case .analyse = self { return true }
        return false
    }
}

// MARK: - IWarmupManager

extension WarmupManager: IWarmupManager {
    public func warmup(mode: WarmupMode,
                       targetsRegex: NSRegularExpression?,
                       exceptTargetsRegex: NSRegularExpression?,
                       options: XcodeBuildOptions,
                       maxInParallel: Int) async throws {
        let endpointURL: URL?
        switch mode {
        case let .endpoint(endpoint), let .analyse(endpoint?):
            endpointURL = try makeEndpoint(endpoint)
        case .analyse(nil):
            endpointURL = nil
        }
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        let notFoundTargets = try await findLocalBinaries(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            options: options
        )

        guard let endpointURL = endpointURL else { return }
        try await downloadRemoteBinaries(
            targets: notFoundTargets,
            endpointURL: endpointURL,
            options: options,
            dryRun: mode.dryRun,
            maxInParallel: maxInParallel
        )
    }
}
