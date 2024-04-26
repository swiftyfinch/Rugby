import Fish
import Foundation

public extension Vault {
    /// The manager to download remote built binaries based on CocoaPods project targets.
    /// - Parameters:
    ///   - timeoutIntervalForRequest: The timeout interval to use when waiting for additional data.
    ///   - httpMaximumConnectionsPerHost: The maximum number of simultaneous connections to make to a given host.
    ///   - archiveType: Binary archive file type: zip or 7z.
    func warmupManager(timeoutIntervalForRequest: TimeInterval,
                       httpMaximumConnectionsPerHost: Int,
                       archiveType: ArchiveType) -> IWarmupManager {
        let xcodeProject = xcode.project(projectPath: router.podsProjectPath)
        let buildTargetsManager = BuildTargetsManager(xcodeProject: xcodeProject)
        let urlSessionConfiguration: URLSessionConfiguration = .default
        urlSessionConfiguration.timeoutIntervalForRequest = timeoutIntervalForRequest
        urlSessionConfiguration.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost
        let cacheDownloader = CacheDownloader(
            logger: logger,
            reachabilityChecker: ReachabilityChecker(urlSession: URLSession.shared),
            urlSession: URLSession(configuration: urlSessionConfiguration),
            decompressor: decompressor(archiveType: archiveType)
        )
        return WarmupManager(logger: logger,
                             rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
                             buildTargetsManager: buildTargetsManager,
                             binariesStorage: binariesStorage,
                             targetsHasher: targetsHasher(),
                             cacheDownloader: cacheDownloader,
                             metricsLogger: metricsLogger,
                             targetsPrinter: targetsPrinter)
    }

    private func decompressor(archiveType: ArchiveType) -> IDecompressor {
        switch archiveType {
        case .zip:
            return ZipDecompressor()
        case .sevenZip:
            return SevenZipDecompressor()
        }
    }
}
