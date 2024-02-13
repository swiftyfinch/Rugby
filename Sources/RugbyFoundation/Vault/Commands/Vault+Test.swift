import Fish

public extension Vault {
    /// The manager to analyse test targets in CocoaPods project.
    func testManager() -> ITestManager {
        let xcodeProject = xcode.project(projectPath: router.podsProjectPath)
        return TestManager(
            logger: logger,
            environmentCollector: environmentCollector,
            rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
            buildTargetsManager: BuildTargetsManager(xcodeProject: xcodeProject),
            targetsHasher: targetsHasher(),
            testsStorage: TestsStorage(
                logger: logger,
                binariesStorage: binariesStorage,
                sharedPath: router.testsFolderPath
            )
        )
    }
}
