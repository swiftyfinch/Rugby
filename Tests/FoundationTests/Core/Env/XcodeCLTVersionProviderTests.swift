@testable import RugbyFoundation
import XCTest

final class XcodeCLTVersionProviderTests: XCTestCase {
    private enum TestError: Error { case test }

    private var shellExecutorMock: IShellExecutorMock!
    private var sut: XcodeCLTVersionProvider!

    override func setUp() {
        super.setUp()
        shellExecutorMock = IShellExecutorMock()
        sut = XcodeCLTVersionProvider(shellExecutor: shellExecutorMock)
    }

    override func tearDown() {
        super.tearDown()
        shellExecutorMock = nil
        sut = nil
    }
}

// MARK: - Success Result

extension XcodeCLTVersionProviderTests {
    func test_version_Xcode14_1() throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        Xcode 14.1
        Build version 14B47b
        """

        // Act
        let versionInfo = try sut.version()

        // Assert
        XCTAssertEqual(versionInfo.base, "Xcode 14.1")
        XCTAssertEqual(versionInfo.build, "Build version 14B47b")
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_version_Xcode_14_1_3() throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        Xcode 14.1.3
        Build version 04BD7b
        """

        // Act
        let versionInfo = try sut.version()

        // Assert
        XCTAssertEqual(versionInfo.base, "Xcode 14.1.3")
        XCTAssertEqual(versionInfo.build, "Build version 04BD7b")
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_version_Xcode_14_1_baseOnly() throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        Xcode 14.1.3
        """

        // Act
        let versionInfo = try sut.version()

        // Assert
        XCTAssertEqual(versionInfo.base, "Xcode 14.1.3")
        XCTAssertNil(versionInfo.build)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_version_Xcode_14_1_3_baseOnlyMultiline() throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        Xcode 14.1.3
        Build
        version
        04BD7b
        """

        // Act
        let versionInfo = try sut.version()

        // Assert
        XCTAssertEqual(versionInfo.base, "Xcode 14.1.3 - Build - version - 04BD7b")
        XCTAssertNil(versionInfo.build)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }
}

// MARK: - Cache

extension XcodeCLTVersionProviderTests {
    func test_swiftVersion_cache() async throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        Xcode 14.2
        Build version 11BT7b
        """

        // Act
        let versionInfo = try sut.version()
        let versionInfoCache = try sut.version()

        // Assert
        XCTAssertEqual(versionInfo.base, "Xcode 14.2")
        XCTAssertEqual(versionInfo.build, "Build version 11BT7b")
        XCTAssertEqual(versionInfoCache.base, "Xcode 14.2")
        XCTAssertEqual(versionInfoCache.build, "Build version 11BT7b")
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }
}

// MARK: - Errors

extension XcodeCLTVersionProviderTests {
    func test_swiftVersion_parsingError() async throws {
        shellExecutorMock.throwingShellArgsReturnValue = nil

        // Act
        var resultError: Error?
        do {
            _ = try sut.version()
        } catch {
            resultError = error
        }

        // Assert
        let unwrappedError = try XCTUnwrap(resultError as? XcodeCLTVersionProviderError)
        XCTAssertEqual(unwrappedError, .unknownXcodeCLT)
        XCTAssertEqual(
            unwrappedError.errorDescription,
            """
            \("Couldn't find Xcode CLT.".red)
            \("🚑 Check Xcode Preferences → Locations → Command Line Tools.".yellow)
            """
        )
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_swiftVersion_shellError() async throws {
        shellExecutorMock.throwingShellArgsThrowableError = TestError.test

        // Act
        var resultError: Error?
        do {
            _ = try sut.version()
        } catch {
            resultError = error
        }

        // Assert
        let unwrappedError = try XCTUnwrap(resultError as? XcodeCLTVersionProviderError)
        XCTAssertEqual(unwrappedError, .unknownXcodeCLT)
        XCTAssertTrue(shellExecutorMock.throwingShellArgsCalled)
    }
}
