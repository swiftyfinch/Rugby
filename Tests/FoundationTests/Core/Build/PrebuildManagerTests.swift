import Rainbow
@testable import RugbyFoundation
import XCTest

final class PrebuildManagerTests: XCTestCase {
    private var sut: IPrebuildManager!
    private var logger: ILoggerMock!
    private var xcodePhaseEditor: IXcodePhaseEditorMock!
    private var buildManager: IInternalBuildManagerMock!
    private var xcodeProject: IInternalXcodeProjectMock!
    private var binariesManager: IBinariesStorageMock!

    override func setUp() {
        super.setUp()
        logger = ILoggerMock()
        xcodePhaseEditor = IXcodePhaseEditorMock()
        buildManager = IInternalBuildManagerMock()
        xcodeProject = IInternalXcodeProjectMock()
        binariesManager = IBinariesStorageMock()
        sut = PrebuildManager(
            logger: logger,
            xcodePhaseEditor: xcodePhaseEditor,
            buildManager: buildManager,
            xcodeProject: xcodeProject,
            binariesManager: binariesManager
        )
        Rainbow.enabled = true
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        logger = nil
        xcodePhaseEditor = nil
        buildManager = nil
        xcodeProject = nil
        binariesManager = nil
    }
}

extension PrebuildManagerTests {
    var options: XcodeBuildOptions {
        .init(
            sdk: .sim,
            config: "Debug",
            arch: "arm64",
            xcargs: ["test_arg0"],
            resultBundlePath: nil
        )
    }

    var paths: XcodeBuildPaths {
        .init(
            project: "test_project",
            symroot: "test_symroot",
            rawLog: "test_rawLog",
            beautifiedLog: "test_beautifiedLog"
        )
    }
}

extension PrebuildManagerTests {
    func test_zeroTargets() async throws {
        var logReceivedInvocations: [
            // swiftlint:disable:next large_tuple
            (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
        ] = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            logReceivedInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }
        buildManager.prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesReturnValue = [:]
        let targetsRegex = try NSRegularExpression(pattern: ".*")
        let exceptTargetsRegex = try NSRegularExpression(pattern: ".?")

        // Act
        try await sut.prebuild(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            options: options,
            paths: paths
        )

        // Assert
        XCTAssertEqual(buildManager.prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesCallsCount, 1)
        let buildArgs = try XCTUnwrap(
            buildManager.prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesReceivedArguments
        )
        XCTAssertEqual(buildArgs.targetsRegex, targetsRegex)
        XCTAssertEqual(buildArgs.exceptTargetsRegex, exceptTargetsRegex)
        XCTAssertFalse(buildArgs.patchLibraries)
        XCTAssertFalse(buildArgs.freeSpaceIfNeeded)

        XCTAssertEqual(xcodePhaseEditor.keepOnlyPreSourceScriptPhasesInCallsCount, 1)
        XCTAssertEqual(xcodePhaseEditor.keepOnlyPreSourceScriptPhasesInReceivedTargets?.isEmpty, true)

        XCTAssertEqual(xcodePhaseEditor.deleteCopyXCFrameworksPhaseInCallsCount, 1)
        XCTAssertEqual(xcodePhaseEditor.deleteCopyXCFrameworksPhaseInReceivedTargets?.isEmpty, true)

        XCTAssertEqual(logReceivedInvocations.count, 1)
        XCTAssertEqual(logReceivedInvocations.first?.header, "\u{1B}[32mRemoving Build Phases\u{1B}[0m")
        XCTAssertNil(logReceivedInvocations.first?.footer)
        XCTAssertNil(logReceivedInvocations.first?.metricKey)
        XCTAssertEqual(logReceivedInvocations.first?.level, .compact)
        XCTAssertEqual(logReceivedInvocations.first?.output, .all)

        XCTAssertEqual(xcodeProject.resetCacheCallsCount, 1)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.first?.text, "\u{1B}[32mSkip\u{1B}[0m")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.first?.level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.first?.output, .all)
    }

    func test_build() async throws {
        let dependencyTarget = IInternalTargetMock()
        dependencyTarget.uuid = "test_dependencyTarget"
        let target0 = IInternalTargetMock()
        target0.underlyingUuid = "test_target0"
        target0.buildPhases = [BuildPhase(name: "test_target0_buildPhase", type: .copyFiles)]
        target0.dependencies = [dependencyTarget.uuid: dependencyTarget]
        let target1 = IInternalTargetMock()
        target1.underlyingUuid = "test_target1"
        buildManager.prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesReturnValue = [
            target0.uuid: target0,
            target1.uuid: target1
        ]
        logger.logFooterMetricKeyLevelOutputBlockClosure = { _, _, _, _, _, block in try await block() }
        let buildTarget = IInternalTargetMock()
        buildManager.makeBuildTargetReturnValue = buildTarget

        // Act
        try await sut.prebuild(
            targetsRegex: nil,
            exceptTargetsRegex: nil,
            options: options,
            paths: paths
        )

        // Assert
        XCTAssertEqual(xcodePhaseEditor.keepOnlyPreSourceScriptPhasesInCallsCount, 1)
        let keepReceivedTargets = try XCTUnwrap(xcodePhaseEditor.keepOnlyPreSourceScriptPhasesInReceivedTargets)
        XCTAssertEqual(keepReceivedTargets.count, 3)
        XCTAssertTrue(keepReceivedTargets[target0.uuid] === target0)
        XCTAssertTrue(keepReceivedTargets[target1.uuid] === target1)
        XCTAssertTrue(keepReceivedTargets[dependencyTarget.uuid] === dependencyTarget)

        XCTAssertEqual(xcodePhaseEditor.deleteCopyXCFrameworksPhaseInCallsCount, 1)
        let deleteReceivedTargets = try XCTUnwrap(xcodePhaseEditor.deleteCopyXCFrameworksPhaseInReceivedTargets)
        XCTAssertEqual(deleteReceivedTargets.count, 3)
        XCTAssertTrue(deleteReceivedTargets[target0.uuid] === target0)
        XCTAssertTrue(deleteReceivedTargets[target1.uuid] === target1)
        XCTAssertTrue(deleteReceivedTargets[dependencyTarget.uuid] === dependencyTarget)

        XCTAssertEqual(buildManager.makeBuildTargetCallsCount, 1)
        XCTAssertEqual(buildManager.makeBuildTargetReceivedTargets?.count, 1)
        XCTAssertTrue(buildManager.makeBuildTargetReceivedTargets?[target0.uuid] === target0)

        XCTAssertEqual(buildManager.buildOptionsPathsCallsCount, 1)
        let buildArgs = try XCTUnwrap(buildManager.buildOptionsPathsReceivedArguments)
        XCTAssertTrue(buildArgs.target === buildTarget)
        XCTAssertEqual(buildArgs.options, options)
        XCTAssertEqual(buildArgs.paths, paths)
    }
}
