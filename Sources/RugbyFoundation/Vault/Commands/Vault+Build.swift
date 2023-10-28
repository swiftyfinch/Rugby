import Fish
import Rainbow

public extension Vault {
    /// The manager to build CocoaPods project.
    /// - Parameter workingDirectory: A directory with Pods folder.
    func buildManager(workingDirectory: IFolder) -> IBuildManager {
        let logFormatter = BuildLogFormatter(workingDirectory: workingDirectory,
                                             colored: Rainbow.enabled)
        let xcodeBuildExecutor = XcodeBuildExecutor(
            shellExecutor: shellExecutor,
            logFormatter: logFormatter
        )
        let xcodeProject = xcode.project(projectPath: router.paths(relativeTo: workingDirectory).podsProject)
        let buildTargetsManager = BuildTargetsManager(xcodeProject: xcodeProject)
        let useBinariesManager = useBinariesManager(workingDirectory: workingDirectory,
                                                    xcodeProject: xcodeProject,
                                                    buildTargetsManager: buildTargetsManager)
        let binariesCleaner = BinariesCleaner(
            logger: logger,
            limit: settings.storageUsedLimit,
            sharedRugbyFolderPath: router.paths.sharedFolder,
            binariesFolderPath: router.paths.binFolder,
            localRugbyFolderPath: router.paths(relativeTo: workingDirectory).rugby,
            buildFolderPath: router.paths(relativeTo: workingDirectory).build
        )
        return BuildManager(logger: logger,
                            buildTargetsManager: buildTargetsManager,
                            librariesPatcher: LibrariesPatcher(),
                            xcodeProject: xcodeProject,
                            rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
                            backupManager: backupManager(workingDirectory: workingDirectory),
                            processMonitor: processMonitor,
                            xcodeBuild: XcodeBuild(xcodeBuildExecutor: xcodeBuildExecutor),
                            binariesManager: binariesManager,
                            targetsHasher: targetsHasher(workingDirectory: workingDirectory),
                            useBinariesManager: useBinariesManager,
                            binariesCleaner: binariesCleaner,
                            environmentCollector: environmentCollector,
                            featureToggles: featureToggles,
                            targetTreePainter: TargetTreePainter())
    }
}
