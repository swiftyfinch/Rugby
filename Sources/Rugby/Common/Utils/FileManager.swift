//
//  FileManager.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 22.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Foundation

extension Folder {
    /// In bytes
    func size() -> Int? {
        FileManager.default.directorySize(url)
    }
}

private extension FileManager {
    /// In bytes
    func directorySize(_ url: URL) -> Int? {
        guard let files = enumerator(at: url, includingPropertiesForKeys: .fileSizeKeys) else { return nil }
        var bytes = 0
        for case let url as URL in files {
            bytes += url.fileSize ?? 0
        }
        return bytes
    }
}

private extension URL {
    /// In bytes
    var fileSize: Int? {
        let values = try? resourceValues(forKeys: .fileSizeKeys)
        return values?.totalFileAllocatedSize ?? values?.fileAllocatedSize
    }
}

private extension Set where Element == URLResourceKey {
    static let fileSizeKeys: Self = [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey]
}
private extension Array where Element == URLResourceKey {
    static let fileSizeKeys: Self = [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey]
}
