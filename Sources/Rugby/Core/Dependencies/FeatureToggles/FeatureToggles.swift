import Foundation
import RugbyFoundation

final class FeatureToggles {
    // swiftlint:disable identifier_name
    private let RUGBY_KEEP_HASH_YAMLS = "RUGBY_KEEP_HASH_YAMLS"
    private let RUGBY_PRINT_MISSING_BINARIES = "RUGBY_PRINT_MISSING_BINARIES"
    // swiftlint:enable identifier_name
}

extension FeatureToggles: IFeatureToggles {
    var all: [String: String] {
        [
            RUGBY_KEEP_HASH_YAMLS: keepHashYamls.yesNo,
            RUGBY_PRINT_MISSING_BINARIES: printMissingBinaries.yesNo
        ]
    }

    var keepHashYamls: Bool {
        ProcessInfo.processInfo.environment[RUGBY_KEEP_HASH_YAMLS].isEnabled
    }

    var printMissingBinaries: Bool {
        ProcessInfo.processInfo.environment[RUGBY_PRINT_MISSING_BINARIES].isEnabled
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
