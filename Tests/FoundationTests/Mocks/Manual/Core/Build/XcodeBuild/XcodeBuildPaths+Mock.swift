@testable import RugbyFoundation

extension XcodeBuildPaths {
    static func mock() -> XcodeBuildPaths {
        XcodeBuildPaths(
            project: "test_project",
            symroot: "test_symroot",
            rawLog: "test_rawLog",
            beautifiedLog: "test_beautifiedLog"
        )
    }
}
