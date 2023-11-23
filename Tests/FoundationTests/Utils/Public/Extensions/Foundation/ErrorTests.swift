import Foundation
@testable import RugbyFoundation
import XCTest

final class ErrorTests: XCTestCase {
    private enum SomeLocalizedError: LocalizedError {
        case test

        var errorDescription: String? {
            "An example of test localized error."
        }
    }

    private enum NoneLocalizedError: Error {
        case parsingError(reason: String)
    }

    func test_localizedError() {
        XCTAssertEqual(SomeLocalizedError.test.beautifulDescription, "An example of test localized error.")
    }

    func test_noneLocalizedError() {
        XCTAssertEqual(
            NoneLocalizedError.parsingError(reason: "Incorrect a key name.").beautifulDescription,
            "parsingError(reason: \"Incorrect a key name.\")"
        )
    }
}
