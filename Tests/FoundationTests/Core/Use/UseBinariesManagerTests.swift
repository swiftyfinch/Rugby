import Rainbow
@testable import RugbyFoundation
import XCTest

// swiftlint:disable line_length

final class UseBinariesManagerTests: XCTestCase {
    private var sut: IUseBinariesManager!
    private var logger: ILoggerMock!
    private var loggerBlockInvocations: [
        (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
    ]!
    private var buildTargetsManager: IBuildTargetsManagerMock!
    private var librariesPatcher: ILibrariesPatcherMock!
    private var xcodeProject: IInternalXcodeProjectMock!
    private var rugbyXcodeProject: IRugbyXcodeProjectMock!
    private var backupManager: IBackupManagerMock!
    private var binariesStorage: IBinariesStorageMock!
    private var targetsHasher: ITargetsHasherMock!
    private var supportFilesPatcher: ISupportFilesPatcherMock!
    private var fileContentEditor: IFileContentEditorMock!

    override func setUp() {
        super.setUp()
        Rainbow.enabled = false
        logger = ILoggerMock()
        loggerBlockInvocations = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            self.loggerBlockInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }

        buildTargetsManager = IBuildTargetsManagerMock()
        librariesPatcher = ILibrariesPatcherMock()
        xcodeProject = IInternalXcodeProjectMock()
        rugbyXcodeProject = IRugbyXcodeProjectMock()
        backupManager = IBackupManagerMock()
        binariesStorage = IBinariesStorageMock()
        targetsHasher = ITargetsHasherMock()
        supportFilesPatcher = ISupportFilesPatcherMock()
        fileContentEditor = IFileContentEditorMock()
        sut = UseBinariesManager(
            logger: logger,
            buildTargetsManager: buildTargetsManager,
            librariesPatcher: librariesPatcher,
            xcodeProject: xcodeProject,
            rugbyXcodeProject: rugbyXcodeProject,
            backupManager: backupManager,
            binariesStorage: binariesStorage,
            targetsHasher: targetsHasher,
            supportFilesPatcher: supportFilesPatcher,
            fileContentEditor: fileContentEditor
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        logger = nil
        loggerBlockInvocations = nil
        buildTargetsManager = nil
        librariesPatcher = nil
        xcodeProject = nil
        rugbyXcodeProject = nil
        backupManager = nil
        binariesStorage = nil
        targetsHasher = nil
        supportFilesPatcher = nil
        fileContentEditor = nil
    }
}

extension UseBinariesManagerTests {
    func test_useTargetsRegex_isAlreadyUsingRugby() async throws {
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = true

        // Act
        var resultError: Error?
        do {
            try await sut.use(
                targetsRegex: nil,
                exceptTargetsRegex: nil,
                xcargs: [],
                deleteSources: false
            )
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? RugbyError, .alreadyUseRugby)
        XCTAssertEqual(
            resultError?.localizedDescription,
            """
            The project is already using 🏈 Rugby.
            🚑 Call "rugby rollback" or "pod install".
            """
        )
    }

    func test_useTargetsRegex_empty() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "^Alamofire$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^SnapKit$")
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsReturnValue = [:]

        // Act
        try await sut.use(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            xcargs: [],
            deleteSources: false
        )

        // Assert
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments?.targets, targetsRegex)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments?.exceptTargets, exceptTargetsRegex)

        XCTAssertEqual(loggerBlockInvocations.count, 1)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Skip")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
    }

    func test_useTargetsRegex_full() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "^Moya|SnapKit.*$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^Alamofire$")
        rugbyXcodeProject.isAlreadyUsingRugbyReturnValue = false
        let alamofire = IInternalTargetMock()
        alamofire.product = Product(name: "Alamofire", moduleName: "Alamofire", type: .framework, parentFolderName: "Alamofire")
        alamofire.underlyingUuid = "test_alamofire_uuid"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        snapkit.product = Product(name: "SnapKit", moduleName: "SnapKit", type: .framework, parentFolderName: "SnapKit")
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        moya.product = Product(name: "Moya", moduleName: "Moya", type: .framework, parentFolderName: "Moya")
        moya.dependencies = [alamofire.uuid: alamofire]
        let localPod = IInternalTargetMock()
        localPod.underlyingUuid = "test_localPod_uuid"
        localPod.product = Product(name: "LocalPod", moduleName: "LocalPod", type: .framework, parentFolderName: "LocalPod")
        localPod.dependencies = [alamofire.uuid: alamofire, snapkit.uuid: snapkit]
        localPod.resourceBundleNamesReturnValue = ["LocalPodResources"]
        let localPodResources = IInternalTargetMock()
        localPodResources.underlyingUuid = "test_localPodResources_uuid"
        localPodResources.product = Product(name: "LocalPodResources", moduleName: "LocalPodResources", type: .framework, parentFolderName: "LocalPodResources")
        buildTargetsManager.findTargetsExceptTargetsIncludingTestsClosure = { targets, exceptTargets, _ in
            guard targets == targetsRegex, exceptTargets == exceptTargetsRegex else { fatalError() }
            return [
                snapkit.uuid: snapkit,
                moya.uuid: moya,
                localPodResources.uuid: localPodResources
            ]
        }
        xcodeProject.findTargetsByExceptIncludingDependenciesClosure = { targets, exceptTargets, including in
            guard targets == nil, exceptTargets == nil, !including else { fatalError() }
            return [
                snapkit.uuid: snapkit,
                alamofire.uuid: alamofire,
                moya.uuid: moya,
                localPod.uuid: localPod,
                localPodResources.uuid: localPodResources
            ]
        }
        binariesStorage.xcodeBinaryFolderPathClosure = { target in
            switch target.uuid {
            case snapkit.uuid: return "${HOME}/.rugby/bin/SnapKit/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/f6aa8a7"
            default: fatalError()
            }
        }
        let snapkitReplacementRegex = try NSRegularExpression(pattern: "test_snapkit_replacement_regex")
        let snapkitFileReplacement: FileReplacement! = FileReplacement(
            replacements: [
                "test_snapkit_lookup0": "test_snapkit_replacement0",
                "test_snapkit_lookup1": "test_snapkit_replacement1"
            ],
            filePath: "test_snapkit_filePath",
            regex: snapkitReplacementRegex
        )
        supportFilesPatcher.prepareReplacementsForTargetClosure = { target in
            guard target.uuid == localPod.uuid else { fatalError() }
            return [snapkitFileReplacement] // It's not a real example
        }

        // Act
        try await sut.use(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            xcargs: ["test_xcarg0", "test_xcarg1"],
            deleteSources: false
        )

        // Assert
        XCTAssertEqual(loggerBlockInvocations.count, 6)

        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Build Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsCallsCount, 1)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments?.targets, targetsRegex)
        XCTAssertEqual(buildTargetsManager.findTargetsExceptTargetsIncludingTestsReceivedArguments?.exceptTargets, exceptTargetsRegex)

        XCTAssertEqual(loggerBlockInvocations[1].header, "Backuping")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)
        XCTAssertEqual(backupManager.backupKindCallsCount, 1)
        let backupKindReceivedArguments = try XCTUnwrap(backupManager.backupKindReceivedArguments)
        XCTAssertIdentical(backupKindReceivedArguments.xcodeProject as? IInternalXcodeProjectMock, xcodeProject)
        XCTAssertEqual(backupKindReceivedArguments.kind, .original)

        XCTAssertEqual(librariesPatcher.patchCallsCount, 1)
        let patchReceivedTargets = try XCTUnwrap(librariesPatcher.patchReceivedTargets)
        XCTAssertEqual(patchReceivedTargets.count, 3)
        XCTAssertTrue(patchReceivedTargets.contains(snapkit.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(moya.uuid))
        XCTAssertTrue(patchReceivedTargets.contains(localPodResources.uuid))

        XCTAssertEqual(loggerBlockInvocations[2].header, "Hashing Targets")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)
        XCTAssertEqual(targetsHasher.hashXcargsCallsCount, 1)
        let hashXcargsReceivedArguments = try XCTUnwrap(targetsHasher.hashXcargsReceivedArguments)
        XCTAssertEqual(hashXcargsReceivedArguments.targets.count, 3)
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(moya.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(snapkit.uuid))
        XCTAssertTrue(hashXcargsReceivedArguments.targets.contains(localPodResources.uuid))
        XCTAssertEqual(hashXcargsReceivedArguments.xcargs, ["test_xcarg0", "test_xcarg1"])

        XCTAssertEqual(loggerBlockInvocations[3].header, "Patching Product Files")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesCallsCount, 1)
        XCTAssertEqual(binariesStorage.xcodeBinaryFolderPathCallsCount, 1)
        XCTAssertEqual(supportFilesPatcher.prepareReplacementsForTargetCallsCount, 1)
        XCTAssertEqual(supportFilesPatcher.prepareReplacementsForTargetReceivedTarget?.uuid, localPod.uuid)
        XCTAssertEqual(fileContentEditor.replaceRegexFilePathCallsCount, 1)
        let replaceRegexFilePathReceivedArguments = try XCTUnwrap(fileContentEditor.replaceRegexFilePathReceivedArguments)
        XCTAssertEqual(replaceRegexFilePathReceivedArguments.replacements, snapkitFileReplacement.replacements)
        XCTAssertEqual(replaceRegexFilePathReceivedArguments.filePath, snapkitFileReplacement.filePath)
        XCTAssertEqual(replaceRegexFilePathReceivedArguments.replacements, snapkitFileReplacement.replacements)

        XCTAssertEqual(loggerBlockInvocations[4].header, "Deleting Targets (2)")
        XCTAssertNil(loggerBlockInvocations[4].footer)
        XCTAssertNil(loggerBlockInvocations[4].metricKey)
        XCTAssertEqual(loggerBlockInvocations[4].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[4].output, .all)
        XCTAssertEqual(xcodeProject.deleteTargetsKeepGroupsCallsCount, 1)
        let deleteTargetsKeepGroupsReceivedArguments = try XCTUnwrap(xcodeProject.deleteTargetsKeepGroupsReceivedArguments)
        XCTAssertEqual(deleteTargetsKeepGroupsReceivedArguments.targetsForRemove.count, 2)
        XCTAssertTrue(deleteTargetsKeepGroupsReceivedArguments.targetsForRemove.contains(snapkit.uuid))
        XCTAssertTrue(deleteTargetsKeepGroupsReceivedArguments.targetsForRemove.contains(moya.uuid))
        XCTAssertTrue(deleteTargetsKeepGroupsReceivedArguments.keepGroups)

        XCTAssertEqual(rugbyXcodeProject.markAsUsingRugbyCallsCount, 1)

        XCTAssertEqual(loggerBlockInvocations[5].header, "Saving Project")
        XCTAssertNil(loggerBlockInvocations[5].footer)
        XCTAssertNil(loggerBlockInvocations[5].metricKey)
        XCTAssertEqual(loggerBlockInvocations[5].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[5].output, .all)
        XCTAssertEqual(xcodeProject.saveCallsCount, 1)
    }
}

// swiftlint:enable line_length
