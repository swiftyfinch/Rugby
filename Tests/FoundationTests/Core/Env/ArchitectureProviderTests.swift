@testable import RugbyFoundation
import XCTest

final class ArchitectureProviderTests: XCTestCase {
    private enum TestError: Error { case test }

    private var shellExecutorMock: IShellExecutorMock!
    private var sut: ArchitectureProvider!

    override func setUp() {
        super.setUp()
        shellExecutorMock = IShellExecutorMock()
        sut = ArchitectureProvider(shellExecutor: shellExecutorMock)
    }

    override func tearDown() {
        super.tearDown()
        shellExecutorMock = nil
        sut = nil
    }
}

// MARK: - Tests

extension ArchitectureProviderTests {
    func test_architecture_appleM1Pro() {
        shellExecutorMock.throwingShellArgsReturnValue = "Apple M1 Pro"

        // Act
        let architecture = sut.architecture()

        // Assert
        XCTAssertEqual(architecture, .arm64)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_architecture_appleM1() {
        shellExecutorMock.throwingShellArgsReturnValue = "Apple M1"

        // Act
        let architecture = sut.architecture()

        // Assert
        XCTAssertEqual(architecture, .arm64)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_architecture_appleProcessor() {
        shellExecutorMock.throwingShellArgsReturnValue = "Apple processor"

        // Act
        let architecture = sut.architecture()

        // Assert
        XCTAssertEqual(architecture, .arm64)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_architecture_intelI7() {
        shellExecutorMock.throwingShellArgsReturnValue = "Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz"

        // Act
        let architecture = sut.architecture()

        // Assert
        XCTAssertEqual(architecture, .x86_64)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_architecture_intelXeon() {
        shellExecutorMock.throwingShellArgsReturnValue = "Intel(R) Xeon(R) CPU X5550 @ 2.67GHz"

        // Act
        let architecture = sut.architecture()

        // Assert
        XCTAssertEqual(architecture, .x86_64)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }

    func test_architecture_unknown() {
        shellExecutorMock.throwingShellArgsReturnValue = "unknown"

        // Act
        let architecture = sut.architecture()

        // Assert
        XCTAssertEqual(architecture, .x86_64)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }
}

// MARK: - Cache

extension ArchitectureProviderTests {
    func test_architecture_cache() {
        shellExecutorMock.throwingShellArgsReturnValue = "Apple M1 Max"

        // Act
        let architecture = sut.architecture()
        let architectureCache = sut.architecture()

        // Assert
        XCTAssertEqual(architecture, .arm64)
        XCTAssertEqual(architectureCache, .arm64)
        XCTAssertEqual(shellExecutorMock.throwingShellArgsCallsCount, 1)
    }
}
