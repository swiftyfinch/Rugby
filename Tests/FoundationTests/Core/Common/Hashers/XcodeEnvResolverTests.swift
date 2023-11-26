@testable import RugbyFoundation
import XCTest

final class XcodeEnvResolverTests: XCTestCase {
    private var logger: ILoggerMock!
    private let env = [
        "SRCROOT": "/Users/swiftyfinch/Example/Pods"
    ]
    private var sut: IXcodeEnvResolver!

    override func setUp() {
        super.setUp()
        logger = ILoggerMock()
        sut = XcodeEnvResolver(logger: logger, env: env)
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        sut = nil
    }
}

extension XcodeEnvResolverTests {
    func test_input_xcfilelist() async throws {
        let resolvedPath = try await sut.resolve(
            path: "${PODS_ROOT}/Target Support Files/Moya/Moya-xcframeworks-input-files.xcfilelist",
            additionalEnv: ["PODS_ROOT": "${SRCROOT}"]
        )

        // Assert
        XCTAssertEqual(
            resolvedPath,
            "/Users/swiftyfinch/Example/Pods/Target Support Files/Moya/Moya-xcframeworks-input-files.xcfilelist"
        )
    }

    func test_xcframeworks_script() async throws {
        let resolvedPath = try await sut.resolve(
            path: "${PODS_ROOT}/Target Support Files/Kingfisher/Kingfisher-xcframeworks.sh",
            additionalEnv: ["PODS_ROOT": "${SRCROOT}"]
        )

        // Assert
        XCTAssertEqual(
            resolvedPath,
            "/Users/swiftyfinch/Example/Pods/Target Support Files/Kingfisher/Kingfisher-xcframeworks.sh"
        )
    }

    func test_xcframework() async throws {
        let resolvedPath = try await sut.resolve(
            path: "${PODS_ROOT}/SnapKit/SnapKit.xcframework",
            additionalEnv: ["PODS_ROOT": "${SRCROOT}"]
        )

        // Assert
        XCTAssertEqual(
            resolvedPath,
            "/Users/swiftyfinch/Example/Pods/SnapKit/SnapKit.xcframework"
        )
    }

    func test_without_all_env_variables() async throws {
        let resolvedPath = try await sut.resolve(
            path: "${PODS_ROOT}/SnapKit/SnapKit.xcframework",
            additionalEnv: [:]
        )

        // Assert
        XCTAssertEqual(resolvedPath, "${PODS_ROOT}/SnapKit/SnapKit.xcframework")
    }

    func test_override_env_with_additionalEnv() async throws {
        let resolvedPath = try await sut.resolve(
            path: "${PODS_ROOT}/SnapKit/SnapKit.xcframework",
            additionalEnv: ["PODS_ROOT": "/Users/swiftyfinch/Pods"]
        )

        // Assert
        XCTAssertEqual(resolvedPath, "/Users/swiftyfinch/Pods/SnapKit/SnapKit.xcframework")
    }
}
