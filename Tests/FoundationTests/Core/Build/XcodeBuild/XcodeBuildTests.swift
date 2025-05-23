import Fish
@testable import RugbyFoundation
import XCTest

final class XcodeBuildTests: XCTestCase {
    private var sut: XcodeBuild!
    private var xcodeBuildExecutor: IXcodeBuildExecutorMock!
    private var fishSharedStorage: IFilesManagerMock!

    override func setUp() {
        super.setUp()
        fishSharedStorage = IFilesManagerMock()
        let backupFishSharedStorage = Fish.sharedStorage
        Fish.sharedStorage = fishSharedStorage
        addTeardownBlock {
            Fish.sharedStorage = backupFishSharedStorage
        }

        xcodeBuildExecutor = IXcodeBuildExecutorMock()
        sut = XcodeBuild(xcodeBuildExecutor: xcodeBuildExecutor)
    }

    override func tearDown() {
        super.tearDown()
        fishSharedStorage = nil
        xcodeBuildExecutor = nil
        sut = nil
    }
}

extension XcodeBuildTests {
    func test_build_general() async throws {
        fishSharedStorage.createFolderAtReturnValue = IFolderMock()

        // Act
        try await sut.build(
            target: "Rugby",
            options: XcodeBuildOptions(
                sdk: .ios,
                config: "Debug",
                arch: "x86_64",
                xcargs: XCARGSProvider().xcargs(strip: true),
                resultBundlePath: "build.xcresult"
            ),
            paths: XcodeBuildPaths(
                project: "/Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Pods.xcodeproj",
                symroot: "/Users/swiftyfinch/Developer/Repos/Rugby/Example/.rugby/build",
                rawLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/rawBuild.log",
                beautifiedLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/build.log"
            )
        )

        // Assert
        XCTAssertEqual(fishSharedStorage.createFolderAtCallsCount, 1)
        XCTAssertEqual(
            fishSharedStorage.createFolderAtReceivedPath,
            "/Users/swiftyfinch/Developer/Repos/Rugby/Example/.rugby/build"
        )
        XCTAssertEqual(xcodeBuildExecutor.runRawLogPathLogPathArgsCallsCount, 1)
        let arguments = try XCTUnwrap(xcodeBuildExecutor.runRawLogPathLogPathArgsReceivedArguments)
        XCTAssertEqual(arguments.command, "NSUnbufferedIO=YES xcodebuild")
        XCTAssertEqual(arguments.rawLogPath, "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/rawBuild.log")
        XCTAssertEqual(arguments.logPath, "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/build.log")
        XCTAssertEqual(
            arguments.args as? [[String]],
            [[
                "-target Rugby",
                "-sdk iphoneos",
                "-config Debug",
                "ARCHS=x86_64",
                "-parallelizeTargets",
                "-project /Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Pods.xcodeproj",
                "SYMROOT=/Users/swiftyfinch/Developer/Repos/Rugby/Example/.rugby/build",
                "-resultBundlePath build.xcresult",
                "COMPILER_INDEX_STORE_ENABLE=NO",
                "GCC_GENERATE_DEBUGGING_SYMBOLS=NO",
                "STRIP_INSTALLED_PRODUCT=YES",
                "COPY_PHASE_STRIP=YES",
                "STRIP_STYLE=all"
            ]]
        )
    }

    func test_build_spaceInPaths() async throws {
        fishSharedStorage.createFolderAtReturnValue = IFolderMock()

        // Act
        try await sut.build(
            target: "RugbyPods",
            options: XcodeBuildOptions(
                sdk: .sim,
                config: "QA Release",
                arch: "arm64",
                xcargs: XCARGSProvider().xcargs(strip: false),
                resultBundlePath: nil
            ),
            paths: XcodeBuildPaths(
                project: "/Users/swiftyfinch/Developer/Repos/Rugby/Exa mple/Pods/Pods.xcodeproj",
                symroot: "/Users/swiftyfinch/Developer/Repos/Rugby/Exa mple/.rugby/build",
                rawLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/rawBuild.log",
                beautifiedLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/build.log"
            )
        )

        // Assert
        XCTAssertEqual(fishSharedStorage.createFolderAtCallsCount, 1)
        XCTAssertEqual(
            fishSharedStorage.createFolderAtReceivedPath,
            "/Users/swiftyfinch/Developer/Repos/Rugby/Exa mple/.rugby/build"
        )
        XCTAssertEqual(xcodeBuildExecutor.runRawLogPathLogPathArgsCallsCount, 1)
        let arguments = try XCTUnwrap(xcodeBuildExecutor.runRawLogPathLogPathArgsReceivedArguments)
        XCTAssertEqual(arguments.command, "NSUnbufferedIO=YES xcodebuild")
        XCTAssertEqual(arguments.rawLogPath, "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/rawBuild.log")
        XCTAssertEqual(arguments.logPath, "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/build.log")
        XCTAssertEqual(
            arguments.args as? [[String]],
            [[
                "-target RugbyPods",
                "-sdk iphonesimulator",
                "-config QA\\ Release",
                "ARCHS=arm64",
                "-parallelizeTargets",
                "-project /Users/swiftyfinch/Developer/Repos/Rugby/Exa\\ mple/Pods/Pods.xcodeproj",
                "SYMROOT=/Users/swiftyfinch/Developer/Repos/Rugby/Exa\\ mple/.rugby/build",
                "COMPILER_INDEX_STORE_ENABLE=NO"
            ]]
        )
    }

    func test_test() async throws {
        fishSharedStorage.createFolderAtReturnValue = IFolderMock()

        // Act
        try await sut.test(
            scheme: "RugbyPods",
            testPlan: "Rugby",
            simulatorName: "iPhone 15",
            options: XcodeBuildOptions(
                sdk: .ios,
                config: "Debug",
                arch: "x86_64",
                xcargs: XCARGSProvider().xcargs(strip: true),
                resultBundlePath: "build.xcresult"
            ),
            paths: XcodeBuildPaths(
                project: "/Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Pods.xcodeproj",
                symroot: "/Users/swiftyfinch/Developer/Repos/Rugby/Example/.rugby/build",
                rawLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/test/rawBuild.log",
                beautifiedLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/test/build.log"
            )
        )

        // Assert
        XCTAssertEqual(fishSharedStorage.createFolderAtCallsCount, 1)
        XCTAssertEqual(
            fishSharedStorage.createFolderAtReceivedPath,
            "/Users/swiftyfinch/Developer/Repos/Rugby/Example/.rugby/build"
        )
        XCTAssertEqual(xcodeBuildExecutor.runRawLogPathLogPathArgsCallsCount, 1)
        let arguments = try XCTUnwrap(xcodeBuildExecutor.runRawLogPathLogPathArgsReceivedArguments)
        XCTAssertEqual(arguments.command, "NSUnbufferedIO=YES xcodebuild")
        XCTAssertEqual(arguments.rawLogPath, "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/test/rawBuild.log")
        XCTAssertEqual(arguments.logPath, "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/test/build.log")
        XCTAssertEqual(
            arguments.args as? [[String]],
            [[
                "-scheme RugbyPods",
                "-testPlan Rugby",
                "-destination \'platform=iOS Simulator,name=iPhone 15\'",
                "test",
                "-project /Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Pods.xcodeproj",
                "SYMROOT=/Users/swiftyfinch/Developer/Repos/Rugby/Example/.rugby/build",
                "-resultBundlePath build.xcresult",
                "COMPILER_INDEX_STORE_ENABLE=NO",
                "GCC_GENERATE_DEBUGGING_SYMBOLS=NO",
                "STRIP_INSTALLED_PRODUCT=YES",
                "COPY_PHASE_STRIP=YES",
                "STRIP_STYLE=all"
            ]]
        )
    }
}
