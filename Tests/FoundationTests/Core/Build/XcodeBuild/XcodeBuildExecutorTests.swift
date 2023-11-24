import Fish
@testable import RugbyFoundation
import XCTest

// swiftlint:disable identifier_name

final class XcodeBuildExecutorTests: XCTestCase {
    private var sut: XcodeBuildExecutor!
    private var shellExecutor: IShellExecutorMock!
    private var buildLogFormatter: IBuildLogFormatterMock!
    private var fishSharedStorage: IFilesManagerMock!

    override func setUp() async throws {
        try await super.setUp()

        fishSharedStorage = IFilesManagerMock()
        let backupFishSharedStorage = Fish.sharedStorage
        Fish.sharedStorage = fishSharedStorage
        addTeardownBlock {
            Fish.sharedStorage = backupFishSharedStorage
        }

        shellExecutor = IShellExecutorMock()
        buildLogFormatter = IBuildLogFormatterMock()
        sut = XcodeBuildExecutor(
            shellExecutor: shellExecutor,
            logFormatter: buildLogFormatter
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        shellExecutor = nil
        buildLogFormatter = nil
        fishSharedStorage = nil
    }
}

extension XcodeBuildExecutorTests {
    func test_taskInLog() throws {
        let createFileMock = IFileMock()
        fishSharedStorage.createFileAtContentsReturnValue = createFileMock
        let createFolderMock = IFolderMock()
        fishSharedStorage.createFolderAtReturnValue = createFolderMock
        let rugbyDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".rugby")
        let test_rawLogPath = rugbyDirectory.appendingPathComponent("test_rawLogPath").path
        let test_logPath = rugbyDirectory.appendingPathComponent("test_logPath").path

        var isRead = false
        let expectedContent = "Touching SnapKit.framework"
        let readableStream = ReadableStreamMock()
        readableStream.readSomeClosure = {
            guard !isRead else { return nil }
            isRead = true
            return expectedContent
        }
        shellExecutor.openReturnValue = readableStream

        var resultLines: [String] = []
        buildLogFormatter.formatLineOutputClosure = { line, output in
            resultLines.append(line)
            try output(line, .task)
        }

        // Act
        try sut.run(
            "test_command",
            rawLogPath: test_rawLogPath,
            logPath: test_logPath,
            args: "arg0", "arg1"
        )

        // Assert
        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        let (command, args) = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments)
        XCTAssertEqual(command, "test_command")
        XCTAssertEqual("\(args)", #"[["arg0", "arg1"], "| tee \'\#(test_rawLogPath)\'"]"#)

        let (path, text) = try XCTUnwrap(fishSharedStorage.createFileAtContentsReceivedArguments)
        XCTAssertEqual(path, test_logPath)
        XCTAssertNil(text)
        XCTAssertEqual(fishSharedStorage.createFileAtContentsCallsCount, 1)

        XCTAssertEqual(shellExecutor.openCallsCount, 1)
        XCTAssertTrue(isRead)

        XCTAssertEqual(buildLogFormatter.formatLineOutputCallsCount, 1)
        XCTAssertEqual(buildLogFormatter.formatLineOutputReceivedArguments?.line, expectedContent)
        XCTAssertEqual(resultLines, [expectedContent])
        XCTAssertEqual(buildLogFormatter.finishOutputCallsCount, 1)

        XCTAssertEqual(createFileMock.appendCallsCount, 1)
        XCTAssertEqual(createFileMock.appendReceivedInvocations, [expectedContent + "\n"])
    }

    func test_errorsInLog() throws {
        let createFileMock = IFileMock()
        fishSharedStorage.createFileAtContentsReturnValue = createFileMock
        let createFolderMock = IFolderMock()
        fishSharedStorage.createFolderAtReturnValue = createFolderMock
        let rugbyDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".rugby")
        let test_rawLogPath = rugbyDirectory.appendingPathComponent("test_rawLogPath").path
        let test_logPath = rugbyDirectory.appendingPathComponent("test_logPath").path

        var readIndex = 0
        let expectedContent = [
            "error: Expressions are not allowed at the top level.",
            "error: No exact matches in call to initializer."
        ]
        let readableStream = ReadableStreamMock()
        readableStream.readSomeClosure = {
            guard readIndex < expectedContent.count else { return nil }
            let read = expectedContent[readIndex] + "\n"
            readIndex += 1
            return read
        }
        shellExecutor.openReturnValue = readableStream

        var resultLines: [String] = []
        buildLogFormatter.formatLineOutputClosure = { line, output in
            resultLines.append(line)
            try output(line, .error)
        }

        // Act
        var resultError: Error?
        try XCTAssertThrowsError(
            sut.run(
                "test_command",
                rawLogPath: test_rawLogPath,
                logPath: test_logPath,
                args: "arg0", "arg1"
            )
        ) { resultError = $0 }

        // Assert
        XCTAssertEqual(
            resultError as? BuildError,
            .buildFailed(
                errors: [
                    "error: Expressions are not allowed at the top level.",
                    "error: No exact matches in call to initializer."
                ],
                buildLogPath: test_logPath,
                rawBuildLogPath: test_rawLogPath
            )
        )

        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        let (command, args) = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments)
        XCTAssertEqual(command, "test_command")
        XCTAssertEqual("\(args)", #"[["arg0", "arg1"], "| tee \'\#(test_rawLogPath)\'"]"#)

        let (path, text) = try XCTUnwrap(fishSharedStorage.createFileAtContentsReceivedArguments)
        XCTAssertEqual(path, test_logPath)
        XCTAssertNil(text)
        XCTAssertEqual(fishSharedStorage.createFileAtContentsCallsCount, 1)

        XCTAssertEqual(shellExecutor.openCallsCount, 1)
        XCTAssertEqual(readIndex, expectedContent.count)

        XCTAssertEqual(buildLogFormatter.formatLineOutputCallsCount, 2)
        XCTAssertEqual(buildLogFormatter.formatLineOutputReceivedInvocations.map(\.line), expectedContent)
        XCTAssertEqual(resultLines, expectedContent)
        XCTAssertEqual(buildLogFormatter.finishOutputCallsCount, 1)

        XCTAssertEqual(fishSharedStorage.createFolderAtCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.createFolderAtReceivedPath, rugbyDirectory.path)
        XCTAssertEqual(createFileMock.appendCallsCount, 2)
        XCTAssertEqual(createFileMock.appendReceivedInvocations, expectedContent.map { "\($0)\n" })
    }
}

// swiftlint:enable identifier_name
