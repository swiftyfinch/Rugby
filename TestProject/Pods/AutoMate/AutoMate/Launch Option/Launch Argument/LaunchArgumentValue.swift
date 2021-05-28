//
//  LaunchArgumentValue.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 17/01/2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

// MARK: - LaunchArgumentValue protocol
/// Represents single portion of data to be passed through launch argument.
///
/// Objects implementing `LaunchArgumentValue` are used
/// by the `LaunchArgumentWithSingleValue` and
/// `LaunchArgumentWithMultipleValues`.
///
/// `AutoMate` provides default implementation for `RawRepresentable` 
/// objects and `Bool` values (check `BooleanLaunchArgumentValue`).
///
/// **Example:**
///
/// ```swift
/// enum Server: String, LaunchArgumentWithSingleValue, LaunchArgumentValue {
///     case testing, production
/// 
///     var key: String {
///         return "Server"
///     }
/// }
/// ```
///
/// ```swift
/// struct Number: LaunchArgumentValue {
///     var value: String {
///         return "\(number)"
///     }
///     let number: Int
/// }
/// ```
public protocol LaunchArgumentValue {

    /// String representation of the value.
    var value: String { get }
}

public extension LaunchArgumentValue where Self: RawRepresentable {
    /// Default string representation for raw representable launch arguments.
    var value: String {
        return "\"\(rawValue)\""
    }
}

// MARK: - Launch argument values
/// Represents launch argument value of type Bool.
public enum BooleanLaunchArgumentValue: Int, ExpressibleByBooleanLiteral, LaunchArgumentValue, Equatable {
    /// Value of true, or 1.
    case `true` = 1
    /// Value of false, or 0.
    case `false` = 0

    // MARK: BooleanLiteralConvertible
    /**
     Initializes boolean launch argument with boolean literal type.
     - parameter value: Literal to use during initialization.
     */
    public init(booleanLiteral value: BooleanLiteralType) {
        self = value ? .true : .false
    }
}
