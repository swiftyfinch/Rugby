@testable import RugbyFoundation
import XCTest

final class GitTests: XCTestCase {
    private enum TestError: Error { case test }

    private var sut: IGit!
    private var shellExecutor: IShellExecutorMock!

    override func setUp() {
        super.setUp()
        shellExecutor = IShellExecutorMock()
        sut = Git(shellExecutor: shellExecutor)
    }

    override func tearDown() {
        super.tearDown()
        shellExecutor = nil
        sut = nil
    }
}

extension GitTests {
    func test_currentBranch_error() async throws {
        shellExecutor.throwingShellArgsThrowableError = TestError.test

        // Act
        var resultError: Error?
        do {
            _ = try sut.currentBranch()
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? TestError, .test)
        XCTAssertFalse(shellExecutor.throwingShellArgsCalled)
    }

    func test_currentBranch_gitError() throws {
        shellExecutor.throwingShellArgsReturnValue = nil

        // Act
        var resultError: Error?
        do {
            _ = try sut.currentBranch()
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? GitError, .nilOutput)
        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        XCTAssertEqual(shellExecutor.throwingShellArgsReceivedArguments?.command, "git branch --show-current")
        let args = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments?.args as? [Any])
        XCTAssertTrue(args.isEmpty)
    }

    func test_currentBranch() throws {
        shellExecutor.throwingShellArgsReturnValue = "fix-something"

        // Act
        let branch = try sut.currentBranch()

        // Assert
        XCTAssertEqual(branch, "fix-something")
        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        XCTAssertEqual(shellExecutor.throwingShellArgsReceivedArguments?.command, "git branch --show-current")
        let args = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments?.args as? [Any])
        XCTAssertTrue(args.isEmpty)
    }

    func test_hasUncommittedChanges_true() throws {
        shellExecutor.throwingShellArgsReturnValue = " M Sources/RugbyFoundation/Core/Env/SwiftVersionProvider.swift"

        // Act
        let hasUncommittedChanges = try sut.hasUncommittedChanges()

        // Assert
        XCTAssertTrue(hasUncommittedChanges)
        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        XCTAssertEqual(shellExecutor.throwingShellArgsReceivedArguments?.command, "git status --porcelain")
        let args = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments?.args as? [Any])
        XCTAssertTrue(args.isEmpty)
    }

    func test_hasUncommittedChanges_false() throws {
        shellExecutor.throwingShellArgsReturnValue = ""

        // Act
        let hasUncommittedChanges = try sut.hasUncommittedChanges()

        // Assert
        XCTAssertFalse(hasUncommittedChanges)
        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        XCTAssertEqual(shellExecutor.throwingShellArgsReceivedArguments?.command, "git status --porcelain")
        let args = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments?.args as? [Any])
        XCTAssertTrue(args.isEmpty)
    }

    func test_isBehind_true() throws {
        shellExecutor.throwingShellArgsReturnValue = "1286ae00c58981e7babd1b6d737df5d9f466d4e9"

        // Act
        let isBehind = try sut.isBehind(branch: "main")

        // Assert
        XCTAssertTrue(isBehind)
        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        XCTAssertEqual(shellExecutor.throwingShellArgsReceivedArguments?.command, "git rev-list main...")
        let args = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments?.args as? [Any])
        XCTAssertTrue(args.isEmpty)
    }

    func test_isBehind_false() throws {
        shellExecutor.throwingShellArgsReturnValue = ""

        // Act
        let isBehind = try sut.isBehind(branch: "main")

        // Assert
        XCTAssertFalse(isBehind)
        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        XCTAssertEqual(shellExecutor.throwingShellArgsReceivedArguments?.command, "git rev-list main...")
        let args = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments?.args as? [Any])
        XCTAssertTrue(args.isEmpty)
    }
}
