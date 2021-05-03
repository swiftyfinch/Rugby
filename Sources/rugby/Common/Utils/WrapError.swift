//
//  WrapError.swift
//  
//
//  Created by Vyacheslav Khorkov on 27.02.2021.
//

import Foundation

enum WrappedError: Error, LocalizedError {
    case common(String)

    var errorDescription: String? {
        switch self {
        case .common(let description):
            return description
        }
    }

    static func wrap(playBell: Bool, _ block: () throws -> Void) throws {
        defer {
            if playBell { playBellSound() }
        }
        do {
            try block()
        } catch {
            throw WrappedError.common(error.localizedDescription.red)
        }
    }
}
