//
//  XcodeBuildRunner.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.06.2021.
//

import Files
import SwiftShell

final class XcodeBuildRunner {
    let rawLogPath: String
    let logPath: String

    init(rawLogPath: String, logPath: String) {
        self.rawLogPath = rawLogPath
        self.logPath = logPath
    }

    func run(_ command: String, args: Any ...) throws {
        _ = try? shell(command, args: args)
        try? beautifyLog()
    }

    private func beautifyLog() throws {
        let log = try Folder.current.createFile(at: logPath)
        let logFormatter = LogFormatter { formattedLine in
            try log.append(formattedLine + "\n")
        }

        let rawLog = try open(.rawBuildLog)
        for line in rawLog.lines() {
            try logFormatter.format(line: line)
        }
        try logFormatter.finish()
    }
}
