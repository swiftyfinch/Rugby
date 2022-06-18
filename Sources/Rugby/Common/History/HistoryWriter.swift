//
//  HistoryWriter.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 02.06.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files
import Foundation

struct HistoryWriter {
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = .dateFormat
        return dateFormatter
    }()

    func save() throws {
        let historyFolder = try Folder.current.createSubfolderIfNeeded(at: .history)
        let historyCount = historyFolder.subfolders.count()
        if historyCount >= .maxHistoryCount {
            let sortedFolders = historyFolder.subfolders.sorted {
                guard let lhsDate = dateFormatter.date(from: $0.name),
                      let rhsDate = dateFormatter.date(from: $1.name)
                else { return false } // Silent error here, this is not so important for the main functionality.
                return lhsDate.timeIntervalSinceReferenceDate < rhsDate.timeIntervalSinceReferenceDate
            }
            try sortedFolders.prefix(historyCount - .maxHistoryCount + 1).forEach { try $0.delete() }
        }

        let newRecordFolder = try historyFolder.createSubfolder(at: generateFolderName())
        let filesForCopy: [String] = [.cacheFile, .log, .rawBuildLog, .buildLog, .plans]
        try filesForCopy.forEach {
            let file = try? Folder.current.file(at: $0)
            try file?.copy(to: newRecordFolder)
        }
    }

    private func generateFolderName() -> String {
        dateFormatter.string(from: Date())
    }
}

private extension Int {
    static let maxHistoryCount = 10
}

private extension String {
    static let dateFormat = "dd.MM.yyyy'T'HH.mm.ss"
}
