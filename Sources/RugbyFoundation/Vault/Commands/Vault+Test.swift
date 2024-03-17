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
            ),
            git: git,
            targetsPrinter: targetsPrinter
        )
    }

    /// The manager to test in CocoaPods project.
    func testManager() -> ITestManager {
        let xcodeProject = xcode.project(projectPath: router.podsProjectPath)
        let buildTargetsManager = BuildTargetsManager(xcodeProject: xcodeProject)
        return TestManager(
            logger: logger,
            environmentCollector: environmentCollector,
            rugbyXcodeProject: RugbyXcodeProject(xcodeProject: xcodeProject),
            buildTargetsManager: buildTargetsManager,
            useBinariesManager: internalUseBinariesManager(
                xcodeProject: xcodeProject,
                buildTargetsManager: buildTargetsManager
            ),
            buildManager: internalBuildManager(),
            xcodeProject: xcodeProject,
            testplanEditor: TestplanEditor(
                xcodeProject: xcodeProject,
                workingDirectory: router.workingDirectory
            ),
            xcodeBuild: xcodeBuild(),
            testImpactManager: internalTestImpactManager(xcodeProject: xcodeProject),
            backupManager: backupManager(),
            processMonitor: processMonitor,
            simCTL: simCTL,
            testsStorage: TestsStorage(
                logger: logger,
                binariesStorage: binariesStorage,
                sharedPath: router.testsImpactFolderPath
            ),
            testsFolderPath: router.testsPath,
            targetsPrinter: targetsPrinter
        )
    }
}
