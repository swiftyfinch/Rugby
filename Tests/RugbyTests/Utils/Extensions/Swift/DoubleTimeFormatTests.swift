@testable import Rugby
import XCTest

final class DoubleTimeFormatTests: XCTestCase {
    func test_format() {
        XCTAssertEqual(0.0.format(), "0s")
        XCTAssertEqual(3.2.format(), "3.2s")
        XCTAssertEqual(28.39.format(), "28.3s")
        XCTAssertEqual(14.0.format(), "14s")
        XCTAssertEqual(140.0.format(), "2m 20s")
        XCTAssertEqual(2940.0.format(), "49m")
    }

    func test_formatWithoutMilliseconds() {
        XCTAssertEqual(0.0.format(withMilliseconds: false), "0s")
        XCTAssertEqual(3.2.format(withMilliseconds: false), "3s")
        XCTAssertEqual(28.39.format(withMilliseconds: false), "28s")
        XCTAssertEqual(14.0.format(withMilliseconds: false), "14s")
        XCTAssertEqual(140.0.format(withMilliseconds: false), "2m 20s")
        XCTAssertEqual(2940.0.format(withMilliseconds: false), "49m")
    }
}
