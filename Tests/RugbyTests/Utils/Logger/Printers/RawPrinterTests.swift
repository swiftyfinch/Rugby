import Fish
import Rainbow
@testable import Rugby
import RugbyFoundation
import XCTest

final class RawPrinterTests: XCTestCase {
    private var sut: RawPrinter!
    private var standardOutput: IStandardOutputMock!

    override func setUp() async throws {
        try await super.setUp()
        Rainbow.outputTarget = .console
        Rainbow.enabled = true
        standardOutput = IStandardOutputMock()
        sut = RawPrinter(
            standardOutput: standardOutput,
            maxLevel: .compact
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        standardOutput = nil
    }
}

extension RawPrinterTests {
    func test_canPrint() {
        sut = RawPrinter(standardOutput: standardOutput, maxLevel: .result)
        XCTAssertEqual(LogLevel.allCases.map(sut.canPrint(level:)), [true, false, false])

        sut = RawPrinter(standardOutput: standardOutput, maxLevel: .compact)
        XCTAssertEqual(LogLevel.allCases.map(sut.canPrint(level:)), [true, true, false])

        sut = RawPrinter(standardOutput: standardOutput, maxLevel: .info)
        XCTAssertEqual(LogLevel.allCases.map(sut.canPrint(level:)), [true, true, true])
    }

    func test_full() {
        sut = RawPrinter(standardOutput: standardOutput, maxLevel: .result)
        LogLevel.allCases.forEach {
            sut.print("test_text", icon: "⚑", duration: 329, level: $0, updateLine: true)
        }
        XCTAssertEqual(standardOutput.printReceivedInvocations, [
            "test_text"
        ])

        standardOutput = IStandardOutputMock()
        sut = RawPrinter(standardOutput: standardOutput, maxLevel: .compact)
        LogLevel.allCases.forEach {
            sut.print("test_text", icon: "⚑", duration: 329, level: $0, updateLine: true)
        }
        XCTAssertEqual(standardOutput.printReceivedInvocations, [
            "test_text",
            "test_text"
        ])

        standardOutput = IStandardOutputMock()
        sut = RawPrinter(standardOutput: standardOutput, maxLevel: .info)
        LogLevel.allCases.forEach {
            sut.print("test_text", icon: "⚑", duration: 329, level: $0, updateLine: true)
        }
        XCTAssertEqual(standardOutput.printReceivedInvocations, [
            "test_text",
            "test_text",
            "test_text"
        ])
    }

    func test_withoutIcon() {
        sut.print("test_text", icon: nil, duration: 6, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(standardOutput.printReceivedInvocations, ["test_text"])
    }

    func test_withoutIconAndDuration() {
        sut.print("test_text", icon: nil, duration: nil, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(standardOutput.printReceivedInvocations, ["test_text"])
    }

    func test_withoutIconAndDurationUpdateLineFalse() {
        sut.print("test_text", icon: nil, duration: nil, level: .compact, updateLine: false)

        // Assert
        XCTAssertEqual(standardOutput.printReceivedInvocations, ["test_text"])
    }

    func test_shift() {
        sut.shift()
        sut.shift()
        sut.print("test_text", icon: "⚑", duration: 329, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(standardOutput.printReceivedInvocations, ["test_text"])
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
            "test_text0",
            "test_text1",
            "test_text2"
        ])
    }
}
