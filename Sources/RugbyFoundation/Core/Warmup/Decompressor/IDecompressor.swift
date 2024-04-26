import Foundation

protocol IDecompressor: AnyObject {
    func unarchiveFile(_ archiveFilePath: URL, destination: URL) throws
}
