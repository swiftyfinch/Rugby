import Rainbow
@testable import RugbyFoundation
import XCTest

final class EnvironmentCollectorTests: XCTestCase {
    private var sut: IEnvironmentCollector!
    private var logger: ILoggerMock!
    private var workingDirectory: IFolderMock!
    private var shellExecutor: IShellExecutorMock!
    private var swiftVersionProvider: ISwiftVersionProviderMock!
    private var architectureProvider: IArchitectureProviderMock!
    private var xcodeCLTVersionProvider: IXcodeCLTVersionProviderMock!
    private var git: IGitMock!

    override func setUp() {
        super.setUp()
        logger = ILoggerMock()
        workingDirectory = IFolderMock()
        shellExecutor = IShellExecutorMock()
        swiftVersionProvider = ISwiftVersionProviderMock()
        architectureProvider = IArchitectureProviderMock()
        xcodeCLTVersionProvider = IXcodeCLTVersionProviderMock()
        git = IGitMock()
        sut = EnvironmentCollector(
            logger: logger,
            workingDirectory: workingDirectory,
            shellExecutor: shellExecutor,
            swiftVersionProvider: swiftVersionProvider,
            architectureProvider: architectureProvider,
            xcodeCLTVersionProvider: xcodeCLTVersionProvider,
            git: git
        )
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        workingDirectory = nil
        shellExecutor = nil
        swiftVersionProvider = nil
        architectureProvider = nil
        xcodeCLTVersionProvider = nil
        git = nil
        sut = nil
    }
}

extension EnvironmentCollectorTests {
    func test_env() async throws {
        xcodeCLTVersionProvider.versionReturnValue = ("Xcode 15.0", "Build version 15A240d")
        architectureProvider.architectureReturnValue = .arm64
        await swiftVersionProvider.setSwiftVersionReturnValue("5.9")
        shellExecutor.throwingShellArgsClosure = { command, _ in
            if command == "sysctl -n machdep.cpu.brand_string" {
                return "Apple M1 Max"
            } else if command == "git branch --show-current" {
                return "main"
            }
            return nil
        }
        let projectFolder = IFolderMock()
        projectFolder.underlyingPathExtension = "xcworkspace"
        projectFolder.underlyingNameExcludingExtension = "Example"
        workingDirectory.foldersDeepReturnValue = [projectFolder]
        let rugbyEnvironment = [
            "RUGBY_KEEP_HASH_YAMLS": "YES",
            "RUGBY_PRINT_MISSING_BINARIES": "NO"
        ]
        git.currentBranchReturnValue = "main"

        // Act
        let env = try await sut.env(
            rugbyVersion: "2.2.0",
            rugbyEnvironment: rugbyEnvironment
        )

        // Assert
        XCTAssertEqual(
            env,
            [
                "Rugby version: 2.2.0",
                "Swift: 5.9",
                "CLT: Xcode 15.0 (Build version 15A240d)",
                "CPU: Apple M1 Max (arm64)",
                "Project: Example",
                "Git branch: main",
                "RUGBY_KEEP_HASH_YAMLS: YES",
                "RUGBY_PRINT_MISSING_BINARIES: NO"
            ]
        )
    }

    func test_write() async throws {
        Rainbow.enabled = false
        xcodeCLTVersionProvider.versionReturnValue = ("Xcode 15.0", "Build version 15A240d")
        await swiftVersionProvider.setSwiftVersionReturnValue("5.9")
        architectureProvider.architectureReturnValue = .auto
        struct Build {
            let arch: String
            let config: String
        }
        let command = Build(arch: "x86_64", config: "Release")
        workingDirectory.foldersDeepReturnValue = []
        let rugbyEnvironment = [
            "RUGBY_KEEP_HASH_YAMLS": "NO",
            "RUGBY_PRINT_MISSING_BINARIES": "YES"
        ]

        // Act
        try await sut.write(
            rugbyVersion: "2.0",
            command: command,
            rugbyEnvironment: rugbyEnvironment
        )

        // Assert
        let invocations = logger.logLevelOutputReceivedInvocations
        XCTAssertEqual(invocations.count, 9)
        XCTAssertEqual(
            invocations.map(\.text),
            [
                "Rugby version: 2.0",
                "Swift: 5.9",
                "CLT: Xcode 15.0 (Build version 15A240d)",
                "CPU: Unknown (auto)",
                "Project: Unknown",
                "Git branch: Unknown",
                "RUGBY_KEEP_HASH_YAMLS: NO",
                "RUGBY_PRINT_MISSING_BINARIES: YES",
                "Command dump: Build(arch: \"x86_64\", config: \"Release\")"
            ]
        )
        XCTAssertEqual(invocations.map(\.level), Array(repeating: .compact, count: 9))
        XCTAssertEqual(invocations.map(\.output), Array(repeating: .file, count: 9))
    }

    func test_logXcodeVersion() async throws {
        Rainbow.enabled = true
        xcodeCLTVersionProvider.versionReturnValue = ("Xcode 15.0", "Build version 15A240d")

        // Act
        try await sut.logXcodeVersion()

        // Assert
        XCTAssertEqual(logger.logLevelOutputCallsCount, 1)
        let args = try XCTUnwrap(logger.logLevelOutputReceivedArguments)
        XCTAssertEqual(args.text, "CLT: Xcode 15.0".green)
        XCTAssertEqual(args.level, .compact)
        XCTAssertEqual(args.output, .all)
    }

    func test_logCommandDump() async throws {
        Rainbow.enabled = true
        struct Build {
            let arch: String
        }
        let command = Build(arch: "x86_64")

        // Act
        await sut.logCommandDump(command: command)

        // Assert
        XCTAssertEqual(logger.logLevelOutputCallsCount, 1)
        let args = try XCTUnwrap(logger.logLevelOutputReceivedArguments)
        XCTAssertEqual(args.text, "Command dump: Build(arch: \"x86_64\")".green)
        XCTAssertEqual(args.level, .compact)
        XCTAssertEqual(args.output, .file)
    }
}
