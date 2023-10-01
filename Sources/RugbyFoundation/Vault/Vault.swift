import Fish

/// The main container of Rugby stuff.
public final class Vault {
    /// The shared singleton instance.
    public static private(set) var shared: Vault!

    /// Setups the shared singleton instance.
    /// - Parameters:
    ///   - featureToggles: The service providing the feature toggles.
    ///   - logger: The service collecting information about Rugby execution.
    public static func setupShared(featureToggles: IFeatureToggles, logger: ILogger) {
        shared = Vault(featureToggles: featureToggles, logger: logger)
    }

    // MARK: - Init

    let featureToggles: IFeatureToggles
    /// The general Rugby settings.
    public let settings = Settings()
    /// The service collecting information about Rugby execution.
    public let logger: ILogger

    private init(featureToggles: IFeatureToggles,
                 logger: ILogger) {
        self.featureToggles = featureToggles
        self.logger = logger
    }

    // MARK: - Base

    /// The service to monitor Rugby child processes.
    public let processMonitor: IProcessMonitor = ProcessMonitor()

    /// The service to execute shell commands from Rugby.
    public private(set) lazy var shellExecutor: IShellExecutor = ShellExecutor(processMonitor: processMonitor)

    /// The service to play sound notifications.
    public private(set) lazy var soundPlayer: ISoundPlayer = SoundPlayer(shellExecutor: shellExecutor)

    /// The service providing all paths for Rugby infrastructure.
    public let router = Router()

    /// Returns the backup manager to save or restore an Xcode project state.
    public func backupManager(workingDirectory: IFolder) -> IBackupManager {
        BackupManager(backupFolderPath: router.paths(relativeTo: workingDirectory).backup,
                      workingDirectory: workingDirectory,
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
        shellExecutor: shellExecutor,
        swiftVersionProvider: swiftVersionProvider,
        architectureProvider: architectureProvider,
        xcodeCLTVersionProvider: XcodeCLTVersionProvider(shellExecutor: shellExecutor)
    )

    // MARK: - Logs

    /// The service to keep only latest logs.
    public private(set) lazy var logsRotator = LogsRotator(logsPath: router.paths.logsFolder)

    /// The service to log commands metrics.
    public private(set) lazy var metricsLogger = MetricsLogger(folderPath: router.paths.logsFolder)

    // MARK: - Common

    private(set) lazy var binariesManager = BinariesStorage(
        logger: logger,
        sharedPath: router.paths.binFolder,
        keepHashYamls: featureToggles.keepHashYamls
    )
    func targetsHasher(workingDirectory: IFolder) -> TargetsHasher {
        let foundationHasher = SHA1Hasher()
        let fileContentHasher = FileContentHasher(
            foundationHasher: foundationHasher,
            workingDirectory: workingDirectory
        )
        return TargetsHasher(
            foundationHasher: foundationHasher,
            swiftVersionProvider: swiftVersionProvider,
            buildPhaseHasher: BuildPhaseHasher(
                workingDirectory: workingDirectory,
                logger: logger,
                foundationHasher: foundationHasher,
                fileContentHasher: fileContentHasher,
                xcodeEnvResolver: XcodeEnvResolver(
                    logger: logger,
                    env: [
                        .SRCROOT: router.paths(relativeTo: workingDirectory).pods,
                        .BUILD_DIR: router.paths(relativeTo: workingDirectory).build
                    ]
                )
            ),
            cocoaPodsScriptsHasher: CocoaPodsScriptsHasher(fileContentHasher: fileContentHasher),
            configurationsHasher: ConfigurationsHasher(foundationHasher: foundationHasher,
                                                       excludeKeys: [settings.hasBackupKey]),
            productHasher: ProductHasher(foundationHasher: foundationHasher),
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
}

// MARK: - Keys

private extension String {
    static let SRCROOT = "SRCROOT"
    static let BUILD_DIR = "BUILD_DIR" // swiftlint:disable:this identifier_name
}
