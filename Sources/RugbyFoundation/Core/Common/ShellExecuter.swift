//
//  ShellExecuter.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 04.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import SwiftShell

// MARK: - Interface

/// The protocol describing a service to execute shell commands from Rugby.
public protocol IShellExecutor {
    /// Runs shell command and returns output and error.
    /// - Parameters:
    ///   - command: A commad to run.
    ///   - args: Command arguments.
    @discardableResult
    func shell(_ command: String, args: Any ...) -> (String?, Error?)

    /// Runs shell command and returns output.
    /// - Parameters:
    ///   - command: A commad to run.
    ///   - args: Command arguments.
    @discardableResult
    func throwingShell(_ command: String, args: Any ...) throws -> String?

    /// Runs shell command and prints output.
    /// - Parameters:
    ///   - command: A commad to run.
    ///   - args: Command arguments.
    func printShell(_ command: String, args: Any ...) throws
}

enum ShellError: LocalizedError {
    case common(String)
    case emptyShellVariable

    var errorDescription: String? {
        let output: String
        switch self {
        case .common(let stderror):
            output = stderror
        case .emptyShellVariable:
            output = "Shell variable is empty."
        }
        return output
    }
}

// MARK: - Implementation

final class ShellExecutor {
    private let processMonitor: IProcessMonitor

    init(processMonitor: IProcessMonitor) {
        self.processMonitor = processMonitor
    }
}

private extension ShellExecutor {

    func runAndPrint(_ command: String, args: Any ...) throws {
        let commandWithArgs = combine(command: command, args: args)
        let currentShell = try getCurrentShell()
        let asyncCommand = SwiftShell.runAsyncAndPrint(currentShell, "-c", commandWithArgs)
        processMonitor.addProcess(asyncCommand)
        do {
            try asyncCommand.finish()
        } catch {
            throw ShellError.common(commandWithArgs)
        }
    }

    func run(_ command: String, args: Any ...) -> (String?, Error?) {
        var stdout: String?
        var stderror: String?
        do {
            let commandWithArgs = combine(command: command, args: args)
            let currentShell = try getCurrentShell()
            let asyncCommand = SwiftShell.runAsync(currentShell, "-c", commandWithArgs)
            processMonitor.addProcess(asyncCommand)

            // Workaround: https://github.com/kareman/SwiftShell/issues/52
            let readOutStreams = DispatchWorkItem {
                stdout = asyncCommand.stdout.read()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let readErrorStreams = DispatchWorkItem {
                stderror = asyncCommand.stderror.read()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            DispatchQueue.global().async(execute: readOutStreams)
            DispatchQueue.global().async(execute: readErrorStreams)

            try asyncCommand.finish()
            readOutStreams.wait()
            readErrorStreams.wait()
            return (stdout, nil)
        } catch {
            let errorMessage: String
            if let stderror = stderror, !stderror.isEmpty {
                errorMessage = stderror
            } else {
                errorMessage = error.beautifulDescription
            }
            return (stdout, ShellError.common(errorMessage))
        }
    }
}

// MARK: - Utils

private extension ShellExecutor {

    func getCurrentShell() throws -> String {
        guard let shell = ProcessInfo.processInfo.environment["SHELL"] else {
            throw ShellError.emptyShellVariable
        }
        return shell
    }

    func combine(command: String, args: Any ...) -> String {
        let stringArgs = args.flatten().map(String.init(describing:))
        return command + " " + stringArgs.joined(separator: " ")
    }
}

// MARK: - IShellExecutor

extension ShellExecutor: IShellExecutor {
    @discardableResult
    public func shell(_ command: String, args: Any ...) -> (String?, Error?) {
        run(command, args: args)
    }

    @discardableResult
    public func throwingShell(_ command: String, args: Any ...) throws -> String? {
        let (output, error) = run(command, args: args)
        if let error = error { throw error }
        return output
    }

    public func printShell(_ command: String, args: Any ...) throws {
        try runAndPrint(command, args: args)
    }
}
