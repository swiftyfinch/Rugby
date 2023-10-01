import Foundation
import RugbyFoundation

final class FeatureToggles: IFeatureToggles {
    var keepHashYamls: Bool {
        ProcessInfo.processInfo.environment["RUGBY_KEEP_HASH_YAMLS"] != nil
    }

    var printMissingBinaries: Bool {
        ProcessInfo.processInfo.environment["RUGBY_PRINT_MISSING_BINARIES"] != nil
    }
}
