import Fish
@testable import RugbyFoundation
import XCTest

// swiftlint:disable identifier_name

final class XcodeBuildExecutorTests: XCTestCase {
    private var sut: XcodeBuildExecutor!
    private var logger: ILoggerMock!
    private var loggerBlockInvocations: [
        (header: String, footer: String?, metricKey: String?, level: LogLevel, output: LoggerOutput)
    ]!
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

        logger = ILoggerMock()
        loggerBlockInvocations = []
        logger.logFooterMetricKeyLevelOutputBlockClosure = { header, footer, metricKey, level, output, block in
            self.loggerBlockInvocations.append((header, footer, metricKey, level, output))
            return try await block()
        }
        shellExecutor = IShellExecutorMock()
        buildLogFormatter = IBuildLogFormatterMock()
        sut = XcodeBuildExecutor(
            logger: logger,
            shellExecutor: shellExecutor,
            logFormatter: buildLogFormatter
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        logger = nil
        loggerBlockInvocations = nil
        shellExecutor = nil
        buildLogFormatter = nil
        fishSharedStorage = nil
    }
}

extension XcodeBuildExecutorTests {
    func test_taskInLog() async throws {
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
        try await sut.run(
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

        XCTAssertEqual(loggerBlockInvocations.count, 1)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Beautifying Log".green)
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
    }

    func test_errorsInLog() async throws {
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
        do {
            try await sut.run(
                "test_command",
                rawLogPath: test_rawLogPath,
                logPath: test_logPath,
                args: "arg0", "arg1"
            )
        } catch {
            resultError = error
        }

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

        XCTAssertEqual(loggerBlockInvocations.count, 1)
        XCTAssertEqual(loggerBlockInvocations[0].header, "Beautifying Log".green)
        XCTAssertNil(loggerBlockInvocations[0].footer)
        XCTAssertEqual(loggerBlockInvocations[0].level, .compact)
        XCTAssertNil(loggerBlockInvocations[0].metricKey)
        XCTAssertEqual(loggerBlockInvocations[0].output, .all)
    }
}

// swiftlint:enable identifier_name
