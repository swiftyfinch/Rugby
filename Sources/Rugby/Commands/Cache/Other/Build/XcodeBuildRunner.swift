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
        if let errors = try? beautifyLog() {
            throw CacheError.buildFailed(errors)
        }
    }

    private func beautifyLog() throws -> [String] {
        var errors: [String] = []
        let log = try Folder.current.createFile(at: logPath)
        let logFormatter = LogFormatter { formattedLine, type in
            if type == .error { errors.append(formattedLine) }
            guard (type == .task && formattedLine.contains("Touching")) || type == .error else { return }
            try log.append(formattedLine + "\n")
        }

        let rawLog = try open(.rawBuildLog)
        for line in rawLog.lines() {
            try logFormatter.format(line: line)
        }
        try logFormatter.finish()
        return errors
    }
}
