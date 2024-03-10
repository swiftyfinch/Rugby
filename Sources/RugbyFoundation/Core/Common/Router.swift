import Fish

// MARK: - Interface

/// The protocol describing router with all Rugby paths.
public protocol IRouter: AnyObject {
    /// The directory with Pods folder.
    var workingDirectory: IFolder { get }

    /// The path to the rugby shared folder.
    var rugbySharedFolderPath: String { get }

    /// The path to the binaries folder.
    var binFolderPath: String { get }

    /// The path to the tests impact folder.
    var testsImpactFolderPath: String { get }

    /// The path to the logs folder.
    var logsFolderPath: String { get }
}

public extension IRouter {
    /// The path to Pods folder.
    var podsPath: String { workingDirectory.subpath(.pods) }
    /// The path to Pods project.
    var podsProjectPath: String { workingDirectory.subpath(.pods, .podsProject) }
    /// The path to .rugby folder.
    var rugbyPath: String { workingDirectory.subpath(.rugby) }
    /// The path to build folder.
    var buildPath: String { workingDirectory.subpath(.rugby, .build) }
    /// The path to backup folder.
    var backupPath: String { workingDirectory.subpath(.rugby, .backup) }
    /// The path to tests folder.
    var testsPath: String { workingDirectory.subpath(.rugby, .tests) }

    /// Returns a path to rawBuild.log which contained subpath.
    func rawLogPath(subpath: String) -> String {
        logsFolderPath.subpath(subpath, .rawBuildLog)
    }

    /// Returns a path to build.log which contained subpath.
    func beautifiedLog(subpath: String) -> String {
        logsFolderPath.subpath(subpath, .buildLog)
    }
}

// MARK: - Implementation

/// The service providing all paths for Rugby infrastructure.
public final class Router: IRouter {
    public let workingDirectory: IFolder
    public let rugbySharedFolderPath: String
    public let binFolderPath: String
    public let testsImpactFolderPath: String
    public let logsFolderPath: String

    /// Creates a router.
    /// - Parameters:
    ///   - workingDirectory: The directory with Pods folder.
    ///   - sharedFolderPath: The path to the main shared folder.
    public init(
        workingDirectory: IFolder,
        sharedFolderPath: String
    ) {
        self.workingDirectory = workingDirectory
        rugbySharedFolderPath = sharedFolderPath.subpath(.rugby)
        binFolderPath = sharedFolderPath.subpath(.rugby, .bin)
        testsImpactFolderPath = sharedFolderPath.subpath(.rugby, .tests)
        logsFolderPath = sharedFolderPath.subpath(.rugby, .logs)
    }
}

// MARK: - Constants

private extension String {
    static let rugby = ".rugby"
    static let logs = "logs"
    static let bin = "bin"
    static let tests = "tests"
    static let pods = "Pods"
    static let podsProject = "Pods.xcodeproj"
    static let build = "build"
    static let rawBuildLog = "rawBuild.log"
    static let buildLog = "build.log"
    static let backup = "backup"
}
