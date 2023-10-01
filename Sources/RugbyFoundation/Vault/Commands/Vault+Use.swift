import Fish

extension Vault {
    /// The manager to use built binaries instead of targets in CocoaPods project.
    /// - Parameter workingDirectory: A directory with Pods folder.
    public func useBinariesManager(workingDirectory: IFolder) -> IUseBinariesManager {
        let xcodeProject = xcode.project(projectPath: router.paths(relativeTo: workingDirectory).podsProject)
        return useBinariesManager(workingDirectory: workingDirectory,
                                  xcodeProject: xcodeProject,
                                  buildTargetsManager: BuildTargetsManager(xcodeProject: xcodeProject))
    }

    func useBinariesManager(workingDirectory: IFolder,
                            xcodeProject: XcodeProject,
                            buildTargetsManager: BuildTargetsManager) -> IUseBinariesManager {
        UseBinariesManager(logger: logger,
                           buildTargetsManager: buildTargetsManager,
                           xcodeProject: xcodeProject,
                           rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
                           backupManager: backupManager(workingDirectory: workingDirectory),
                           binariesManager: binariesManager,
                           targetsHasher: targetsHasher(workingDirectory: workingDirectory),
                           supportFilesPatcher: SupportFilesPatcher(),
                           fileContentEditor: FileContentEditor())
    }
}
