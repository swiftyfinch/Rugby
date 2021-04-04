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

enum LogError: Error, LocalizedError {
    case cantFindLog

    var errorDescription: String? {
        switch self {
        case .cantFindLog: return "Can't find log."
        }
    }
}

struct Log: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        abstract: "Print last command log verbosely."
    )

    func run() throws {
        guard Folder.current.containsFile(at: .log) else { throw LogError.cantFindLog }
        try shellOut(to: "cat " + .log, outputHandle: FileHandle.standardOutput)
    }
}
