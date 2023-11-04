@testable import RugbyFoundation
import XCTest

final class StringTests: XCTestCase {

    // MARK: - homeFinderRelativePath

    func test_homeFinderRelativePath_success() {
        let homeDirectoryPath = ProcessInfo.processInfo.environment["HOME"] ?? ""
        let path = "\(homeDirectoryPath)/some/path/to/folder"

        // Act & Assert
        XCTAssertEqual(path.homeFinderRelativePath(), "~/some/path/to/folder")
    }

    func test_homeFinderRelativePath_fail() {
        let path = "/some/path/to/folder"

        // Act & Assert
        XCTAssertEqual(path.homeFinderRelativePath(), path)
    }

    // MARK: - homeEnvRelativePath

    func test_homeEnvRelativePath_success() {
        let homeDirectoryPath = ProcessInfo.processInfo.environment["HOME"] ?? ""
        let path = "\(homeDirectoryPath)/some/path/to/folder"

        // Act & Assert
        XCTAssertEqual(path.homeEnvRelativePath(), "${HOME}/some/path/to/folder")
    }

    func test_homeEnvRelativePath_fail() {
        let path = "/some/path/to/folder"

        // Act & Assert
        XCTAssertEqual(path.homeEnvRelativePath(), path)
    }

    // MARK: - groups(regex:)

    func test_groupRegex() throws {
        let regex = #"(Apple Swift version)\s(\d+\.\d+(?:\.\d)?)"#

        // Act
        let groups = try "Apple Swift version 5.7.1".groups(regex: regex)

        // Assert
        XCTAssertEqual(groups, ["Apple Swift version 5.7.1", "Apple Swift version", "5.7.1"])
    }

    // MARK: - uppercasedFirstLetter

    func test_uppercasedFirstLetter() {
        XCTAssertEqual("Some".uppercasedFirstLetter, "Some")
        XCTAssertEqual("some".uppercasedFirstLetter, "Some")
        XCTAssertEqual("1ome".uppercasedFirstLetter, "1ome")
        XCTAssertEqual(".ome".uppercasedFirstLetter, ".ome")
        XCTAssertEqual(" some".uppercasedFirstLetter, " some")
        XCTAssertEqual("some tests".uppercasedFirstLetter, "Some tests")
        XCTAssertEqual("some-tests here".uppercasedFirstLetter, "Some-tests here")
    }
}
