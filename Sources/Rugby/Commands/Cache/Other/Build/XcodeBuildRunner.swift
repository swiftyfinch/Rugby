//
//  XcodeBuildRunner.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.06.2021.
//

import Files

final class XcodeBuildRunner {
    let logPath: String

    init(logPath: String) {
        self.logPath = logPath
    }

    func run(_ command: String, args: Any ...) throws {
        let log = try Folder.current.createFile(at: logPath)
        let logFormatter = LogFormatter { formattedLine in
            try log.append(formattedLine + "\n")
        }

        let command = try ShellRunner.shared.runAsync(command, args: args)
        for line in command.stdout.lines() {
            try logFormatter.format(line: line)
        }
        try logFormatter.finish()
    }
}
