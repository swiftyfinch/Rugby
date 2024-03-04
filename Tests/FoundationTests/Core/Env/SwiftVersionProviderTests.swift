@testable import RugbyFoundation
import XCTest

final class SwiftVersionProviderTests: XCTestCase {
    private enum TestError: Error { case test }

    private var shellExecutorMock: IShellExecutorMock!
    private var sut: SwiftVersionProvider!

    override func setUp() {
        super.setUp()
        shellExecutorMock = IShellExecutorMock()
        sut = SwiftVersionProvider(shellExecutor: shellExecutorMock)
    }

    override func tearDown() {
        super.tearDown()
        shellExecutorMock = nil
        sut = nil
    }
}

// MARK: - Success Result

extension SwiftVersionProviderTests {
    func test_swiftVersion_5d7d1() async throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        swift-driver version: 1.62.15 Apple Swift version 5.7.1 (swiftlang-5.7.1.135.3 clang-1400.0.29.51)
        Target: arm64-apple-macosx13.0
        """

        // Act
        let swiftVersion = try await sut.swiftVersion()

        // Assert
        XCTAssertEqual(swiftVersion, "5.7.1")
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_swiftVersion_5d7d2() async throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        swift-driver version: 1.62.15 Apple Swift version 5.7.2 (swiftlang-5.7.2.135.5 clang-1400.0.29.51)
        Target: arm64-apple-macosx13.0
        """

        // Act
        let swiftVersion = try await sut.swiftVersion()

        // Assert
        XCTAssertEqual(swiftVersion, "5.7.2")
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_swiftVersion_5d6d1() async throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        swift-driver version: 1.45.2 Apple Swift version 5.6.1 (swiftlang-5.6.0.323.66 clang-1316.0.20.12)
        Target: x86_64-apple-macosx12.0
        """

        // Act
        let swiftVersion = try await sut.swiftVersion()

        // Assert
        XCTAssertEqual(swiftVersion, "5.6.1")
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_swiftVersion_5d5d2() async throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        swift-driver version: 1.26.21 Apple Swift version 5.5.2 (swiftlang-1300.0.47.5 clang-1300.0.29.30)
        Target: x86_64-apple-macosx12.0
        """

        // Act
        let swiftVersion = try await sut.swiftVersion()

        // Assert
        XCTAssertEqual(swiftVersion, "5.5.2")
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_swiftVersion_5d5() async throws {
        shellExecutorMock.throwingShellArgsReturnValue = """
        swift-driver version: 1.26.21 Apple Swift version 5.5 (swiftlang-1300.0.47.5 clang-1300.0.29.30)
        Target: x86_64-apple-macosx12.0
        """

        // Act
        let swiftVersion = try await sut.swiftVersion()

        // Assert
        XCTAssertEqual(swiftVersion, "5.5")
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }
}

// MARK: - Cache

extension SwiftVersionProviderTests {
    func test_swiftVersion_cache() async throws {
        shellExecutorMock.throwingShellArgsReturnValue = "Apple Swift version 5.5"

        // Act
        let swiftVersion = try await sut.swiftVersion()
        let swiftVersionCache = try await sut.swiftVersion()

        // Assert
        XCTAssertEqual(swiftVersion, "5.5")
        XCTAssertEqual(swiftVersionCache, swiftVersion)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }
}

// MARK: - Errors

extension SwiftVersionProviderTests {
    func test_swiftVersion_parsingError() async throws {
        shellExecutorMock.throwingShellArgsReturnValue = "random text"

        // Act
        var resultError: Error?
        do {
            _ = try await sut.swiftVersion()
        } catch {
            resultError = error
        }

        // Assert
        let unwrappedError = try XCTUnwrap(resultError as? SwiftVersionProviderError)
        XCTAssertEqual(unwrappedError, .parsingFailed)
        XCTAssertEqual(unwrappedError.errorDescription, "Couldn't parse Swift version.")
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_swiftVersion_shellError() async throws {
        shellExecutorMock.throwingShellArgsThrowableError = TestError.test

        // Act
        var resultError: Error?
        do {
            _ = try await sut.swiftVersion()
        } catch {
            resultError = error
        }

        // Assert
        let unwrappedError = try XCTUnwrap(resultError as? TestError)
        XCTAssertEqual(unwrappedError, .test)
        XCTAssertTrue(shellExecutorMock.throwingShellArgsCalled)
    }
}
