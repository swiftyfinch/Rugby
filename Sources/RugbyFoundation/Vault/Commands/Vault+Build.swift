import Fish
import Rainbow

public extension Vault {
    /// The manager to build CocoaPods project.
    /// - Parameter workingDirectory: A directory with Pods folder.
    func buildManager(workingDirectory: IFolder) -> IBuildManager {
        let logFormatter = BuildLogFormatter(colored: Rainbow.enabled)
        let xcodeBuildExecutor = XcodeBuildExecutor(
            shellExecutor: shellExecutor,
            logFormatter: logFormatter,
            workingDirectory: workingDirectory
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
