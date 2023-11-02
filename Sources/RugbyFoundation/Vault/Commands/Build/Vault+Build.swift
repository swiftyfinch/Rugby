import Fish
import Rainbow

extension Vault {
    /// The manager to build CocoaPods project.
    /// - Parameter workingDirectory: A directory with Pods folder.
    public func buildManager(workingDirectory: IFolder) -> IBuildManager {
        internalBuildManager(workingDirectory: workingDirectory)
    }

    // MARK: - Internal

    func internalBuildManager(workingDirectory: IFolder) -> IInternalBuildManager {
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
        let xcodeBuild = XcodeBuild(xcodeBuildExecutor: xcodeBuildExecutor)
        return BuildManager(logger: logger,
                            buildTargetsManager: buildTargetsManager,
                            librariesPatcher: LibrariesPatcher(logger: logger),
                            xcodeProject: xcodeProject,
                            rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
                            backupManager: backupManager(workingDirectory: workingDirectory),
                            processMonitor: processMonitor,
                            xcodeBuild: xcodeBuild,
                            binariesManager: binariesManager,
                            targetsHasher: targetsHasher(workingDirectory: workingDirectory),
                            useBinariesManager: useBinariesManager,
                            binariesCleaner: binariesCleaner,
                            environmentCollector: environmentCollector,
                            featureToggles: featureToggles,
                            targetTreePainter: TargetTreePainter())
    }
}
