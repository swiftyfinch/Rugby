//
//  XcodeBuildRunner.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.06.2021.
//

import Files

final class XcodeBuildRunner {
    let rawLogPath: String
    let logPath: String

    init(rawLogPath: String, logPath: String) {
        self.rawLogPath = rawLogPath
        self.logPath = logPath
    }

    func run(_ command: String, args: Any ...) throws {
        let log = try Folder.current.createFile(at: logPath)
        let logFormatter = LogFormatter { formattedLine in
            try log.append(formattedLine + "\n")
        }

        let rawLog = try Folder.current.createFile(at: rawLogPath)
        let command = try ShellRunner.shared.runAsync(command, args: args)
        for line in command.stdout.lines() {
            try rawLog.append(line + "\n")
            try logFormatter.format(line: line)
        }
        try logFormatter.finish()
    }
}
