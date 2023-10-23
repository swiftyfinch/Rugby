import Fish
@testable import Rugby
import RugbyFoundation
import XCTest

final class FilePrinterTests: XCTestCase {
    private var sut: FilePrinter!
    private var file: IFileMock!

    override func setUp() async throws {
        try await super.setUp()
        file = IFileMock()
        let date = Date(timeIntervalSinceReferenceDate: 687_312_329)
        sut = FilePrinter(file: file, dateProvider: { date })
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        file = nil
    }
}

extension FilePrinterTests {
    func test_canPrint() {
        let results = LogLevel.allCases.map(sut.canPrint(level:))

        // Assert
        XCTAssertTrue(results.allSatisfy { $0 == true })
    }

    func test_full() {
        LogLevel.allCases.forEach {
            sut.print("test_text", icon: "⚑", duration: 329, level: $0, updateLine: true)
        }

        // Assert
        XCTAssertTrue(file.appendReceivedInvocations.allSatisfy { $0 == "[05:05:29]: ⚑ [5m 29s] test_text\n" })
    }

    func test_withoutIcon() {
        sut.print("test_text", icon: nil, duration: 6, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(file.appendReceivedInvocations, ["[05:05:29]: [6s] test_text\n"])
    }

    func test_withoutIconAndDuration() {
        sut.print("test_text", icon: nil, duration: nil, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(file.appendReceivedInvocations, ["[05:05:29]: test_text\n"])
    }

    func test_withoutIconAndDurationUpdateLineFalse() {
        sut.print("test_text", icon: nil, duration: nil, level: .compact, updateLine: false)

        // Assert
        XCTAssertEqual(file.appendReceivedInvocations, ["[05:05:29]: test_text\n"])
    }

    func test_shift() {
        sut.shift()
        sut.shift()
        sut.print("test_text", icon: "⚑", duration: 329, level: .compact, updateLine: true)

        // Assert
        XCTAssertEqual(file.appendReceivedInvocations, ["[05:05:29]:   ⚑ [5m 29s] test_text\n"])
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
        XCTAssertEqual(file.appendReceivedInvocations, [
            "[05:05:29]:   ⚑ [29s] test_text0\n",
            "[05:05:29]:     ⚑ [17m 9s] test_text1\n",
            "[05:05:29]:   ⚑ test_text2\n"
        ])
    }
}
