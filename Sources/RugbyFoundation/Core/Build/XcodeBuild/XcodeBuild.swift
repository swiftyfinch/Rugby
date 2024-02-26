import Fish

// MARK: - Interface

protocol IXcodeBuild: AnyObject {
    func build(target: String,
               options: XcodeBuildOptions,
               paths: XcodeBuildPaths) async throws

    func test(scheme: String,
              testPlan: String,
              simulatorName: String,
              options: XcodeBuildOptions,
              paths: XcodeBuildPaths) async throws
}

/// Xcode build options.
public struct XcodeBuildOptions: Equatable {
    let sdk: SDK
    let config: String
    let arch: String
    let xcargs: [String]
    let resultBundlePath: String?

    /// Initializer.
    /// - Parameters:
    ///   - sdk: SDK to use in xcodebuild.
    ///   - config: A config to use in xcodebuild.
    ///   - arch: An architecture to use in xcodebuild.
    ///   - xcargs: The xcargs to use in xcodebuild.
    ///   - resultBundlePath: The resultBundlePath to use in xcodebuild.
    public init(sdk: SDK,
                config: String,
                arch: String,
                xcargs: [String],
                resultBundlePath: String?) {
        self.sdk = sdk
        self.config = config
        self.arch = arch
        self.xcargs = xcargs
        self.resultBundlePath = resultBundlePath
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
public struct XcodeBuildPaths: Equatable {
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
    private let xcodeBuildExecutor: IXcodeBuildExecutor

    init(xcodeBuildExecutor: IXcodeBuildExecutor) {
        self.xcodeBuildExecutor = xcodeBuildExecutor
    }

    private func run(
        arguments: [String],
        options: XcodeBuildOptions,
        paths: XcodeBuildPaths
    ) async throws {
        let command = "NSUnbufferedIO=YES xcodebuild"
        var arguments = arguments
        arguments.append(contentsOf: [
            "-project \(paths.project.shellFriendly)",
            "SYMROOT=\(paths.symroot.shellFriendly)"
        ])
        options.resultBundlePath.map {
            arguments.append("-resultBundlePath \($0.shellFriendly)")
        }
        arguments.append(contentsOf: options.xcargs)

        try Folder.create(at: paths.symroot)
        try await xcodeBuildExecutor.run(command,
                                         rawLogPath: paths.rawLog,
                                         logPath: paths.beautifiedLog,
                                         args: arguments)
    }
}

extension XcodeBuild: IXcodeBuild {
    func build(target: String,
               options: XcodeBuildOptions,
               paths: XcodeBuildPaths) async throws {
        try await run(
            arguments: [
                "-target \(target)",
                "-sdk \(options.sdk.xcodebuild)",
                "-config \(options.config.shellFriendly)",
                "ARCHS=\(options.arch)",
                "-parallelizeTargets"
            ],
            options: options,
            paths: paths
        )
    }

    func test(scheme: String,
              testPlan: String,
              simulatorName: String,
              options: XcodeBuildOptions,
              paths: XcodeBuildPaths) async throws {
        try await run(
            arguments: [
                "-scheme \(scheme.shellFriendly)",
                "-testPlan \(testPlan.shellFriendly)",
                "-destination 'platform=iOS Simulator,name=\(simulatorName)'",
                "test"
            ],
            options: options,
            paths: paths
        )
    }
}
