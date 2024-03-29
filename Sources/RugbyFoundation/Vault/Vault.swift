import Fish
import Foundation
import Rainbow

/// The main container of Rugby stuff.
public final class Vault {
    /// The shared singleton instance.
    public private(set) static var shared: Vault!

    /// Setups the shared singleton instance.
    /// - Parameters:
    ///   - featureToggles: The service providing the feature toggles.
    ///   - logger: The service collecting information about Rugby execution.
    ///   - router: The service providing all paths for Rugby infrastructure.
    public static func setupShared(
        env: IEnvironment,
        logger: ILogger,
        router: IRouter
    ) {
        shared = Vault(env: env, logger: logger, router: router)
    }

    // MARK: - Init

    /// The service providing environment variables.
    public let env: IEnvironment
    /// The general Rugby settings.
    public let settings = Settings()
    /// The service collecting information about Rugby execution.
    public let logger: ILogger
    /// The service providing all paths for Rugby infrastructure.
    public let router: IRouter

    private init(
        env: IEnvironment,
        logger: ILogger,
        router: IRouter
    ) {
        self.env = env
        self.logger = logger
        self.router = router
    }

    // MARK: - Base

    /// The service to monitor Rugby child processes.
    public let processMonitor: IProcessMonitor = ProcessMonitor()

    /// The service to execute shell commands from Rugby.
    public private(set) lazy var shellExecutor: IShellExecutor = ShellExecutor(processMonitor: processMonitor)

    /// The service to play sound notifications.
    public private(set) lazy var soundPlayer: ISoundPlayer = SoundPlayer(shellExecutor: shellExecutor)

    /// Returns the backup manager to save or restore an Xcode project state.
    public func backupManager() -> IBackupManager {
        BackupManager(backupFolderPath: router.backupPath,
                      workingDirectory: router.workingDirectory,
                      hasBackupKey: settings.hasBackupKey)
    }

    // MARK: - Environment

    /// The service providing xcargs which is used in Rugby.
    public private(set) lazy var xcargsProvider = XCARGSProvider()

    /// The service providing the current Swift version.
    public private(set) lazy var swiftVersionProvider: ISwiftVersionProvider = SwiftVersionProvider(
        shellExecutor: shellExecutor
    )

    /// The service providing the current CPU architecture.
    public private(set) lazy var architectureProvider: IArchitectureProvider = ArchitectureProvider(
        shellExecutor: shellExecutor
    )

    /// The service providing the environment information.
    public private(set) lazy var environmentCollector: IEnvironmentCollector = EnvironmentCollector(
        logger: logger,
        workingDirectory: router.workingDirectory,
        shellExecutor: shellExecutor,
        swiftVersionProvider: swiftVersionProvider,
        architectureProvider: architectureProvider,
        xcodeCLTVersionProvider: XcodeCLTVersionProvider(shellExecutor: shellExecutor),
        git: git
    )

    // MARK: - Logs

    /// The service to keep only latest logs.
    public private(set) lazy var logsRotator = LogsRotator(
        logsPath: router.logsFolderPath,
        shellExecutor: shellExecutor
    )

    /// The service to log commands metrics.
    public private(set) lazy var metricsLogger = MetricsLogger(folderPath: router.logsFolderPath)

    // MARK: - Common

    private(set) lazy var git = Git(shellExecutor: shellExecutor)
    private(set) lazy var simCTL = SimCTL(shellExecutor: shellExecutor)
    private(set) lazy var targetsPrinter = TargetsPrinter(logger: logger)
    private(set) lazy var binariesStorage = BinariesStorage(
        logger: logger,
        sharedPath: router.binFolderPath,
        keepHashYamls: env.keepHashYamls
    )
    private(set) lazy var envVariablesResolver: IEnvVariablesResolver = EnvVariablesResolver(
        logger: logger,
        env: ProcessInfo.processInfo.environment.merging([
            .SRCROOT: router.podsPath,
            .BUILD_DIR: router.buildPath
        ], uniquingKeysWith: { _, rhs in rhs })
    )
    func targetsHasher() -> ITargetsHasher {
        let foundationHasher = SHA1Hasher()
        let fileContentHasher = FileContentHasher(
            foundationHasher: foundationHasher,
            workingDirectory: router.workingDirectory
        )
        return TargetsHasher(
            foundationHasher: foundationHasher,
            swiftVersionProvider: swiftVersionProvider,
            buildPhaseHasher: BuildPhaseHasher(
                logger: logger,
                workingDirectoryPath: router.workingDirectory.path,
                fileContentHasher: fileContentHasher,
                envVariablesResolver: envVariablesResolver
            ),
            cocoaPodsScriptsHasher: CocoaPodsScriptsHasher(fileContentHasher: fileContentHasher),
            configurationsHasher: ConfigurationsHasher(excludeKeys: [settings.hasBackupKey]),
            productHasher: ProductHasher(),
            buildRulesHasher: BuildRulesHasher(foundationHasher: foundationHasher,
                                               fileContentHasher: fileContentHasher)
        )
    }

    // MARK: - Xcode

    /// The container of Xcode stuff.
    public private(set) lazy var xcode = XcodeVault(
        settings: settings,
        logger: logger,
        logsRotator: logsRotator,
        router: router
    )

    func xcodeBuild() -> XcodeBuild {
        let logFormatter = BuildLogFormatter(workingDirectory: router.workingDirectory,
                                             colored: Rainbow.enabled)
        let xcodeBuildExecutor = XcodeBuildExecutor(
            logger: logger,
            shellExecutor: shellExecutor,
            logFormatter: logFormatter
        )
        return XcodeBuild(xcodeBuildExecutor: xcodeBuildExecutor)
    }
}

// MARK: - Keys

private extension String {
    static let SRCROOT = "SRCROOT"
    static let BUILD_DIR = "BUILD_DIR" // swiftlint:disable:this identifier_name
}
