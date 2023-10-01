//
//  VersionParserTests.swift
//
//
//  Created by Marcel Canhisares on 2023-09-30.
//
@testable import Rugby
import XCTest

final class VersionParserTests: XCTestCase {
    private var parser: VersionParser!

    override func setUp() {
        super.setUp()
        parser = VersionParser()
    }

    override func tearDown() {
        super.tearDown()
        parser = nil
    }
}

extension VersionParserTests {
    func testParseValidVersion() throws {
        let version = "1.0.0"
        let ghVersion = GitHubUpdaterVersion(major: 1, minor: 0, patch: 0,
                                             prerelease: GitHubUpdaterVersion.Prerelease.prod, build: 0)
        // Act
        let parsedVersion = try parser.parse(version)

        // Assert
        XCTAssertEqual(ghVersion.major, parsedVersion.major)
        XCTAssertEqual(ghVersion.minor, parsedVersion.minor)
        XCTAssertEqual(ghVersion.patch, parsedVersion.patch)
        XCTAssertEqual(ghVersion.prerelease, parsedVersion.prerelease)
        XCTAssertEqual(ghVersion.build, parsedVersion.build)
    }

    func testParseValidBetaVersion() throws {
        let version = "1.0.0b"
        let ghVersion = GitHubUpdaterVersion(major: 1, minor: 0, patch: 0,
                                             prerelease: GitHubUpdaterVersion.Prerelease.beta, build: 0)
        // Act
        let parsedVersion = try parser.parse(version)

        // Assert
        XCTAssertEqual(ghVersion.major, parsedVersion.major)
        XCTAssertEqual(ghVersion.minor, parsedVersion.minor)
        XCTAssertEqual(ghVersion.patch, parsedVersion.patch)
        XCTAssertEqual(ghVersion.prerelease, parsedVersion.prerelease)
        XCTAssertEqual(ghVersion.build, parsedVersion.build)
    }

    func testParseValidBuildVersion() throws {
        let version = "1.0.0b1"
        let ghVersion = GitHubUpdaterVersion(major: 1, minor: 0, patch: 0,
                                             prerelease: GitHubUpdaterVersion.Prerelease.beta, build: 1)
        // Act
        let parsedVersion = try parser.parse(version)

        // Assert
        XCTAssertEqual(ghVersion.major, parsedVersion.major)
        XCTAssertEqual(ghVersion.minor, parsedVersion.minor)
        XCTAssertEqual(ghVersion.patch, parsedVersion.patch)
        XCTAssertEqual(ghVersion.prerelease, parsedVersion.prerelease)
        XCTAssertEqual(ghVersion.build, parsedVersion.build)
    }

    func testParseInvalidBuildVersion() throws {
        let version = "1.0.0ba"
        let ghVersion = GitHubUpdaterVersion(major: 1, minor: 0, patch: 0,
                                             prerelease: GitHubUpdaterVersion.Prerelease.beta, build: 1)
        // Act
        let parsedVersion = try parser.parse(version)

        // Assert
        XCTAssertEqual(ghVersion.major, parsedVersion.major)
        XCTAssertEqual(ghVersion.minor, parsedVersion.minor)
        XCTAssertEqual(ghVersion.patch, parsedVersion.patch)
        XCTAssertEqual(ghVersion.prerelease, parsedVersion.prerelease)
        XCTAssertNotEqual(ghVersion.build, parsedVersion.build)
    }

    func testParseInvalidBetaVersion() throws {
        let version = "1.0.0a1"
        let ghVersion = GitHubUpdaterVersion(major: 1, minor: 0, patch: 0,
                                             prerelease: GitHubUpdaterVersion.Prerelease.beta, build: 1)
        // Act
        let parsedVersion = try parser.parse(version)

        // Assert
        XCTAssertEqual(ghVersion.major, parsedVersion.major)
        XCTAssertEqual(ghVersion.minor, parsedVersion.minor)
        XCTAssertEqual(ghVersion.patch, parsedVersion.patch)
        XCTAssertNotEqual(ghVersion.prerelease, parsedVersion.prerelease)
        XCTAssertNotEqual(ghVersion.build, parsedVersion.build)
    }

    func testInvalidShortVersionParse() {
        let version = "1.0"
        let expectedLocalizedDescription = VersionParserError.incorrectVersion(version).localizedDescription

        // Act & Assert
        XCTAssertThrowsError(try parser.parse(version)) { error in
            XCTAssertEqual((error as? VersionParserError)?.localizedDescription, expectedLocalizedDescription)
        }
    }

    func testInvalidCharVersionParse() {
        let version = "1.o.0"
        let expectedLocalizedDescription = VersionParserError.incorrectVersion(version).localizedDescription

        // Act & Assert
        XCTAssertThrowsError(try parser.parse(version)) { error in
            XCTAssertEqual((error as? VersionParserError)?.localizedDescription, expectedLocalizedDescription)
        }
    }
}
