import Rainbow
@testable import Rugby
import XCTest

final class ProgressPrinterTests: XCTestCase {
    private var sut: ProgressPrinter!
    private var printer: PrinterMock!
    private var timerTaskFactory: ITimerTaskFactoryMock!

    override func setUp() {
        super.setUp()
        Rainbow.outputTarget = .console
        Rainbow.enabled = true
        printer = PrinterMock()
        timerTaskFactory = ITimerTaskFactoryMock()
        sut = ProgressPrinter(printer: printer, timerTaskFactory: timerTaskFactory)
    }

    override func tearDown() {
        super.tearDown()
        printer = nil
        sut = nil
    }
}

extension ProgressPrinterTests {
    func test_show() async {
        timerTaskFactory.makeTaskIntervalTaskReturnValue = ITimerTaskMock()
        let result = await sut.show(text: "test_text", level: .compact) {
            timerTaskFactory.makeTaskIntervalTaskReceivedArguments?.task()
            return "test_result"
        }

        // Assert
        XCTAssertEqual(result, "test_result")
        let invocations = printer.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 1)
        XCTAssertEqual(invocations[0].text, "test_text")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[33m◔\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, 0)
        XCTAssertEqual(invocations[0].level, .compact)
        XCTAssertTrue(invocations[0].updateLine)
    }

    func test_showTriple() async {
        timerTaskFactory.makeTaskIntervalTaskReturnValue = ITimerTaskMock()
        let result = await sut.show(text: "test_text", level: .compact) {
            timerTaskFactory.makeTaskIntervalTaskReceivedArguments?.task()
            timerTaskFactory.makeTaskIntervalTaskReceivedArguments?.task()
            timerTaskFactory.makeTaskIntervalTaskReceivedArguments?.task()
            return "test_result"
        }

        // Assert
        XCTAssertEqual(result, "test_result")
        let invocations = printer.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 3)
        XCTAssertEqual(invocations[0].text, "test_text")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[33m◔\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, 0)
        XCTAssertEqual(invocations[0].level, .compact)
        XCTAssertTrue(invocations[0].updateLine)

        XCTAssertEqual(invocations[1].text, "test_text")
        XCTAssertEqual(invocations[1].icon, "\u{1B}[33m◔\u{1B}[0m")
        XCTAssertEqual(invocations[1].duration, 0)
        XCTAssertEqual(invocations[1].level, .compact)
        XCTAssertTrue(invocations[1].updateLine)

        XCTAssertEqual(invocations[2].text, "test_text")
        XCTAssertEqual(invocations[2].icon, "\u{1B}[33m◑\u{1B}[0m")
        XCTAssertEqual(invocations[2].duration, 0)
        XCTAssertEqual(invocations[2].level, .compact)
        XCTAssertTrue(invocations[2].updateLine)
    }

    func test_showCancel() async {
        let timerTask = ITimerTaskMock()
        timerTaskFactory.makeTaskIntervalTaskReturnValue = timerTask
        let result = await sut.show(text: "test_text", level: .compact) {
            timerTaskFactory.makeTaskIntervalTaskReceivedArguments?.task()
            await sut.cancel()
            return "test_result"
        }

        // Assert
        XCTAssertEqual(result, "test_result")
        XCTAssertTrue(timerTask.cancelCalled)
        let invocations = printer.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 1)
        XCTAssertEqual(invocations[0].text, "test_text")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[33m◔\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, 0)
        XCTAssertEqual(invocations[0].level, .compact)
        XCTAssertTrue(invocations[0].updateLine)
    }

    func test_showStop() async {
        let timerTask = ITimerTaskMock()
        timerTaskFactory.makeTaskIntervalTaskReturnValue = timerTask
        let result = await sut.show(text: "test_text", level: .compact) {
            timerTaskFactory.makeTaskIntervalTaskReceivedArguments?.task()
            await sut.stop()
            return "test_result"
        }

        // Assert
        XCTAssertEqual(result, "test_result")
        XCTAssertTrue(timerTask.cancelCalled)
        let invocations = printer.printIconDurationLevelUpdateLineReceivedInvocations
        XCTAssertEqual(invocations.count, 1)
        XCTAssertEqual(invocations[0].text, "test_text")
        XCTAssertEqual(invocations[0].icon, "\u{1B}[33m◔\u{1B}[0m")
        XCTAssertEqual(invocations[0].duration, 0)
        XCTAssertEqual(invocations[0].level, .compact)
        XCTAssertTrue(invocations[0].updateLine)
    }
}
