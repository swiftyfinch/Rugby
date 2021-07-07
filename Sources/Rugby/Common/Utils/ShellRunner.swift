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
    func runAndPrint(_ command: String, args: Any ...) throws {
        let commandWithArgs = combine(command: command, args: args)
        let currentShell = try getCurrentShell()
        do {
            try SwiftShell.runAndPrint(currentShell, "-c", commandWithArgs)
        } catch {
            throw ShellError.common("🐚 " + commandWithArgs)
        }
    }

    func run(_ command: String, args: Any ...) throws -> String {
        let commandWithArgs = combine(command: command, args: args)
        let currentShell = try getCurrentShell()
        let output = SwiftShell.run(currentShell, "-c", commandWithArgs)
        if output.succeeded {
            return output.stdout
        } else {
            throw wrapError(output)
        }
    }
}

private extension ShellRunner {
    enum ShellError: Swift.Error, LocalizedError {
        case common(String)

        var errorDescription: String? {
            switch self {
            case .common(let stderror):
                return stderror
            }
        }
    }
}

final class ShellRunner {
    static let shared = ShellRunner()
    private var shell: String?

    private init() {}

    private func getCurrentShell() throws -> String {
        if let shell = shell { return shell }

        let output = SwiftShell.run(bash: "echo $SHELL")
        if output.succeeded {
            shell = output.stdout
            return output.stdout
        } else {
            throw wrapError(output)
        }
    }

    private func combine(command: String, args: Any ...) -> String {
        let stringArgs = args.flatten().map(String.init(describing:))
        return command + " " + stringArgs.joined(separator: " ")
    }

    private func wrapError(_ output: RunOutput) -> Error {
        ShellError.common(output.stdout.trimmingCharacters(in: .newlines))
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
