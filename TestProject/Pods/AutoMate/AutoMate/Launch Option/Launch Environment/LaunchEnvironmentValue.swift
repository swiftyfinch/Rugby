//
//  LaunchEnvironmentValue.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 26/01/2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

// MARK: - Launch Environment Value
/// Contains basic requirements for type that will be used as value for launch environment.
///
/// **Example:**
///
/// ```swift
/// public enum DataSource: String, LaunchEnvironmentValue {
///     case valid = "mock_valid"
///     case error = "mock_error"
/// }
public protocol LaunchEnvironmentValue {

    // MARK: Properties
    /// `String` which is passed with launch enviroment.
    var value: String { get }
}

/// Default implementation for `RawRepresentable<String>`
extension LaunchEnvironmentValue where Self: RawRepresentable, Self.RawValue == String {

    // MARK: Properties
    /// Returns `rawValue`.
    public var value: String {
        return rawValue
    }
}

// MARK: - Launch enviroment values
/// Represents launch environment value of type `Bool`.
///
/// - `true`: `true` value
/// - `false`: `false` value
public enum BooleanLaunchEnvironmentValue: String, ExpressibleByBooleanLiteral, LaunchEnvironmentValue, Equatable {

    /// Value of true, or 1.
    case `true`
    /// Value of false, or 0.
    case `false`

    // MARK: BooleanLiteralConvertible
    /// Initializes boolean launch environment with boolean literal type.
    ///
    /// - Parameter value: Literal to use during initialization.
    public init(booleanLiteral value: BooleanLiteralType) {
        self = value ? .true : .false
    }
}
// MARK: - Launch Environment Resource Value
/// Launch environment resource model containing informations required to point proper file containing resource data. 
/// Expects bundle and file name. If bundle name is `nil` main bundle will be searched.
///
/// **Example:**
///
/// ```swift
/// let resource = LaunchEnvironmentResourceValue(fileName: "monthly_events", bundleName: "Data")
public struct LaunchEnvironmentResourceValue: LaunchEnvironmentValue {

    // MARK: Properties
    /// Name of file in which resource is kept.
    public let file: String
    /// Name of bundle in which resource `file` is kept. `.none` is handled as main bundle.
    public let bundle: String?
    /// Implementation of `value` property from `LaunchEnvironmentValue` protocol.
    public var value: String {
        return "\(bundle ?? "nil"):\(file)"
    }

    // MARK: Initialization
    /// Initializes `LaunchEnvironmentResourceValue` that can be passed as value of types adapting `LaunchEnvironmentProtocol`.
    ///
    /// - Parameters:
    ///   - file: `String` name of file where resources are kept.
    ///   - bundle: `String` name of bundle that contains `file`, default `.none` is handled as main bundle.
    public init(fileName file: String, bundleName bundle: String? = nil) {
        self.file = file
        self.bundle = bundle
    }
}
