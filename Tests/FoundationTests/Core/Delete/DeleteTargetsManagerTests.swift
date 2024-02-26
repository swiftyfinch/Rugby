import Rainbow
@testable import RugbyFoundation
import XCTest

// swiftlint:disable line_length

final class DeleteTargetsManagerTests: XCTestCase {
    private var sut: IDeleteTargetsManager!

    private var logger: ILoggerMock!
    private var loggerBlockInvocations: [
        (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
    ]!
    private var xcodeProject: IInternalXcodeProjectMock!
    private var backupManager: IBackupManagerMock!

    override func setUp() {
        super.setUp()

        Rainbow.enabled = false
        logger = ILoggerMock()
        loggerBlockInvocations = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            self.loggerBlockInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }

        xcodeProject = IInternalXcodeProjectMock()
        backupManager = IBackupManagerMock()
        sut = DeleteTargetsManager(
            logger: logger,
            xcodeProject: xcodeProject,
            backupManager: backupManager
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        logger = nil
        loggerBlockInvocations = nil
        xcodeProject = nil
        backupManager = nil
    }
}

extension DeleteTargetsManagerTests {
    func test_empty() async throws {
        xcodeProject.findTargetsByExceptIncludingDependenciesReturnValue = [:]
        let targetsRegex = try NSRegularExpression(pattern: "^Alamofire$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^SnapKit$")

        // Act
        try await sut.delete(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            keepExceptedTargetsDependencies: false,
            deleteSources: false
        )

        // Assert
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations.count, 1)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[0].regex, targetsRegex)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[0].exceptRegex, exceptTargetsRegex)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[0].includingDependencies, false)

        XCTAssertEqual(loggerBlockInvocations.count, 1)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Skip")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
    }

    func test_empty_keepExceptedTargetsDependencies() async throws {
        xcodeProject.findTargetsByExceptIncludingDependenciesReturnValue = [:]
        let targetsRegex = try NSRegularExpression(pattern: "^Alamofire$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^SnapKit$")

        // Act
        try await sut.delete(
            targetsRegex: targetsRegex,
            exceptTargetsRegex: exceptTargetsRegex,
            keepExceptedTargetsDependencies: true,
            deleteSources: false
        )

        // Assert
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations.count, 2)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[0].regex, targetsRegex)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[0].exceptRegex, exceptTargetsRegex)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[0].includingDependencies, false)
        XCTAssertNil(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[1].regex)
        XCTAssertNil(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[1].exceptRegex)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[1].includingDependencies, false)

        XCTAssertEqual(loggerBlockInvocations.count, 2)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Keeping Excepted Targets Dependencies")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .info)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        XCTAssertEqual(logger.logLevelOutputReceivedInvocations.count, 1)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].text, "Skip")
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].level, .compact)
        XCTAssertEqual(logger.logLevelOutputReceivedInvocations[0].output, .all)
    }
}

extension DeleteTargetsManagerTests {
    func test_keepExceptedTargetsDependencies() async throws {
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        alamofire.underlyingName = "Alamofire"
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        moya.underlyingName = "Moya"
        moya.dependencies = [alamofire.uuid: alamofire]
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        snapkit.underlyingName = "Snapkit"
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^Moya$")
        xcodeProject.findTargetsByExceptIncludingDependenciesClosure = { regex, exceptRegex, includingDependencies in
            switch (regex, exceptRegex, includingDependencies) {
            case (nil, exceptTargetsRegex, false): return [alamofire.uuid: alamofire, snapkit.uuid: snapkit]
            case (nil, nil, false): return [alamofire.uuid: alamofire, snapkit.uuid: snapkit, moya.uuid: moya]
            default: fatalError()
            }
        }

        // Act
        try await sut.delete(
            targetsRegex: nil,
            exceptTargetsRegex: exceptTargetsRegex,
            keepExceptedTargetsDependencies: true,
            deleteSources: true
        )

        // Assert
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations.count, 2)
        XCTAssertEqual(loggerBlockInvocations.count, 5)

        XCTAssertNil(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[0].regex)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[0].exceptRegex, exceptTargetsRegex)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[0].includingDependencies, false)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Finding Targets")
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)

        XCTAssertNil(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[1].regex)
        XCTAssertNil(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[1].exceptRegex)
        XCTAssertEqual(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedInvocations[1].includingDependencies, false)
        XCTAssertEqual(loggerBlockInvocations[1].header, "Keeping Excepted Targets Dependencies")
        XCTAssertNil(loggerBlockInvocations[1].footer)
        XCTAssertNil(loggerBlockInvocations[1].metricKey)
        XCTAssertEqual(loggerBlockInvocations[1].level, .info)
        XCTAssertEqual(loggerBlockInvocations[1].output, .all)

        XCTAssertEqual(backupManager.backupKindReceivedInvocations.count, 1)
        XCTAssertEqual(backupManager.backupKindReceivedInvocations[0].kind, .original)
        XCTAssertIdentical(backupManager.backupKindReceivedInvocations[0].xcodeProject as? IInternalXcodeProjectMock, xcodeProject)
        XCTAssertEqual(loggerBlockInvocations[2].header, "Backuping")
        XCTAssertNil(loggerBlockInvocations[2].footer)
        XCTAssertNil(loggerBlockInvocations[2].metricKey)
        XCTAssertEqual(loggerBlockInvocations[2].level, .info)
        XCTAssertEqual(loggerBlockInvocations[2].output, .all)

        XCTAssertEqual(xcodeProject.deleteTargetsKeepGroupsReceivedInvocations.count, 1)
        XCTAssertEqual(xcodeProject.deleteTargetsKeepGroupsReceivedInvocations[0].targetsForRemove.map(\.value.uuid), [snapkit.uuid])
        XCTAssertFalse(xcodeProject.deleteTargetsKeepGroupsReceivedInvocations[0].keepGroups)
        XCTAssertEqual(loggerBlockInvocations[3].header, "Deleting Targets (1)")
        XCTAssertNil(loggerBlockInvocations[3].footer)
        XCTAssertNil(loggerBlockInvocations[3].metricKey)
        XCTAssertEqual(loggerBlockInvocations[3].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[3].output, .all)

        XCTAssertEqual(xcodeProject.saveCallsCount, 1)
        XCTAssertEqual(loggerBlockInvocations[4].header, "Saving Project")
        XCTAssertNil(loggerBlockInvocations[4].footer)
        XCTAssertNil(loggerBlockInvocations[4].metricKey)
        XCTAssertEqual(loggerBlockInvocations[4].level, .compact)
        XCTAssertEqual(loggerBlockInvocations[4].output, .all)
    }
}

// swiftlint:enable line_length
