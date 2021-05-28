//
//  String.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 26/01/2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

/// Default implementation LaunchEnvironmentValue for string.
/// Usage example:
///
/// ```swift
/// public struct StringLaunchEnvironment: LaunchEnvironmentProtocol {
///
///     public typealias Value = String
///     public let value: Value
///     public var launchEnvironments: [String : String]? {
///         return [uniqueIdentifier: value]
///     }
///     public init(value: Value) {
///         self.value = value
///     }
/// }
/// ```
/// - note:
/// `internal` initializer would be generated automatically but it would not fulfill requirement of `public` protocol.
extension String: LaunchEnvironmentValue {

    // MARK: Properties
    /// `String` which is passed with launch enviroment.
    public var value: String {
        return self
    }
}
