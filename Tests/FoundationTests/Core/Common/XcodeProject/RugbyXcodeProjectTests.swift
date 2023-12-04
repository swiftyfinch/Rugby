@testable import RugbyFoundation
import XCTest

final class RugbyXcodeProjectTests: XCTestCase {
    private var sut: IRugbyXcodeProject!
    private var xcodeProject: IInternalXcodeProjectMock!

    override func setUp() {
        super.setUp()
        xcodeProject = IInternalXcodeProjectMock()
        sut = RugbyXcodeProject(xcodeProject: xcodeProject)
    }

    override func tearDown() {
        super.tearDown()
        xcodeProject = nil
        sut = nil
    }
}

extension RugbyXcodeProjectTests {
    func test_isAlreadyUsingRugby_true() async throws {
        xcodeProject.containsBuildSettingsKeyReturnValue = true

        // Act
        let isAlreadyUsingRugby = try await sut.isAlreadyUsingRugby()

        // Assert
        XCTAssertEqual(xcodeProject.containsBuildSettingsKeyCallsCount, 1)
        XCTAssertTrue(isAlreadyUsingRugby)
    }

    func test_isAlreadyUsingRugby_false() async throws {
        xcodeProject.containsBuildSettingsKeyReturnValue = false

        // Act
        let isAlreadyUsingRugby = try await sut.isAlreadyUsingRugby()

        // Assert
        XCTAssertEqual(xcodeProject.containsBuildSettingsKeyCallsCount, 1)
        XCTAssertFalse(isAlreadyUsingRugby)
    }

    func test_markAsUsingRugby() async throws {
        try await sut.markAsUsingRugby()

        // Assert
        XCTAssertEqual(xcodeProject.setBuildSettingsKeyValueCallsCount, 1)
        XCTAssertEqual(xcodeProject.setBuildSettingsKeyValueReceivedArguments?.buildSettingsKey, "RUGBY_PATCHED")
        XCTAssertEqual(xcodeProject.setBuildSettingsKeyValueReceivedArguments?.value as? String, "YES")
    }
}
