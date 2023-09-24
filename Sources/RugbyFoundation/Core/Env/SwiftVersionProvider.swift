//
//  SwiftVersionProvider.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 30.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

// MARK: - Interface

/// The protocol describing a service providing the current Swift version.
public protocol ISwiftVersionProvider: Actor {
    /// Returns the current Swift version.
    func swiftVersion() throws -> String
}

enum SwiftVersionProviderError: LocalizedError {
    case parsingFailed

    var errorDescription: String? {
        let output: String
        switch self {
        case .parsingFailed:
            output = "Couldn't parse Swift version."
        }
        return output
    }
}

// MARK: - Implementation

final actor SwiftVersionProvider {
    private typealias Error = SwiftVersionProviderError

    private let shellExecutor: IShellExecutor
    private var cachedSwiftVersion: String?

    init(shellExecutor: IShellExecutor) {
        self.shellExecutor = shellExecutor
    }
}

// MARK: - ISwiftVersionProvider

extension SwiftVersionProvider: ISwiftVersionProvider {
    public func swiftVersion() throws -> String {
        if let cachedSwiftVersion = cachedSwiftVersion { return cachedSwiftVersion }
        let output = try shellExecutor.throwingShell("swift --version")
        let regex = #"(?<=Apple Swift version )(\d+\.\d+(?:\.\d)?)"#
        guard let version = try output?.groups(regex: regex).first else { throw Error.parsingFailed }
        cachedSwiftVersion = version
        return version
    }
}
