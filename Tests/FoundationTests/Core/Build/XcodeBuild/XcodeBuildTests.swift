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
    func test_general() throws {
        fishSharedStorage.createFolderAtReturnValue = IFolderMock()
        try sut.build(
            target: "Rugby",
            options: XcodeBuildOptions(
                sdk: .ios,
                config: "Debug",
                arch: "x86_64",
                xcargs: XCARGSProvider().xcargs(strip: true)
            ),
            paths: XcodeBuildPaths(
                project: "/Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Pods.xcodeproj",
                symroot: "/Users/swiftyfinch/Developer/Repos/Rugby/Example/.rugby/build",
                rawLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/rawBuild.log",
                beautifiedLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/build.log"
            )
        )

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
                "-project /Users/swiftyfinch/Developer/Repos/Rugby/Example/Pods/Pods.xcodeproj",
                "-target Rugby",
                "-sdk iphoneos",
                "-config Debug",
                "ARCHS=x86_64",
                "SYMROOT=/Users/swiftyfinch/Developer/Repos/Rugby/Example/.rugby/build",
                "-parallelizeTargets",
                "COMPILER_INDEX_STORE_ENABLE=NO",
                "SWIFT_COMPILATION_MODE=wholemodule",
                "GCC_GENERATE_DEBUGGING_SYMBOLS=NO",
                "STRIP_INSTALLED_PRODUCT=YES",
                "COPY_PHASE_STRIP=YES",
                "STRIP_STYLE=all"
            ]]
        )
    }

    func test_spaceInPaths() throws {
        fishSharedStorage.createFolderAtReturnValue = IFolderMock()
        try sut.build(
            target: "RugbyPods",
            options: XcodeBuildOptions(
                sdk: .sim,
                config: "QA Release",
                arch: "arm64",
                xcargs: XCARGSProvider().xcargs(strip: false)
            ),
            paths: XcodeBuildPaths(
                project: "/Users/swiftyfinch/Developer/Repos/Rugby/Exa mple/Pods/Pods.xcodeproj",
                symroot: "/Users/swiftyfinch/Developer/Repos/Rugby/Exa mple/.rugby/build",
                rawLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/rawBuild.log",
                beautifiedLog: "/Users/swiftyfinch/.rugby/logs/26.10.2023T17.12.09/build.log"
            )
        )

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
                "-project /Users/swiftyfinch/Developer/Repos/Rugby/Exa\\ mple/Pods/Pods.xcodeproj",
                "-target RugbyPods",
                "-sdk iphonesimulator",
                "-config QA\\ Release",
                "ARCHS=arm64",
                "SYMROOT=/Users/swiftyfinch/Developer/Repos/Rugby/Exa\\ mple/.rugby/build",
                "-parallelizeTargets",
                "COMPILER_INDEX_STORE_ENABLE=NO",
                "SWIFT_COMPILATION_MODE=wholemodule"
            ]]
        )
    }
}
