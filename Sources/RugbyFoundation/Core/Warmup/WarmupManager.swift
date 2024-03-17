import Foundation

// MARK: - Interface

/// The protocol describing a manager to download remote built binaries based on CocoaPods project targets.
public protocol IWarmupManager: AnyObject {
    /// Downloads remote built binaries based on CocoaPods project targets.
    /// - Parameters:
    ///   - mode: A warmup mode.
    ///   - targetsOptions: A set of options to to select targets.
    ///   - options: Xcode build options.
    ///   - maxInParallel: A count of parallel jobs.
    ///   - headers: Extra HTTP header fields for a request (["s3-key": "my-secret-key"]).
    func warmup(mode: WarmupMode,
                targetsOptions: TargetsOptions,
                options: XcodeBuildOptions,
                maxInParallel: Int,
                headers: [String: String]) async throws
}

/// The enumeration of warmup modes.
public enum WarmupMode {
    /// The mode to download remote built binaries.
    case endpoint(String)
    /// The mode to analyse availability of binaries.
    case analyse(endpoint: String?)
    /// A mode where only the selected targets are printed.
    case printTargets
}

enum WarmupManagerError: LocalizedError, Equatable {
    case incorrectEndpoint(String)

    var errorDescription: String? {
        switch self {
        case let .incorrectEndpoint(endpoint):
            return "Incorrect endpoint: \(endpoint)"
        }
    }
}

// MARK: - Implementation

final class WarmupManager: Loggable {
    private typealias Error = WarmupManagerError

    let logger: ILogger
    private let rugbyXcodeProject: IRugbyXcodeProject
    private let buildTargetsManager: IBuildTargetsManager
    private let binariesStorage: IBinariesStorage
    private let targetsHasher: ITargetsHasher
    private let cacheDownloader: ICacheDownloader
    private let metricsLogger: IMetricsLogger
    private let targetsPrinter: ITargetsPrinter

    init(logger: ILogger,
         rugbyXcodeProject: IRugbyXcodeProject,
         buildTargetsManager: IBuildTargetsManager,
         binariesStorage: IBinariesStorage,
         targetsHasher: ITargetsHasher,
         cacheDownloader: ICacheDownloader,
         metricsLogger: IMetricsLogger,
         targetsPrinter: ITargetsPrinter) {
        self.logger = logger
        self.rugbyXcodeProject = rugbyXcodeProject
        self.buildTargetsManager = buildTargetsManager
        self.binariesStorage = binariesStorage
        self.targetsHasher = targetsHasher
        self.cacheDownloader = cacheDownloader
        self.metricsLogger = metricsLogger
        self.targetsPrinter = targetsPrinter
    }

    private func findLocalBinaries(targetsOptions: TargetsOptions,
                                   options: XcodeBuildOptions,
                                   dryRun: Bool) async throws -> TargetsMap {
        let targets = try await log(
            "Finding Build Targets",
            auto: await buildTargetsManager.findTargets(
                targetsOptions.targetsRegex,
                exceptTargets: targetsOptions.exceptTargetsRegex
            )
        )
        if targetsOptions.tryMode { return targets }
        guard targets.isNotEmpty else { throw BuildError.cantFindBuildTargets }

        try await log("Hashing Targets", auto: await targetsHasher.hash(targets, xcargs: options.xcargs))
        let (found, notFound) = try await log(
            "Finding Binaries",
            auto: binariesStorage.findBinaries(ofTargets: targets, buildOptions: options)
        )

        if notFound.values.isNotEmpty {
            let logLevel: LogLevel = dryRun ? .result : .info
            let notFoundPaths = try notFound.values
                .map { try "- \(binariesStorage.finderBinaryFolderPath($0, buildOptions: options))" }
                .caseInsensitiveSorted()
            await log("Not Found:", level: logLevel)
            await logList(notFoundPaths, level: logLevel)
        }

        await log(
            "Found Locally: \(found.count.percent(total: targets.count))% (\(found.count)/\(targets.count))",
            level: .result
        )

        return notFound
    }

    private func downloadRemoteBinaries(targets: TargetsMap,
                                        endpointURL: URL,
                                        options: XcodeBuildOptions,
                                        dryRun: Bool,
                                        maxInParallel: Int,
                                        headers: [String: String]) async throws {
        let binariesInfo = try collectRemoteBinariesInfo(targets: targets,
                                                         endpoint: endpointURL,
                                                         options: options)
        let reachableBinariesInfo = await log("Checking binaries reachability") {
            await filterReachableURLs(binariesInfo: binariesInfo, maxInParallel: maxInParallel, headers: headers)
        }
        if reachableBinariesInfo.unreachable.isNotEmpty {
            let listUnreachable = reachableBinariesInfo.unreachable
                .map(\.url.absoluteString).sorted().joined(separator: "\n")
            await log("Unreachable:\n\(listUnreachable)", output: .file)
        }

        let reachable = reachableBinariesInfo.reachable
        let reachablePercent = reachable.count.percent(total: binariesInfo.count)
        await log("Found Remotely: \(reachablePercent)% (\(reachable.count)/\(binariesInfo.count))")
        metricsLogger.log(reachablePercent, name: "Found Remote Binaries Percent")

        if dryRun { return }
        let downloaded = await log("Downloading binaries (\(reachable.count))") {
            await downloadBinaries(binariesInfo: reachable, maxInParallel: maxInParallel, headers: headers)
        }
        let downloadedPercent = downloaded.count.percent(total: reachable.count)
        await log("Downloaded: \(downloadedPercent)% (\(downloaded.count)/\(reachable.count))")
        metricsLogger.log(downloadedPercent, name: "Downloaded Binaries Percent")
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
    typealias RemoteBinaryInfo = (url: URL, localPath: URL)

    private func collectRemoteBinariesInfo(
        targets: TargetsMap,
        endpoint: URL,
        options: XcodeBuildOptions
    ) throws -> [RemoteBinaryInfo] {
        try targets.values.map { target in
            let binaryPath = try binariesStorage.finderBinaryFolderPath(target, buildOptions: options)
            let binaryConfigFolder = URL(fileURLWithPath: binaryPath).deletingLastPathComponent()

            let relativePath = try binariesStorage.binaryRelativePath(target, buildOptions: options)
            let url = endpoint.appendingPathComponent(relativePath).appendingPathExtension("zip")

            return (url, binaryConfigFolder)
        }
    }

    private func filterReachableURLs(
        binariesInfo: [RemoteBinaryInfo],
        maxInParallel: Int,
        headers: [String: String]
    ) async -> (reachable: [RemoteBinaryInfo], unreachable: [RemoteBinaryInfo]) {
        await binariesInfo.concurrentCompactMap(
            maxInParallel: maxInParallel
        ) { [weak self] binaryInfo -> (succeed: Bool, info: RemoteBinaryInfo) in
            guard let self else { return (false, binaryInfo) }
            let succeed = await self.cacheDownloader.checkIfBinaryIsReachable(url: binaryInfo.url, headers: headers)
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
        maxInParallel: Int,
        headers: [String: String]
    ) async -> [RemoteBinaryInfo] {
        await binariesInfo.concurrentCompactMap(maxInParallel: maxInParallel) { [weak self] binaryInfo in
            guard let self else { return nil }
            let (url, localPath) = binaryInfo
            let succeed = await self.cacheDownloader.downloadBinary(url: url, headers: headers, to: localPath)
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
                       targetsOptions: TargetsOptions,
                       options: XcodeBuildOptions,
                       maxInParallel: Int,
                       headers: [String: String]) async throws {
        let endpointURL: URL?
        switch mode {
        case let .endpoint(endpoint), let .analyse(endpoint?):
            endpointURL = try makeEndpoint(endpoint)
        case .analyse(nil), .printTargets:
            endpointURL = nil
        }
        guard try await !rugbyXcodeProject.isAlreadyUsingRugby() else { throw RugbyError.alreadyUseRugby }

        let notFoundTargets = try await findLocalBinaries(
            targetsOptions: targetsOptions,
            options: options,
            dryRun: mode.dryRun
        )
        if targetsOptions.tryMode {
            return await targetsPrinter.print(notFoundTargets)
        }

        guard let endpointURL, notFoundTargets.isNotEmpty else { return }
        try await downloadRemoteBinaries(
            targets: notFoundTargets,
            endpointURL: endpointURL,
            options: options,
            dryRun: mode.dryRun,
            maxInParallel: maxInParallel,
            headers: headers
        )
    }
}
