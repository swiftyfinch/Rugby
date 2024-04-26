import Foundation
import PLzmaSDK

final class SevenZipDecompressor {}

extension SevenZipDecompressor: IDecompressor {
    func unarchiveFile(_ archiveFilePath: URL, destination: URL) throws {
        let archiveFilePath = try Path(archiveFilePath.path())
        let stream = try InStream(path: archiveFilePath)
        let decoder = try Decoder(stream: stream, fileType: .sevenZ)
        if try decoder.open() {
            let destinationPath = try Path(destination.path())
            _ = try decoder.extract(to: destinationPath)
        }
    }
}
