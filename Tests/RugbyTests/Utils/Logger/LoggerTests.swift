import Rainbow
@testable import Rugby
import RugbyFoundation
import XCTest

final class LoggerTests: XCTestCase {
    private var sut: ILogger!
    private var clock: IClockMock!
    private var screenPrinter: PrinterMock!
    private var filePrinter: PrinterMock!
    private var progressPrinter: IProgressPrinterMock!
    private var metricsLogger: IMetricsLoggerMock!

    override func setUp() {
        super.setUp()
        Rainbow.outputTarget = .console
        Rainbow.enabled = true
        clock = IClockMock()
        clock.underlyingSystemUptime = 0
        clock.timeSinceSystemUptimeReturnValue = 0
        sut = Logger(clock: clock)
        screenPrinter = PrinterMock()
        filePrinter = PrinterMock()
        progressPrinter = IProgressPrinterMock()
        metricsLogger = IMetricsLoggerMock()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        clock = nil
        screenPrinter = nil
        filePrinter = nil
        progressPrinter = nil
        metricsLogger = nil
    }
}

extension LoggerTests {
    func test_logBlock() async {
        screenPrinter.canPrintLevelClosure = { _ in true }
        await sut.configure(screenPrinter: screenPrinter, filePrinter: nil, progressPrinter: nil, metricsLogger: nil)

        // Act
        let result = await sut.log(
            "Use",
            footer: nil,
            metricKey: nil,
            level: .compact,
            output: .screen,
            block: { "log_result" }
        )

        // Assert
        XCTAssertEqual(result, "log_result")
        let invocations = screenPrinter.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 2)
        XCTAssertEqual(invocations[0].text, "Use")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[33m⚑\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, nil)
        XCTAssertEqual(invocations[0].level, .compact)
        XCTAssertEqual(invocations[0].updateLine, false)
        XCTAssertEqual(invocations[1].text, "Use")
        XCTAssertEqual(invocations[1].icon, "\u{1B}[32m✓\u{1B}[0m")
        XCTAssertEqual(invocations[1].duration, nil)
        XCTAssertEqual(invocations[1].level, .compact)
        XCTAssertEqual(invocations[1].updateLine, true)
    }

    func test_logFooter() async {
        screenPrinter.canPrintLevelClosure = { _ in true }
        await progressPrinter.setShowTextLevelJobClosure { _, _, block in try await block() }
        await sut.configure(
            screenPrinter: screenPrinter,
            filePrinter: nil,
            progressPrinter: progressPrinter,
            metricsLogger: nil
        )

        // Act
        await sut.log(
            "Use",
            footer: "test_footer",
            metricKey: nil,
            level: .compact,
            output: .screen,
            block: { await sut.log("Some", level: .compact, output: .screen) }
        )

        // Assert
        let invocations = screenPrinter.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 4)
        XCTAssertEqual(invocations[0].text, "Use")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[33m⚑\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, nil)
        XCTAssertEqual(invocations[0].level, .compact)
        XCTAssertEqual(invocations[0].updateLine, false)
        XCTAssertEqual(invocations[1].text, "Use")
        XCTAssertEqual(invocations[1].icon, "\u{1B}[33m⚑\u{1B}[0m")
        XCTAssertEqual(invocations[1].duration, nil)
        XCTAssertEqual(invocations[1].level, .compact)
        XCTAssertEqual(invocations[1].updateLine, true)
        XCTAssertEqual(invocations[2].text, "Some")
        XCTAssertEqual(invocations[2].icon, "\u{1B}[32m✓\u{1B}[0m")
        XCTAssertEqual(invocations[2].duration, nil)
        XCTAssertEqual(invocations[2].level, .compact)
        XCTAssertEqual(invocations[2].updateLine, false)
        XCTAssertEqual(invocations[3].text, "test_footer")
        XCTAssertEqual(invocations[3].icon, "\u{1B}[32m✓\u{1B}[0m")
        XCTAssertEqual(invocations[3].duration, nil)
        XCTAssertEqual(invocations[3].level, .compact)
        XCTAssertEqual(invocations[3].updateLine, false)
    }

    func test_logMeticKey() async {
        clock.underlyingSystemUptime = 0.1
        clock.timeSinceSystemUptimeReturnValue = 0.11
        screenPrinter.canPrintLevelClosure = { _ in true }
        await sut.configure(
            screenPrinter: screenPrinter,
            filePrinter: nil,
            progressPrinter: nil,
            metricsLogger: metricsLogger
        )

        // Act
        await sut.log(
            "Build",
            footer: nil,
            metricKey: "xcodebuild",
            level: .info,
            output: .screen,
            block: {}
        )

        // Assert
        let invocations = screenPrinter.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(clock.timeSinceSystemUptimeReceivedSinceSystemUptime, 0.1)
        XCTAssertEqual(invocations.count, 2)
        XCTAssertEqual(invocations[0].text, "Build")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[33m⚑\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, nil)
        XCTAssertEqual(invocations[0].level, .info)
        XCTAssertEqual(invocations[0].updateLine, false)
        XCTAssertEqual(invocations[1].text, "Build")
        XCTAssertEqual(invocations[1].icon, "\u{1B}[32m✓\u{1B}[0m")
        XCTAssertEqual(invocations[1].duration?.description, "0.11")
        XCTAssertEqual(invocations[1].level, .info)
        XCTAssertEqual(invocations[1].updateLine, true)
        XCTAssertEqual(metricsLogger.addNameReceivedInvocations.count, 1)
        XCTAssertEqual(metricsLogger.addNameReceivedInvocations[0].name, "xcodebuild")
        XCTAssertEqual(metricsLogger.addNameReceivedInvocations[0].metric.description, "0.11")
        XCTAssertTrue(metricsLogger.logNameReceivedInvocations.isEmpty)
    }

    func test_logToFile() async {
        filePrinter.canPrintLevelClosure = { _ in true }
        await sut.configure(
            screenPrinter: nil,
            filePrinter: filePrinter,
            progressPrinter: nil,
            metricsLogger: nil
        )

        // Act
        await sut.log(
            "Warmup",
            footer: nil,
            metricKey: nil,
            level: .result,
            output: .file,
            block: {}
        )

        // Assert
        let invocations = filePrinter.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 2)
        XCTAssertEqual(invocations[0].text, "Warmup")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[33m⚑\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, nil)
        XCTAssertEqual(invocations[0].level, .result)
        XCTAssertEqual(invocations[0].updateLine, false)
        XCTAssertEqual(invocations[1].text, "Warmup")
        XCTAssertEqual(invocations[1].icon, "\u{1B}[32m✓\u{1B}[0m")
        XCTAssertEqual(invocations[1].duration, nil)
        XCTAssertEqual(invocations[1].level, .result)
        XCTAssertEqual(invocations[1].updateLine, false)
    }

    func test_logAuto() async {
        screenPrinter.canPrintLevelClosure = { _ in true }
        await sut.configure(
            screenPrinter: screenPrinter,
            filePrinter: nil,
            progressPrinter: nil,
            metricsLogger: nil
        )

        // Act
        let result = await sut.log(
            "Warmup",
            footer: nil,
            metricKey: nil,
            level: .result,
            output: .all,
            auto: "test_result"
        )

        // Assert
        XCTAssertEqual(result, "test_result")
        let invocations = screenPrinter.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 2)
        XCTAssertEqual(invocations[0].text, "Warmup")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[33m⚑\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, nil)
        XCTAssertEqual(invocations[0].level, .result)
        XCTAssertEqual(invocations[0].updateLine, false)
        XCTAssertEqual(invocations[1].text, "Warmup")
        XCTAssertEqual(invocations[1].icon, "\u{1B}[32m✓\u{1B}[0m")
        XCTAssertEqual(invocations[1].duration, nil)
        XCTAssertEqual(invocations[1].level, .result)
        XCTAssertEqual(invocations[1].updateLine, true)
    }

    func test_log() async {
        screenPrinter.canPrintLevelClosure = { _ in true }
        await sut.configure(
            screenPrinter: screenPrinter,
            filePrinter: nil,
            progressPrinter: nil,
            metricsLogger: nil
        )

        // Act
        await sut.log("test_text", level: .result, output: .all)

        // Assert
        let invocations = screenPrinter.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 1)
        XCTAssertEqual(invocations[0].text, "test_text")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[32m✓\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, nil)
        XCTAssertEqual(invocations[0].level, .result)
        XCTAssertEqual(invocations[0].updateLine, false)
    }

    func test_logPlain() async {
        screenPrinter.canPrintLevelClosure = { _ in true }
        await sut.configure(
            screenPrinter: screenPrinter,
            filePrinter: nil,
            progressPrinter: nil,
            metricsLogger: nil
        )

        // Act
        await sut.logPlain("test_text", level: .result, output: .all)

        // Assert
        let invocations = screenPrinter.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 1)
        XCTAssertEqual(invocations[0].text, "test_text")
        XCTAssertEqual(invocations[0].icon, nil)
        XCTAssertEqual(invocations[0].duration, nil)
        XCTAssertEqual(invocations[0].level, .result)
        XCTAssertEqual(invocations[0].updateLine, false)
    }

    func test_logList() async {
        screenPrinter.canPrintLevelClosure = { _ in true }
        await sut.configure(
            screenPrinter: screenPrinter,
            filePrinter: nil,
            progressPrinter: nil,
            metricsLogger: nil
        )

        // Act
        await sut.logList(["test_text0", "test_text1"], level: .result, output: .all)

        // Assert
        let invocations = screenPrinter.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 2)
        XCTAssertEqual(invocations[0].text, "test_text0")
        XCTAssertEqual(invocations[0].icon, nil)
        XCTAssertEqual(invocations[0].duration, nil)
        XCTAssertEqual(invocations[0].level, .result)
        XCTAssertEqual(invocations[0].updateLine, false)
        XCTAssertEqual(invocations[1].text, "test_text1")
        XCTAssertEqual(invocations[1].icon, nil)
        XCTAssertEqual(invocations[1].duration, nil)
        XCTAssertEqual(invocations[1].level, .result)
        XCTAssertEqual(invocations[1].updateLine, false)
    }
}
