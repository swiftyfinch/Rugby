//
//  ArchitectureProvider.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 13.04.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

// MARK: - Interface

/// The protocol describing a service providing the current CPU architecture.
public protocol IArchitectureProvider {
    /// Returns the current CPU architecture.
    func architecture() -> Architecture
}

/// The enumeration of available architectures.
public enum Architecture: String {
    case auto, x86_64, arm64 // swiftlint:disable:this identifier_name
}

// MARK: - Implementation

final class ArchitectureProvider {
    private let shellExecutor: IShellExecutor
    private var cachedArchitecture: Architecture?

    init(shellExecutor: IShellExecutor) {
        self.shellExecutor = shellExecutor
    }
}

// MARK: - IArchitectureProvider

extension ArchitectureProvider: IArchitectureProvider {
    public func architecture() -> Architecture {
        if let cachedArchitecture { return cachedArchitecture }

        let architecture: Architecture
        switch try? shellExecutor.throwingShell("sysctl -n machdep.cpu.brand_string") {
        case let value? where value.contains("Apple"):
            architecture = .arm64
        default:
            architecture = .x86_64
        }
        cachedArchitecture = architecture
        return architecture
    }
}
