@testable import RugbyFoundation
import XCTest

final class BuildTargetsManagerTests: XCTestCase {
    private var sut: IBuildTargetsManager!
    private var xcodeProject: IInternalXcodeProjectMock!

    override func setUp() {
        super.setUp()
        xcodeProject = IInternalXcodeProjectMock()
        sut = BuildTargetsManager(xcodeProject: xcodeProject)
    }

    override func tearDown() {
        super.tearDown()
        xcodeProject = nil
        sut = nil
    }
}

extension BuildTargetsManagerTests {
    func test_findTargets_empty() async throws {
        let targetsRegex = try NSRegularExpression(pattern: "^Alamofire$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^SnapKit$")
        xcodeProject.findTargetsByExceptIncludingDependenciesReturnValue = [:]

        // Act
        let targets = try await sut.findTargets(targetsRegex, exceptTargets: exceptTargetsRegex)

        // Assert
        XCTAssertTrue(targets.isEmpty)
        let arguments = try XCTUnwrap(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedArguments)
        XCTAssertEqual(arguments.regex, targetsRegex)
        XCTAssertEqual(arguments.exceptRegex, exceptTargetsRegex)
        XCTAssertTrue(arguments.includingDependencies)
    }

    func test_findTargets() async throws {
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        alamofire.underlyingIsNative = true
        alamofire.underlyingIsTests = false
        alamofire.underlyingIsPodsUmbrella = false
        alamofire.underlyingIsApplication = false
        let localPodTests = IInternalTargetMock()
        localPodTests.underlyingUuid = "test_localPodTests_uuid"
        localPodTests.underlyingIsNative = true
        localPodTests.underlyingIsTests = true
        localPodTests.underlyingIsPodsUmbrella = false
        localPodTests.underlyingIsApplication = false
        let realm = IInternalTargetMock()
        realm.underlyingUuid = "test_realm_uuid"
        realm.underlyingIsNative = false
        realm.underlyingIsTests = false
        realm.underlyingIsPodsUmbrella = false
        realm.underlyingIsApplication = false
        let pods = IInternalTargetMock()
        pods.underlyingUuid = "test_pods_uuid"
        pods.underlyingIsNative = true
        pods.underlyingIsPodsUmbrella = true
        pods.underlyingIsTests = false
        pods.underlyingIsApplication = false
        let application = IInternalTargetMock()
        application.underlyingUuid = "test_application_uuid"
        application.underlyingIsNative = true
        application.underlyingIsPodsUmbrella = false
        application.underlyingIsTests = false
        application.underlyingIsApplication = true
        let targetsRegex = try NSRegularExpression(pattern: "^Alamofire$")
        let exceptTargetsRegex = try NSRegularExpression(pattern: "^SnapKit$")
        xcodeProject.findTargetsByExceptIncludingDependenciesReturnValue = [
            alamofire.uuid: alamofire,
            localPodTests.uuid: localPodTests,
            realm.uuid: realm,
            pods.uuid: pods,
            application.uuid: application
        ]

        // Act
        let targets = try await sut.findTargets(targetsRegex, exceptTargets: exceptTargetsRegex)

        // Assert
        XCTAssertEqual(targets.count, 1)
        XCTAssertEqual(targets.first?.key, alamofire.uuid)
        let arguments = try XCTUnwrap(xcodeProject.findTargetsByExceptIncludingDependenciesReceivedArguments)
        XCTAssertEqual(arguments.regex, targetsRegex)
        XCTAssertEqual(arguments.exceptRegex, exceptTargetsRegex)
        XCTAssertTrue(arguments.includingDependencies)
    }

    func test_filterTargets() async throws {
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        alamofire.underlyingIsNative = true
        alamofire.underlyingIsTests = false
        alamofire.underlyingIsPodsUmbrella = false
        alamofire.underlyingIsApplication = false
        let localPodTests = IInternalTargetMock()
        localPodTests.underlyingUuid = "test_localPodTests_uuid"
        localPodTests.underlyingIsNative = true
        localPodTests.underlyingIsTests = true
        localPodTests.underlyingIsPodsUmbrella = false
        localPodTests.underlyingIsApplication = false
        let realm = IInternalTargetMock()
        realm.underlyingUuid = "test_realm_uuid"
        realm.underlyingIsNative = false
        realm.underlyingIsTests = false
        realm.underlyingIsPodsUmbrella = false
        realm.underlyingIsApplication = false
        let pods = IInternalTargetMock()
        pods.underlyingUuid = "test_pods_uuid"
        pods.underlyingIsNative = true
        pods.underlyingIsPodsUmbrella = true
        pods.underlyingIsTests = false
        pods.underlyingIsApplication = false
        let application = IInternalTargetMock()
        application.underlyingUuid = "test_application_uuid"
        application.underlyingIsNative = true
        application.underlyingIsPodsUmbrella = false
        application.underlyingIsTests = false
        application.underlyingIsApplication = true
        let targets = [
            alamofire.uuid: alamofire,
            localPodTests.uuid: localPodTests,
            realm.uuid: realm,
            pods.uuid: pods,
            application.uuid: application
        ]

        // Act
        let filteredTargets = sut.filterTargets(targets, includingTests: true)

        // Assert
        XCTAssertEqual(filteredTargets.count, 2)
        XCTAssertTrue(filteredTargets.contains(alamofire.uuid))
        XCTAssertTrue(filteredTargets.contains(localPodTests.uuid))
    }

    func test_filterTargets_withoutTests() async throws {
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        alamofire.underlyingIsNative = true
        alamofire.underlyingIsTests = false
        alamofire.underlyingIsPodsUmbrella = false
        alamofire.underlyingIsApplication = false
        let localPodTests = IInternalTargetMock()
        localPodTests.underlyingUuid = "test_localPodTests_uuid"
        localPodTests.underlyingIsNative = true
        localPodTests.underlyingIsTests = true
        localPodTests.underlyingIsPodsUmbrella = false
        localPodTests.underlyingIsApplication = false
        let realm = IInternalTargetMock()
        realm.underlyingUuid = "test_realm_uuid"
        realm.underlyingIsNative = false
        realm.underlyingIsTests = false
        realm.underlyingIsPodsUmbrella = false
        realm.underlyingIsApplication = false
        let pods = IInternalTargetMock()
        pods.underlyingUuid = "test_pods_uuid"
        pods.underlyingIsNative = true
        pods.underlyingIsPodsUmbrella = true
        pods.underlyingIsTests = false
        pods.underlyingIsApplication = false
        let application = IInternalTargetMock()
        application.underlyingUuid = "test_application_uuid"
        application.underlyingIsNative = true
        application.underlyingIsPodsUmbrella = false
        application.underlyingIsTests = false
        application.underlyingIsApplication = true
        let targets = [
            alamofire.uuid: alamofire,
            localPodTests.uuid: localPodTests,
            realm.uuid: realm,
            pods.uuid: pods,
            application.uuid: application
        ]

        // Act
        let filteredTargets = sut.filterTargets(targets)

        // Assert
        XCTAssertEqual(filteredTargets.count, 1)
        XCTAssertTrue(filteredTargets.contains(alamofire.uuid))
    }

    func test_createTarget() async throws {
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        let moya = IInternalTargetMock()
        moya.underlyingUuid = "test_moya_uuid"
        let snapkit = IInternalTargetMock()
        snapkit.underlyingUuid = "test_snapkit_uuid"
        let targets = [
            alamofire.uuid: alamofire,
            moya.uuid: moya,
            snapkit.uuid: snapkit
        ]
        let resultTarget = IInternalTargetMock()
        xcodeProject.createAggregatedTargetNameDependenciesReturnValue = resultTarget

        // Act
        let target = try await sut.createTarget(dependencies: targets)

        // Assert
        XCTAssertIdentical(resultTarget, target)
        XCTAssertEqual(xcodeProject.createAggregatedTargetNameDependenciesCallsCount, 1)
        let arguments = try XCTUnwrap(xcodeProject.createAggregatedTargetNameDependenciesReceivedArguments)
        XCTAssertEqual(arguments.name, "RugbyPods")
        XCTAssertEqual(arguments.dependencies.count, 3)
        XCTAssertTrue(arguments.dependencies.contains(alamofire.uuid))
        XCTAssertTrue(arguments.dependencies.contains(moya.uuid))
        XCTAssertTrue(arguments.dependencies.contains(snapkit.uuid))
    }

    func test_createTarget_forTests() async throws {
        let alamofire = IInternalTargetMock()
        alamofire.underlyingUuid = "test_alamofire_uuid"
        let localPodTests = IInternalTargetMock()
        localPodTests.underlyingUuid = "test_localPodTests_uuid"
        let targets = [
            alamofire.uuid: alamofire,
            localPodTests.uuid: localPodTests
        ]
        let resultTarget = IInternalTargetMock()
        xcodeProject.createAggregatedTargetNameDependenciesReturnValue = resultTarget

        // Act
        let target = try await sut.createTarget(
            dependencies: targets,
            buildConfiguration: "Debug",
            testplanPath: "path/to/testplan"
        )

        // Assert
        XCTAssertIdentical(resultTarget, target)
        XCTAssertEqual(xcodeProject.createAggregatedTargetNameDependenciesCallsCount, 1)
        let createAggregatedArguments = try XCTUnwrap(
            xcodeProject.createAggregatedTargetNameDependenciesReceivedArguments
        )
        XCTAssertEqual(createAggregatedArguments.name, "RugbyPods")
        XCTAssertEqual(createAggregatedArguments.dependencies.count, 2)
        XCTAssertTrue(createAggregatedArguments.dependencies.contains(alamofire.uuid))
        XCTAssertTrue(createAggregatedArguments.dependencies.contains(localPodTests.uuid))

        XCTAssertEqual(xcodeProject.createTestingSchemeBuildConfigurationTestplanPathCallsCount, 1)
        let createTestingArguments = try XCTUnwrap(
            xcodeProject.createTestingSchemeBuildConfigurationTestplanPathReceivedArguments
        )
        XCTAssertIdentical(createTestingArguments.target, target)
        XCTAssertEqual(createTestingArguments.buildConfiguration, "Debug")
        XCTAssertEqual(createTestingArguments.testplanPath, "path/to/testplan")
    }
}
