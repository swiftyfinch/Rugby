@testable import RugbyFoundation
import XCTest

final class SHA1HasherTests: XCTestCase {
    private var sut: FoundationHasher!

    override func setUp() {
        super.setUp()
        sut = SHA1Hasher()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

extension SHA1HasherTests {
    func test_hash_string() {
        let expected = "f6b1cf5"
        let input = "string_for_hash"

        // Act
        let result = sut.hash(input)

        // Assert
        XCTAssertEqual(result, expected)
    }

    func test_hash_data() {
        let expected = "f6b1cf5"
        let input = Data("string_for_hash".utf8)

        // Act
        let result = sut.hash(input)

        // Assert
        XCTAssertEqual(result, expected)
    }

    func test_hash_array_of_strings() {
        let expected = "2e88151"
        let input = ["string_for_hash0", "string_for_hash1", "string_for_hash2"]

        // Act
        let result = sut.hash(input)

        // Assert
        XCTAssertEqual(result, expected)
    }
}
