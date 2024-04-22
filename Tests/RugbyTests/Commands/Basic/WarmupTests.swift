@testable import Rugby
import XCTest

final class WarmupTests: XCTestCase {
    func test_headersParsing_two() {
        let headers = ["X-First-Name: Joe", "User-Agent: yes-please/2000"].parseHeaders()

        // Assert
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers["X-First-Name"], "Joe")
        XCTAssertEqual(headers["User-Agent"], "yes-please/2000")
    }

    func test_headersParsing() {
        XCTAssertEqual(["User-Agent: yes-please/2000"].parseHeaders(), ["User-Agent": "yes-please/2000"])
        XCTAssertEqual(["User-Agent:yes-please/2000"].parseHeaders(), [:])
        XCTAssertEqual([].parseHeaders(), [:])
        XCTAssertEqual([""].parseHeaders(), [:])
    }
}
