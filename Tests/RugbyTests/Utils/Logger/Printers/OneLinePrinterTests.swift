import Fish
import Rainbow
@testable import Rugby
import RugbyFoundation
import XCTest

final class OneLinePrinterTests: XCTestCase {
    private var sut: OneLinePrinter!
    private var standardOutput: IStandardOutputMock!

    override func setUp() async throws {
        try await super.setUp()
        Rainbow.outputTarget = .console
        Rainbow.enabled = true
        standardOutput = IStandardOutputMock()
        sut = OneLinePrinter(
            standardOutput: standardOutput,
            maxLevel: .compact,
            columns: .max
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        standardOutput = nil
    }
}

extension OneLinePrinterTests {
    func test_canPrint() {
        sut = OneLinePrinter(standardOutput: standardOutput, maxLevel: .result, columns: .max)
        XCTAssertEqual(LogLevel.allCases.map(sut.canPrint(level:)), [true, false, false])

        sut = OneLinePrinter(standardOutput: standardOutput, maxLevel: .compact, columns: .max)
        XCTAssertEqual(LogLevel.allCases.map(sut.canPrint(level:)), [true, true, false])

        sut = OneLinePrinter(standardOutput: standardOutput, maxLevel: .info, columns: .max)
        XCTAssertEqual(LogLevel.allCases.map(sut.canPrint(level:)), [true, true, true])
    }

    func test_full() {
        sut = OneLinePrinter(standardOutput: standardOutput, maxLevel: .result, columns: .max)
        LogLevel.allCases.forEach {
            sut.print("test_text", icon: "⚑", duration: 329, level: $0, updateLine: true)
        }
        XCTAssertEqual(standardOutput.printReceivedInvocations, [
            "\u{1B}[1A\u{1B}[K⚑ \u{1B}[33m[5m 29s] \u{1B}[0mtest_text"
        ])

        standardOutput = IStandardOutputMock()
        sut = OneLinePrinter(standardOutput: standardOutput, maxLevel: .compact, columns: .max)
        LogLevel.allCases.forEach {
            sut.print("test_text", icon: "⚑", duration: 329, level: $0, updateLine: true)
        }
        XCTAssertEqual(standardOutput.printReceivedInvocations, [
            "\u{1B}[1A\u{1B}[K⚑ \u{1B}[33m[5m 29s] \u{1B}[0mtest_text",
            "\u{1B}[1A\u{1B}[K⚑ \u{1B}[33m[5m 29s] \u{1B}[0mtest_text"
        ])

        standardOutput = IStandardOutputMock()
        sut = OneLinePrinter(standardOutput: standardOutput, maxLevel: .info, columns: .max)
        LogLevel.allCases.forEach {
            sut.print("test_text", icon: "⚑", duration: 329, level: $0, updateLine: true)
        }
        XCTAssertEqual(standardOutput.printReceivedInvocations, [
            "\u{1B}[1A\u{1B}[K⚑ \u{1B}[33m[5m 29s] \u{1B}[0mtest_text",
            "\u{1B}[1A\u{1B}[K⚑ \u{1B}[33m[5m 29s] \u{1B}[0mtest_text",
            "\u{1B}[1A\u{1B}[K⚑ \u{1B}[33m[5m 29s] \u{1B}[0mtest_text"
        ])
    }

    func test_withoutIcon() {
        sut.print("test_text", icon: nil, duration: 6, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(standardOutput.printReceivedInvocations, ["\u{1B}[1A\u{1B}[K\u{1B}[33m[6s] \u{1B}[0mtest_text"])
    }

    func test_withoutIconAndDuration() {
        sut.print("test_text", icon: nil, duration: nil, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(standardOutput.printReceivedInvocations, ["\u{1B}[1A\u{1B}[Ktest_text"])
    }

    func test_withoutIconAndDurationUpdateLineFalse() {
        sut.print("test_text", icon: nil, duration: nil, level: .compact, updateLine: false)

        // Assert
        XCTAssertEqual(standardOutput.printReceivedInvocations, ["test_text"])
    }

    func test_columns() {
        sut = OneLinePrinter(standardOutput: standardOutput, maxLevel: .info, columns: 5)
        sut.print("test_text", icon: nil, duration: nil, level: .compact, updateLine: false)

        // Assert
        XCTAssertEqual(standardOutput.printReceivedInvocations, ["tes…"])
    }

    func test_shift() {
        sut.shift()
        sut.shift()
        sut.print("test_text", icon: "⚑", duration: 329, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(
            standardOutput.printReceivedInvocations,
            ["\u{1B}[1A\u{1B}[K  ⚑ \u{1B}[33m[5m 29s] \u{1B}[0mtest_text"]
        )
    }

    func test_shiftAndUnshift() {
        sut.shift()
        sut.shift()
        sut.print("test_text0", icon: "⚑", duration: 29, level: .compact, updateLine: true)
        sut.shift()
        sut.print("test_text1", icon: "⚑", duration: 1029, level: .compact, updateLine: true)
        sut.unshift()
        sut.print("test_text2", icon: "⚑", duration: nil, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(standardOutput.printReceivedInvocations, [
            "\u{1B}[1A\u{1B}[K  ⚑ \u{1B}[33m[29s] \u{1B}[0mtest_text0",
            "\u{1B}[1A\u{1B}[K    ⚑ \u{1B}[33m[17m 9s] \u{1B}[0mtest_text1",
            "\u{1B}[1A\u{1B}[K  ⚑ test_text2"
        ])
    }
}
