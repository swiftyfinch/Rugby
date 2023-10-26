import Fish

// MARK: - Interface

/// Xcode build options.
public struct XcodeBuildOptions: CustomStringConvertible {
    let sdk: SDK
    let config: String
    let arch: String
    let xcargs: [String]

    /// Initializer.
    /// - Parameters:
    ///   - sdk: SDK to use in xcodebuild.
    ///   - config: A config to use in xcodebuild.
    ///   - arch: An architecture to use in xcodebuild.
    ///   - xcargs: The xcargs to use in xcodebuild.
    public init(sdk: SDK,
                config: String,
                arch: String,
                xcargs: [String]) {
        self.sdk = sdk
        self.config = config
        self.arch = arch
        self.xcargs = xcargs
    }

    public var description: String {
        """
        sdk: \(sdk.xcodebuild)
        config: \(config)
        arch: \(arch)
        xcargs: [\(xcargs.joined(separator: ", "))]
        """
    }
}

/// The enumeration of available SDKs.
public enum SDK: String {
    case sim, ios

    var string: String { rawValue }
    var xcodebuild: String {
        switch self {
        case .sim: return "iphonesimulator"
        case .ios: return "iphoneos"
        }
    }
}

/// The collection of Xcode paths.
public struct XcodeBuildPaths {
    let project: String
    let symroot: String
    let rawLog: String
    let beautifiedLog: String

    /// Initializer.
    /// - Parameters:
    ///   - project: A path to Xcode project.
    ///   - symroot: A path to a build folder.
    ///   - rawLog: A path to a raw log file.
    ///   - beautifiedLog: A path to a formatted log file.
    public init(project: String,
                symroot: String,
                rawLog: String,
                beautifiedLog: String) {
        self.project = project
        self.symroot = symroot
        self.rawLog = rawLog
        self.beautifiedLog = beautifiedLog
    }
}

// MARK: - Implementation

final class XcodeBuild {
    private let xcodeBuildExecutor: XcodeBuildExecutor

    init(xcodeBuildExecutor: XcodeBuildExecutor) {
        self.xcodeBuildExecutor = xcodeBuildExecutor
    }

    func build(target: String,
               options: XcodeBuildOptions,
               paths: XcodeBuildPaths) throws {
        let command = "NSUnbufferedIO=YES xcodebuild"
        let arguments = [
            "-project \(paths.project.shellFriendly)",
            "-scheme \(target)",
            "-sdk \(options.sdk.xcodebuild)",
            "-config \(options.config.shellFriendly)",
            "ARCHS=\(options.arch)",
            "SYMROOT=\(paths.symroot.shellFriendly)"
        ] + options.xcargs

        try Folder.create(at: paths.symroot)
        try xcodeBuildExecutor.run(command,
                                   rawLogPath: paths.rawLog,
                                   logPath: paths.beautifiedLog,
                                   args: arguments)
    }
}
