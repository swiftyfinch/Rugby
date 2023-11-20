import Fish
import Foundation
import RugbyFoundation

final class Environment {
    // swiftlint:disable identifier_name
    private let RUGBY_KEEP_HASH_YAMLS = "RUGBY_KEEP_HASH_YAMLS"
    private let RUGBY_PRINT_MISSING_BINARIES = "RUGBY_PRINT_MISSING_BINARIES"
    private let RUGBY_SHARED_DIR_ROOT = "RUGBY_SHARED_DIR_ROOT"
    // swiftlint:enable identifier_name
}

extension Environment: IEnvironment {
    var all: [String: String] {
        [
            RUGBY_KEEP_HASH_YAMLS: keepHashYamls.yesNo,
            RUGBY_PRINT_MISSING_BINARIES: printMissingBinaries.yesNo,
            RUGBY_SHARED_DIR_ROOT: sharedFolderParentPath
        ]
    }

    var keepHashYamls: Bool {
        ProcessInfo.processInfo.environment[RUGBY_KEEP_HASH_YAMLS].isEnabled
    }

    var printMissingBinaries: Bool {
        ProcessInfo.processInfo.environment[RUGBY_PRINT_MISSING_BINARIES].isEnabled
    }

    var sharedFolderParentPath: String {
        ProcessInfo.processInfo.environment[RUGBY_SHARED_DIR_ROOT] ?? Folder.home.path
    }
}

private extension String? {
    var isEnabled: Bool {
        switch self {
        case "YES", "true", "1":
            return true
        default:
            return false
        }
    }
}

private extension Bool {
    var yesNo: String { self ? "YES" : "NO" }
}
