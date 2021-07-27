//
//  WrapError.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 27.02.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

enum WrappedError: Error, LocalizedError {
    case common(String)

    var errorDescription: String? {
        switch self {
        case .common(let description):
            // Need to clear color because in _errorLabel we don't do that
            return """
            \u{1B}[0m\(description)
            🚑 \("Call doctor for more help:".yellow) rugby doctor
            """
        }
    }

    static func wrap(playBell: Bool, _ block: () throws -> Void) throws {
        let begin = ProcessInfo.processInfo.systemUptime
        defer {
            let time = ProcessInfo.processInfo.systemUptime - begin
            if playBell && time > 1 { playBellSound() }
        }
        do {
            try block()
        } catch {
            throw WrappedError.common(error.localizedDescription.red)
        }
    }
}
