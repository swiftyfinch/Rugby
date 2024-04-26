import Foundation
import ZIPFoundation

final class ZipDecompressor {
    private let fileManager = FileManager.default
}

extension ZipDecompressor: IDecompressor {
    func unarchiveFile(_ archiveFilePath: URL, destination: URL) throws {
        try fileManager.unzipItem(at: archiveFilePath, to: destination)
    }
}
