//
//  LaunchEnvironments.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 20/01/2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

// MARK: - Launch Environments
/// Most basic and generic structure to pass `(key: value)` pairs through `TestLauncher`.
///
/// **Example:**
///
/// ```swift
/// let launchEnvironmentDictionary: LaunchEnvironments = ["CORPORATION_KEY": "PGS", "PROJECT_KEY": "AutoMate"]
public struct LaunchEnvironments: LaunchEnvironmentProtocol, ExpressibleByDictionaryLiteral {

    // MARK: Typealiases
    public typealias Key = String
    public typealias Value = String

    // MARK: Properties
    /// Data passed as value for environment variable
    public let data: [String: String]

    /// Unique value to use when comparing with other launch options.
    public var uniqueIdentifier: String {
        return "\(data.reduce(0) { $0 ^ $1.0.hashValue })"
    }

    /// Launch environment variables provided by this option.
    public var launchEnvironments: [String: String]? {
        return data
    }

    // MARK: Initialization
    /// Initialize structure with dictionary of keys and values.
    ///
    /// - Parameter elements: Dictionary of keys and values.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        data = Dictionary(elements: elements)
    }
}

// MARK: - Launch Environment
/// Simple implementation of `LaunchEnvironment` that wraps single `(key: value)` pair for `TestLauncher`.
///
/// **Example:**
///
/// ```swift
/// let launchEnvironmentOption = LaunchEnvironment(key: "MADE_WITH_LOVE_BY", value: "PGS")
public struct LaunchEnvironment: LaunchEnvironmentProtocol {

    // MARK: Typealiases
    public typealias Value = String

    // MARK: Properties
    /// Launch environment key.
    public let key: String
    /// Launch environment value.
    public let value: String

    /// Launch environment variables provided by this option.
    public var launchEnvironments: [String: String]? {
        return [key: value]
    }

    /// Unique value to use when comparing with other launch options.
    public var uniqueIdentifier: String {
        return key
    }

    // MARK: - Initialization
    /// Initialize structure with `key` and `value`.
    ///
    /// - Parameters:
    ///   - key: Launch environment key.
    ///   - value: Launch environment value.
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
