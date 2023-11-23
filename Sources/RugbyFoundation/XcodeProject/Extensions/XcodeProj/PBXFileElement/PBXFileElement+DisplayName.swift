import Foundation
import XcodeProj

extension PBXFileElement {
    var displayName: String? {
        name ?? path.map(URL.init(fileURLWithPath:))?.lastPathComponent
    }
}
