import Foundation
import Zip

// MARK: - Interface

protocol IDecompressor: AnyObject {
    func unzipFile(_ zipFilePath: URL, destination: URL) throws
}

// MARK: - Implementation

final class Decompressor {}

extension Decompressor: IDecompressor {
    func unzipFile(_ zipFilePath: URL, destination: URL) throws {
        Zip.addCustomFileExtension(zipFilePath.pathExtension)
        try Zip.unzipFile(zipFilePath, destination: destination, overwrite: true, password: nil)
    }
}
