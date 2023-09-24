//
//  ParsableCommand+ToRunnable.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 02.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Foundation

// MARK: - Interface

private enum RunnableCommandError: LocalizedError {
    case unsupportedCommand(String)

    var errorDescription: String? {
        switch self {
        case let .unsupportedCommand(name):
            return #"Unsupported runnable command "\#(name)"."#
        }
    }
}

// MARK: - Implementation

extension ParsableCommand {
    func toRunnable() throws -> RunnableCommand {
        guard let runnableCommand = self as? RunnableCommand else {
            throw RunnableCommandError.unsupportedCommand(
                Self.configuration.commandName ?? "Unknown"
            )
        }
        return runnableCommand
    }
}
