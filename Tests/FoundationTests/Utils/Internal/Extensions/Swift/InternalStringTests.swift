@testable import RugbyFoundation
import XCTest

final class InternalStringTests: XCTestCase {}

extension InternalStringTests {
    func test_removing() {
        XCTAssertEqual("   Some".removing(3), "Some")
        XCTAssertEqual("sssSome".removing(3), "Some")
        XCTAssertEqual("Some".removing(0), "Some")
        XCTAssertEqual("Some".removing(4), "")
        XCTAssertEqual("Some".removing(5), "")
    }

    func test_prefixCount() {
        XCTAssertEqual("   Some".prefixCount(), 3)
        XCTAssertEqual("   Some".prefixCount(symbols: "s"), 0)
        XCTAssertEqual("sssSome".prefixCount(symbols: "s"), 3)
        XCTAssertEqual(" s Some".prefixCount(symbols: "s"), 0)
        XCTAssertEqual(" s Some".prefixCount(symbols: " "), 1)
    }

    func test_subpath() {
        XCTAssertEqual(
            "~/.rugby".subpath("logs", "13.11.2023T18.09.50", "rawBuild.log"),
            "~/.rugby/logs/13.11.2023T18.09.50/rawBuild.log"
        )
        XCTAssertEqual(
            "~/.rugby".subpath(nil, "logs", nil, "13.11.2023T18.09.50", "rawBuild.log", nil),
            "~/.rugby/logs/13.11.2023T18.09.50/rawBuild.log"
        )
        XCTAssertEqual("~/.rugby".subpath(nil), "~/.rugby")
        XCTAssertEqual("Example/.rugby".subpath("build"), "Example/.rugby/build")
    }
}
