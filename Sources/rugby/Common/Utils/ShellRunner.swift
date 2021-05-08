//
//  ShellRunner.swift
//  
//
//  Created by Vyacheslav Khorkov on 08.05.2021.
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
        let currentShell = try getCurrentShell()
        try SwiftShell.runAndPrint(currentShell, "-c", command, args)
    }

    func run(_ command: String, args: Any ...) throws -> String {
        let currentShell = try getCurrentShell()
        return SwiftShell.run(currentShell, "-c", command, args).stdout
    }
}

extension ShellRunner {
    enum Error: Swift.Error, LocalizedError {
        case unknown(String)

        var errorDescription: String? {
            switch self {
            case .unknown(let stderror):
                return stderror
            }
        }
    }
}

private final class ShellRunner {
    static let shared = ShellRunner()
    private var shell: String?

    private init() {}

    private func getCurrentShell() throws -> String {
        if let shell = shell { return shell }

        let output = SwiftShell.run(bash: "echo $SHELL")
        if output.succeeded {
            return output.stdout
        } else if let error = output.error {
            throw error
        } else {
            throw Error.unknown(output.stderror)
        }
    }
}
