//
//  Log.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import ArgumentParser
import Files
import Foundation
import ShellOut

private enum LogError: Error, LocalizedError {
    case cantFindLog

    var errorDescription: String? {
        switch self {
        case .cantFindLog: return "Can't find log."
        }
    }
}

struct Log: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "• Print last command log verbosely."
    )

    func run() throws {
        try WrappedError.wrap(playBell: false) {
            try wrappedRun()
        }
    }
}

extension Log {
    private func wrappedRun() throws {
        guard Folder.current.containsFile(at: .log) else { throw LogError.cantFindLog }
        try shellOut(to: "cat " + .log, outputHandle: FileHandle.standardOutput)
    }
}
