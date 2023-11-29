@testable import Rugby
import RugbyFoundation
import XCTest

final class RegexTests: XCTestCase {
    func test_plusSignEscaping_exactMatches() throws {
        let regex = try regex(patterns: [], exactMatches: ["Keyboard+LayoutGuide-framework"])

        // Assert
        let unwrapedRegex = try XCTUnwrap(regex)
        XCTAssertTrue(unwrapedRegex.isMatched("Keyboard+LayoutGuide-framework"))
    }

    func test_plusSignEscaping_patterns() throws {
        let regex = try regex(patterns: ["Keyboard.*"], exactMatches: [])

        // Assert
        let unwrapedRegex = try XCTUnwrap(regex)
        XCTAssertTrue(unwrapedRegex.isMatched("Keyboard+LayoutGuide-framework"))
    }

    func test_plusSignEscaping_patterns2() throws {
        let regex = try regex(patterns: ["Keyboard\\+"], exactMatches: [])

        // Assert
        let unwrapedRegex = try XCTUnwrap(regex)
        XCTAssertTrue(unwrapedRegex.isMatched("Keyboard+LayoutGuide-framework"))
    }
}

// MARK: - Utils

private extension NSRegularExpression {
    func isMatched(_ string: String) -> Bool {
        let range = NSRange(string.startIndex..., in: string)
        return firstMatch(in: string, range: range) != nil
    }
}
