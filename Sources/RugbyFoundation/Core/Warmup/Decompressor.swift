import Foundation
import PLzmaSDK
import ZIPFoundation

// MARK: - Interface

protocol IDecompressor: AnyObject {
    func unzipFile(_ zipFilePath: URL, destination: URL) throws
}

// MARK: - Implementation

final class ZipDecompressor {
    private let fileManager = FileManager.default
}

extension ZipDecompressor: IDecompressor {
    func unzipFile(_ zipFilePath: URL, destination: URL) throws {
        try fileManager.unzipItem(at: zipFilePath, to: destination)
    }
}

final class SevenZipDecompressor {}

extension SevenZipDecompressor: IDecompressor {
    func unzipFile(_ zipFilePath: URL, destination: URL) throws {
        let decoder = try Decoder(stream: InStream(path: Path(zipFilePath.path())), fileType: .sevenZ)
        _ = try decoder.open()

        _ = try decoder.extract(to: Path(destination.path()))
    }
}
