import Fish
import Foundation

public extension Vault {
    /// The manager to download remote built binaries based on CocoaPods project targets.
    /// - Parameters:
    ///   - workingDirectory: A directory with Pods folder.
    ///   - timeoutIntervalForRequest: The timeout interval to use when waiting for additional data.
    ///   - httpMaximumConnectionsPerHost: The maximum number of simultaneous connections to make to a given host.
    func warmupManager(workingDirectory: IFolder,
                       timeoutIntervalForRequest: TimeInterval,
                       httpMaximumConnectionsPerHost: Int) -> IWarmupManager {
        let xcodeProject = xcode.project(projectPath: router.paths(relativeTo: workingDirectory).podsProject)
        let buildTargetsManager = BuildTargetsManager(xcodeProject: xcodeProject)
        let urlSessionConfiguration: URLSessionConfiguration = .default
        urlSessionConfiguration.timeoutIntervalForRequest = timeoutIntervalForRequest
        urlSessionConfiguration.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost
        let cacheDownloader = CacheDownloader(
            logger: logger,
            reachabilityChecker: ReachabilityChecker(),
            urlSession: URLSession(configuration: urlSessionConfiguration)
        )
        return WarmupManager(logger: logger,
                             rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
                             buildTargetsManager: buildTargetsManager,
                             binariesManager: binariesManager,
                             targetsHasher: targetsHasher(workingDirectory: workingDirectory),
                             cacheDownloader: cacheDownloader,
                             metricsLogger: metricsLogger)
    }
}
