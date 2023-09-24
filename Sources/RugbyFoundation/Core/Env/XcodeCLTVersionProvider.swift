//
//  XcodeCLTVersionProvider.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 21.04.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

// MARK: - Interface

protocol IXcodeCLTVersionProvider {
    func version() throws -> (base: String, build: String?)
}

enum XcodeCLTVersionProviderError: LocalizedError {
    case unknownXcodeCLT

    public var errorDescription: String? {
        switch self {
        case .unknownXcodeCLT:
            return """
            \("Couldn't find Xcode CLT.".red)
            \("🚑 Check Xcode Preferences → Locations → Command Line Tools.".yellow)
            """
        }
    }
}

// MARK: - Implementation

final class XcodeCLTVersionProvider {
    private typealias Error = XcodeCLTVersionProviderError
    private let shellExecutor: IShellExecutor
    private var cachedXcodeVersion: (base: String, build: String?)?

    init(shellExecutor: IShellExecutor) {
        self.shellExecutor = shellExecutor
    }
}

// MARK: - IXcodeCLTVersionProvider

extension XcodeCLTVersionProvider: IXcodeCLTVersionProvider {
    func version() throws -> (base: String, build: String?) {
        if let cachedXcodeVersion { return cachedXcodeVersion }

        guard let output = try? shellExecutor.throwingShell("xcodebuild -version")?
            .components(separatedBy: .newlines)
            .filter({ !$0.isEmpty })
        else { throw XcodeCLTVersionProviderError.unknownXcodeCLT }

        let version: (base: String, build: String?)
        if output.count == 2 {
            version = (output[0], output[1])
        } else {
            version = (output.joined(separator: " - "), nil)
        }
        cachedXcodeVersion = version
        return version
    }
}
