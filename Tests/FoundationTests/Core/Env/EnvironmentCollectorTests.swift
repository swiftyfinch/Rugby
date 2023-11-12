@testable import RugbyFoundation
import XCTest

final class EnvironmentCollectorTests: XCTestCase {
    private var sut: IEnvironmentCollector!
    private var logger: ILoggerMock!
    private var shellExecutor: IShellExecutorMock!
    private var swiftVersionProvider: ISwiftVersionProviderMock!
    private var architectureProvider: IArchitectureProviderMock!
    private var xcodeCLTVersionProvider: IXcodeCLTVersionProviderMock!

    override func setUp() {
        super.setUp()
        logger = ILoggerMock()
        shellExecutor = IShellExecutorMock()
        swiftVersionProvider = ISwiftVersionProviderMock()
        architectureProvider = IArchitectureProviderMock()
        xcodeCLTVersionProvider = IXcodeCLTVersionProviderMock()
        sut = EnvironmentCollector(
            logger: logger,
            shellExecutor: shellExecutor,
            swiftVersionProvider: swiftVersionProvider,
            architectureProvider: architectureProvider,
            xcodeCLTVersionProvider: xcodeCLTVersionProvider
        )
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        shellExecutor = nil
        swiftVersionProvider = nil
        architectureProvider = nil
        xcodeCLTVersionProvider = nil
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
        let workingDirectory = IFolderMock()
        let projectFolder = IFolderMock()
        projectFolder.underlyingPathExtension = "xcworkspace"
        projectFolder.underlyingNameExcludingExtension = "Example"
        workingDirectory.foldersDeepReturnValue = [projectFolder]
        let rugbyEnvironment = [
            "RUGBY_KEEP_HASH_YAMLS": "YES",
            "RUGBY_PRINT_MISSING_BINARIES": "NO"
        ]

        // Act
        let env = try await sut.env(
            rugbyVersion: "2.2.0",
            workingDirectory: workingDirectory,
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
}
