import Fish

public extension Vault {
    /// The manager to analyse test targets in CocoaPods project.
    func testImpactManager() -> ITestImpactManager {
        let xcodeProject = xcode.project(projectPath: router.podsProjectPath)
        return internalTestImpactManager(xcodeProject: xcodeProject)
    }

    internal func internalTestImpactManager(xcodeProject: IInternalXcodeProject) -> IInternalTestImpactManager {
        TestImpactManager(
            logger: logger,
            environmentCollector: environmentCollector,
            rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
            buildTargetsManager: BuildTargetsManager(xcodeProject: xcodeProject),
            targetsHasher: targetsHasher(),
            testsStorage: TestsStorage(
                logger: logger,
                binariesStorage: binariesStorage,
                sharedPath: router.testsImpactFolderPath
            )
        )
    }
}
