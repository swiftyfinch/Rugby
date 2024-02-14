import Foundation
import ZIPFoundation

// MARK: - Interface

protocol IDecompressor: AnyObject {
    func unzipFile(_ zipFilePath: URL, destination: URL) throws
}

// MARK: - Implementation

final class Decompressor {
    private let fileManager = FileManager.default
}

extension Decompressor: IDecompressor {
    func unzipFile(_ zipFilePath: URL, destination: URL) throws {
        try fileManager.unzipItem(at: zipFilePath, to: destination)
    }
}
