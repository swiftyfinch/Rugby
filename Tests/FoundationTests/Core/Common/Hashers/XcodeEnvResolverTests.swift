@testable import RugbyFoundation
import XCTest

final class EnvVariablesResolverTests: XCTestCase {
    private var logger: ILoggerMock!
    private let env = [
        "SRCROOT": "/Users/swiftyfinch/Example/Pods"
    ]
    private var sut: IEnvVariablesResolver!

    override func setUp() {
        super.setUp()
        logger = ILoggerMock()
        sut = EnvVariablesResolver(logger: logger, env: env)
    }

    override func tearDown() {
        super.tearDown()
        logger = nil
        sut = nil
    }
}

extension EnvVariablesResolverTests {
    func test_input_xcfilelist() async throws {
        let resolved = try await sut.resolve(
            "${PODS_ROOT}/Target Support Files/Moya/Moya-xcframeworks-input-files.xcfilelist",
            additionalEnv: ["PODS_ROOT": "${SRCROOT}"]
        )

        // Assert
        XCTAssertEqual(
            resolved,
            "/Users/swiftyfinch/Example/Pods/Target Support Files/Moya/Moya-xcframeworks-input-files.xcfilelist"
        )
    }

    func test_xcframeworks_script() async throws {
        let resolved = try await sut.resolve(
            "${PODS_ROOT}/Target Support Files/Kingfisher/Kingfisher-xcframeworks.sh",
            additionalEnv: ["PODS_ROOT": "${SRCROOT}"]
        )

        // Assert
        XCTAssertEqual(
            resolved,
            "/Users/swiftyfinch/Example/Pods/Target Support Files/Kingfisher/Kingfisher-xcframeworks.sh"
        )
    }

    func test_xcframework() async throws {
        let resolved = try await sut.resolve(
            "${PODS_ROOT}/SnapKit/SnapKit.xcframework",
            additionalEnv: ["PODS_ROOT": "${SRCROOT}"]
        )

        // Assert
        XCTAssertEqual(
            resolved,
            "/Users/swiftyfinch/Example/Pods/SnapKit/SnapKit.xcframework"
        )
    }

    func test_without_all_env_variables() async throws {
        let resolved = try await sut.resolve(
            "${PODS_ROOT}/SnapKit/SnapKit.xcframework",
            additionalEnv: [:]
        )

        // Assert
        XCTAssertEqual(resolved, "${PODS_ROOT}/SnapKit/SnapKit.xcframework")
    }

    func test_override_env_with_additionalEnv() async throws {
        let resolved = try await sut.resolve(
            "${PODS_ROOT}/SnapKit/SnapKit.xcframework",
            additionalEnv: ["PODS_ROOT": "/Users/swiftyfinch/Pods"]
        )

        // Assert
        XCTAssertEqual(resolved, "/Users/swiftyfinch/Pods/SnapKit/SnapKit.xcframework")
    }

    func test_resolvedDifferentNaming() async throws {
        let env = ["SECRET_KEY": "qwerty123"]
        let resolved0 = try await sut.resolve("secret_key: ${SECRET_KEY}", additionalEnv: env)
        let resolved1 = try await sut.resolve("secret_key: $SECRET_KEY", additionalEnv: env)
        let resolved2 = try await sut.resolve("secret_key: $(SECRET_KEY)", additionalEnv: env)

        // Assert
        XCTAssertEqual(resolved0, "secret_key: qwerty123")
        XCTAssertEqual(resolved1, "secret_key: qwerty123")
        XCTAssertEqual(resolved2, "secret_key: qwerty123")
    }
}
