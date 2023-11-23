@testable import LocalPod
import XCTest

final class ResourceBundleTests: XCTestCase {
    func testAccessToResourcesBundle() throws {
        try XCTAssertEqual(readId(from: .resourcesBundle), "LocalPod")
    }

    func testAccessToTestResourcesBundle() throws {
        try XCTAssertEqual(readId(from: .testResourcesBundle), "ResourceBundleTests")
    }

    // MARK: - Private

    private func readId(from bundle: Bundle) throws -> String {
        let path = bundle.path(forResource: "dummy", ofType: "json") ?? ""
        let data = try Data(contentsOf: URL(filePath: path))
        return try JSONDecoder().decode(Dummy.self, from: data).id
    }
}

struct Dummy: Codable {
    let id: String
}
