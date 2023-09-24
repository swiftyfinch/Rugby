//
//  LogsRotator.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 18.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Fish
import Foundation

/// The service to keep only latest logs.
public final class LogsRotator {
    private let logsPath: String

    private let maxLogs = 10
    private var cachedLogsRecord: IFolder?

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy'T'HH.mm.ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()

    /// Initializer.
    /// - Parameter logsPath: The path to the logs folder.
    public init(logsPath: String) {
        self.logsPath = logsPath
    }

    /// Creates the new log file folder per a session and returns it.
    public func currentLogFolder() throws -> IFolder {
        if let logsRecord = cachedLogsRecord { return logsRecord }

        let logsFolder = try Folder.create(at: logsPath)
        let sortedFolders = try sortedLogFolders()
        let logsCount = sortedFolders.count
        if logsCount >= maxLogs {
            try sortedFolders.prefix(logsCount - maxLogs + 1).forEach { folder in
                try folder.delete()
            }
        }

        let logsFolderName = dateFormatter.string(from: Date())
        let logsRecord = try logsFolder.createFolder(named: logsFolderName)
        cachedLogsRecord = logsRecord
        return logsRecord
    }

    /// Returns the latest log folder.
    public func previousLogFolder() throws -> IFolder? {
        try sortedLogFolders().last
    }

    // MARK: - Private

    private func sortedLogFolders() throws -> [IFolder] {
        let logsFolder = try Folder.create(at: logsPath)
        let logsSubfolders = try logsFolder.folders()
        return logsSubfolders.sorted { lhs, rhs in
            guard let lhsDate = dateFormatter.date(from: lhs.name),
                  let rhsDate = dateFormatter.date(from: rhs.name)
            else { return false } // Silent error here, this is not so important for the main functionality.
            return lhsDate.timeIntervalSinceReferenceDate < rhsDate.timeIntervalSinceReferenceDate
        }
    }
}
