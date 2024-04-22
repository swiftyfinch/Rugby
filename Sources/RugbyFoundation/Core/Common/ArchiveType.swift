import Foundation

public enum ArchiveType: String, CustomStringConvertible {
    case zip
    case sevenZip = "7z"
    
    public var description: String {
        switch self {
        case .zip:
            return "zip"
        case .sevenZip:
            return "7z"
        }
    }
}
