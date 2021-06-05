//
//  XcodeBuildRunner.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.06.2021.
//

import Files
import Foundation
import SwiftShell

struct XcodeBuildRunner {
    let rawLogPath: String
    let logPath: String
    private let shellRunner = ShellRunner.shared

    func run(_ command: String, args: Any ...) throws {
        let rawLog = try Folder.current.createFile(at: rawLogPath)
        let command = try shellRunner.runAsync(command, args: args)

        var error: Error?
        let group = DispatchGroup()
        command.stdout.onOutput { handler in
            for line in handler.lines() {
                do {
                    try rawLog.append(line + "\n")
                } catch let fileError {
                    error = fileError
                    command.interrupt()
                }
            }
        }

        group.enter()
        command.onCompletion { _ in
            group.leave()
        }

        group.wait()
        if let error = error { throw error }
    }
}
