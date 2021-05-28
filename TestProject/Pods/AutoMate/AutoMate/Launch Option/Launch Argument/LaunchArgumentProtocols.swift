//
//  LaunchArgumentProtocols.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 17/01/2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

// MARK: - LaunchArgument protocol
/// Any type that implements this protocol can be used to configure application
/// with TestLauncher. Specifically it represents launch argument option so it requires to provide argument `key`.
/// Type conforming to this protocol should override default implementation of `launchArguments`.
///
/// Custom launch arguments can implement one of two additional protocols:
///
/// - `LaunchArgumentWithSingleValue`
/// - `LaunchArgumentWithMultipleValues`
///
/// For more info about launch arguments variables check:
/// [Xcode Help](http://help.apple.com/xcode/mac/8.0/#/dev3ec8a1cb4).
public protocol LaunchArgument: LaunchOption {

    /// String representation of the argument.
    var key: String { get }
}

// MARK: Default implementation
public extension LaunchArgument {

    /// Unique value to use when comparing with other launch options.
    var uniqueIdentifier: String {
        return key
    }

    /// Launch environment variables provided by this option.
    ///
    /// Launch argument does not have to provide launch environments.
    var launchEnvironments: [String: String]? {
        return nil
    }
}

// MARK: - LaunchArgumentWithSingleValue protocol
/// Protocol that should be implemented by types representing launch argument that accepts single
/// argument value.
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
/// **Usage:**
///
/// ```swift
/// let app = XCUIApplication()
/// TestLauncher(options: [
///     Server.testing
/// ]).configure(app).launch()
/// ```
///
/// **Handling:**
///
/// ```swift
/// let serverAddress = UserDefaults.standard.string(forKey: "Server")
/// ```
public protocol LaunchArgumentWithSingleValue: LaunchArgument {
    /// Value of the launch argument.
    var value: LaunchArgumentValue { get }
}

extension LaunchArgumentWithSingleValue {

    // MARK: Option
    /// Default formatted representation of the launch argument.
    public var launchArguments: [String]? {
        return ["-\(key)", value.value]
    }
}

extension LaunchArgumentWithSingleValue where Self: LaunchArgumentValue {
    /// Default formatted representation of the launch argument value.
    public var value: LaunchArgumentValue {
        return self
    }
}

// MARK: - LaunchArgumentWithMultipleValues protocol
/// Protocol that should be implemented by types representing launch argument that accepts collection
/// of values.
///
/// **Example:**
///
/// ```swift
/// struct MagicNumbers: LaunchArgumentWithMultipleValues {
///     struct Number: LaunchArgumentValue {
///         var value: String {
///             return "\(number)"
///         }
///         let number: Int
///     }
/// 
///     let key = "MagicNumbers"
///     let values: [Number]
///     public init(_ values: [Number]) {
///         self.values = values
///     }
/// }
/// ```
///
/// **Usage:**
///
/// ```swift
/// let app = XCUIApplication()
/// TestLauncher(options: [
///     MagicNumbers([.init(number: 5), .init(number: 7)])
/// ]).configure(app).launch()
/// ```
///
/// **Handling:**
///
/// ```swift
/// let magicNumbers = UserDefaults.standard.stringArray(forKey: "MagicNumbers")
/// ```
public protocol LaunchArgumentWithMultipleValues: LaunchArgument, ExpressibleByArrayLiteral {
    /// `LaunchArgumentValue` holds a set of requirements for the values a launch arguments can hold.
    associatedtype Value: LaunchArgumentValue

    /// Array of values associated to the launch argument.
    var values: [Value] { get }

    /// Initializes object with given array of valeus.
    init(_ values: [Value])

    // MARK: ArrayLiteralConvertible
    /// An argument that can hold multiple values uses an array as a storage.
    /// For convienence client can initialize it with and array literal
    /// containing element's of type `Value`.
    associatedtype Element = Value
}

extension LaunchArgumentWithMultipleValues {

    // MARK: Option
    /// Default formatted representation of the launch argument.
    public var launchArguments: [String]? {
        return ["-\(key)", values.launchArgument]
    }

    /// Initializes launch argument with a list.
    ///
    /// - parameter elements: list of values.
    public init(arrayLiteral elements: Value ...) {
        self.init(elements)
    }
}
