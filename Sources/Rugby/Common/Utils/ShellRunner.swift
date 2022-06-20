//
//  ShellRunner.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 08.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import SwiftShell

@discardableResult
func shell(_ command: String, args: Any ...) throws -> String {
    try ShellRunner.shared.run(command, args: args)
}

func printShell(_ command: String, args: Any ...) throws {
    try ShellRunner.shared.runAndPrint(command, args: args)
}

// MARK: - Implementation

extension ShellRunner {
    fileprivate func runAndPrint(_ command: String, args: Any ...) throws {
        let commandWithArgs = combine(command: command, args: args)
        let currentShell = try getCurrentShell()
        let asyncCommand = SwiftShell.runAsyncAndPrint(currentShell, "-c", commandWithArgs)
        ProcessMonitor.shared.addProcess(asyncCommand)
        do {
            try asyncCommand.finish()
        } catch {
            throw ShellError.common("🐚 " + commandWithArgs)
        }
    }

    fileprivate func run(_ command: String, args: Any ...) throws -> String {
        let commandWithArgs = combine(command: command, args: args)
        let currentShell = try getCurrentShell()
        let asyncCommand = SwiftShell.runAsync(currentShell, "-c", commandWithArgs)
        ProcessMonitor.shared.addProcess(asyncCommand)

        var stderror: String?
        do {
            // Workaround: https://github.com/kareman/SwiftShell/issues/52
            var stdout: String?
            let readOutStreams = DispatchWorkItem {
                stdout = asyncCommand.stdout.read()
            }
            let readErrorStreams = DispatchWorkItem {
                stderror = asyncCommand.stderror.read()
            }
            DispatchQueue.global().async(execute: readOutStreams)
            DispatchQueue.global().async(execute: readErrorStreams)

            try asyncCommand.finish()
            readOutStreams.wait()
            readErrorStreams.wait()
            return stdout ?? ""
        } catch {
            throw ShellError.common(stderror ?? error.beautifulDescription)
        }
    }
}

private extension ShellRunner {
    enum ShellError: Swift.Error, LocalizedError {
        case common(String)
        case emptyShellVariable

        var errorDescription: String? {
            switch self {
            case .common(let stderror):
                return stderror
            case .emptyShellVariable:
                return "Shell variable is empty."
            }
        }
    }
}

final class ShellRunner {
    static let shared = ShellRunner()

    private init() {}

    private func getCurrentShell() throws -> String {
        guard let shell = ProcessInfo.processInfo.environment["SHELL"] else {
            throw ShellError.emptyShellVariable
        }
        return shell
    }

    private func combine(command: String, args: Any ...) -> String {
        let stringArgs = args.flatten().map(String.init(describing:))
        return command + " " + stringArgs.joined(separator: " ")
    }

    // MARK: - Wrap Errors

    private func wrapError(_ output: RunOutput) -> Error {
        ShellError.common(output.stdout.cleanUpOutput())
    }

    private func wrapError(_ command: AsyncCommand) -> Error {
        ShellError.common(command.stderror.read().cleanUpOutput())
    }
}

private extension String {
    // This method from SwiftShell
    func cleanUpOutput() -> String {
        let afterFirstNewline = firstIndex(of: "\n").map(index(after:))
        return (afterFirstNewline == nil || afterFirstNewline == endIndex)
            ? trimmingCharacters(in: .whitespacesAndNewlines)
            : self
    }
}

private extension Array where Element: Any {
    func flatten() -> [Any] {
        flatMap { x -> [Any] in
            if let anyarray = x as? [Any] {
                return anyarray.map { $0 as Any }.flatten()
            }
            return [x]
        }
    }
}
