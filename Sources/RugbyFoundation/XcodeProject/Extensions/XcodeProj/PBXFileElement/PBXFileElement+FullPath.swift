import XcodeProj

extension PBXFileElement {
    var fullPath: String? {
        try? fullPath(sourceRoot: "Pods")?.string
    }
}
