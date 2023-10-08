@testable import LocalPod
import XCTest

final class ResourceBundleTests: XCTestCase {
    func testAccessToResourcesBundle() throws {
        try dummyTest(.resourcesBundle, expectedValue: "another")
    }

    func testAccessToTestResourcesBundle() throws {
        try dummyTest(.testResourcesBundle, expectedValue: "some")
    }

    private func dummyTest(_ bundle: Bundle, expectedValue: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let path = bundle.path(forResource: "dummy", ofType: "json") ?? ""
        let data = try Data(contentsOf: URL(filePath: path))
        let dummy = try JSONDecoder().decode(Dummy.self, from: data)
        XCTAssertEqual(dummy.id, expectedValue, file: file, line: line)
    }
}

struct Dummy: Codable {
    let id: String
}
