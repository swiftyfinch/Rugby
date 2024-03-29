import Fish
@testable import RugbyFoundation
import XCTest

// swiftlint:disable line_length

final class BuildPhaseHasherTests: XCTestCase {
    private var logger: ILoggerMock!
    private let workingDirectoryPath = "/Users/swiftyfinch/Developer/Example"
    private var fileContentHasher: IFileContentHasherMock!
    private var envVariablesResolver: IEnvVariablesResolverMock!
    private var fishSharedStorage: IFilesManagerMock!
    private var sut: IBuildPhaseHasher!

    override func setUp() {
        super.setUp()
        logger = ILoggerMock()
        fileContentHasher = IFileContentHasherMock()
        envVariablesResolver = IEnvVariablesResolverMock()
        sut = BuildPhaseHasher(
            logger: logger,
            workingDirectoryPath: workingDirectoryPath,
            fileContentHasher: fileContentHasher,
            envVariablesResolver: envVariablesResolver
        )

        fishSharedStorage = IFilesManagerMock()
        let backupFishSharedStorage = Fish.sharedStorage
        Fish.sharedStorage = fishSharedStorage
        addTeardownBlock {
            Fish.sharedStorage = backupFishSharedStorage
        }
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        fileContentHasher = nil
        envVariablesResolver = nil
        fishSharedStorage = nil
        sut = nil
    }
}

extension BuildPhaseHasherTests {
    func test_xcframeworks() async throws {
        let inputFilesList = "${PODS_ROOT}/Target Support Files/Realm-framework/Realm-framework-xcframeworks-input-files.xcfilelist"
        let inputFile0 = "${PODS_ROOT}/Target Support Files/Realm-framework/Realm-framework-xcframeworks.sh"
        let inputFile1 = "${PODS_ROOT}/Realm/core/realm-monorepo.xcframework"
        let resolvedFilesList = "/Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Target Support Files/Realm-framework/Realm-framework-xcframeworks-input-files.xcfilelist"
        let resolvedInputFile0 = "/Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Realm/core/realm-monorepo.xcframework"
        let resolvedInputFile1 = "/Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Target Support Files/Realm-framework/Realm-framework-xcframeworks.sh"
        envVariablesResolver.resolveXcodeVariablesInAdditionalEnvClosure = { path, _ in
            switch path {
            case inputFilesList: return resolvedFilesList
            case inputFile0: return resolvedInputFile0
            case inputFile1: return resolvedInputFile1
            default: fatalError()
            }
        }
        fishSharedStorage.readFileClosure = { url in
            if url.path == resolvedFilesList { return inputFile0 + "\n" + inputFile1 }
            fatalError()
        }
        fishSharedStorage.isItemExistAtClosure = { path in
            path == resolvedInputFile1
        }
        fileContentHasher.hashContextPathsClosure = { paths in
            switch paths {
            case [resolvedInputFile1]:
                return ["Pods/Target Support Files/Realm-framework/Realm-framework-xcframeworks.sh: 8a32c0c"]
            case []: return []
            default: fatalError()
            }
        }
        let target = IInternalTargetMock()
        target.configurations = [
            "Debug": Configuration(name: "Debug", buildSettings: [:])
        ]
        target.buildPhases = [
            BuildPhase(
                name: "[CP] Copy XCFrameworks",
                type: .runScript,
                inputFileListPaths: [
                    "${PODS_ROOT}/Target Support Files/Realm-framework/Realm-framework-xcframeworks-input-files.xcfilelist"
                ],
                outputFileListPaths: [
                    "${PODS_ROOT}/Target Support Files/Realm-framework/Realm-framework-xcframeworks-output-files.xcfilelist"
                ]
            )
        ]

        // Act
        let anyHashContext = try await sut.hashContext(target: target)

        // Assert
        let hashContext = try XCTUnwrap((anyHashContext as? [[String: Any]])?.first)
        XCTAssertEqual(hashContext["name"] as? String, "[CP] Copy XCFrameworks")
        XCTAssertEqual(hashContext["type"] as? String, "runScript")
        XCTAssertEqual(
            hashContext["inputFileListPaths"] as? [String],
            ["Pods/Target Support Files/Realm-framework/Realm-framework-xcframeworks.sh: 8a32c0c"]
        )
        XCTAssertEqual(
            hashContext["inputFileListPaths_missing"] as? [String],
            ["/Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Realm/core/realm-monorepo.xcframework"]
        )
        XCTAssertEqual(
            hashContext["outputFileListPaths"] as? [String],
            ["${PODS_ROOT}/Target Support Files/Realm-framework/Realm-framework-xcframeworks-output-files.xcfilelist"]
        )
    }
}

// swiftlint:enable line_length
