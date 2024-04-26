import Foundation

/// Binary archive file type.
public enum ArchiveType: String {
    case zip
    case sevenZip = "7z"

    /// File extension of the current archive type.
    public var fileExtension: String {
        rawValue
    }
}
