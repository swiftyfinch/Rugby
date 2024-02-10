import Fish

extension Vault {
    /// The manager to use built binaries instead of targets in CocoaPods project.
    public func useBinariesManager() -> IUseBinariesManager {
        let xcodeProject = xcode.project(projectPath: router.podsProjectPath)
        return useBinariesManager(xcodeProject: xcodeProject,
                                  buildTargetsManager: BuildTargetsManager(xcodeProject: xcodeProject))
    }

    func useBinariesManager(xcodeProject: IInternalXcodeProject,
                            buildTargetsManager: IBuildTargetsManager) -> IUseBinariesManager {
        UseBinariesManager(logger: logger,
                           buildTargetsManager: buildTargetsManager,
                           librariesPatcher: LibrariesPatcher(logger: logger),
                           xcodeProject: xcodeProject,
                           rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
                           backupManager: backupManager(),
                           binariesStorage: binariesStorage,
                           targetsHasher: targetsHasher(),
                           supportFilesPatcher: SupportFilesPatcher(),
                           fileContentEditor: FileContentEditor())
    }
}
