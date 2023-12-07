@testable import RugbyFoundation

extension XcodeBuildOptions {
    static func mock() -> XcodeBuildOptions {
        XcodeBuildOptions(
            sdk: .sim,
            config: "Debug",
            arch: "arm64",
            xcargs: [],
            resultBundlePath: nil
        )
    }
}
