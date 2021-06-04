//
//  HistoryWriter.swift
//  
//
//  Created by Vyacheslav Khorkov on 02.06.2021.
//

import Files
import Foundation

struct HistoryWriter {
    func save() throws {
        let historyFolder = try Folder.current.createSubfolderIfNeeded(at: .history)
        let historyCount = historyFolder.subfolders.count()
        if historyCount >= .maxHistoryCount {
            let sortedFolders = historyFolder.subfolders.sorted { $0.name < $1.name }
            try sortedFolders.prefix(historyCount - .maxHistoryCount + 1).forEach { try $0.delete() }
        }

        let newRecordFolder = try historyFolder.createSubfolder(at: generateFolderName())
        let filesForCopy: [String] = [.cacheFile, .log, .buildLog, .plans]
        try filesForCopy.forEach {
            let file = try? Folder.current.file(at: $0)
            try file?.copy(to: newRecordFolder)
        }
    }

    private func generateFolderName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = .dateFormat
        return dateFormatter.string(from: Date())
    }
}

private extension Int {
    static let maxHistoryCount = 10
}

private extension String {
    static let dateFormat = "dd.MM.yyyy'T'HH.mm.ss"
}
