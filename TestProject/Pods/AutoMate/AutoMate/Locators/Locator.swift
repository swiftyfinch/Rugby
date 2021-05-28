//
//  Locator.swift
//  AutoMate
//
//  Created by Ewelina Cyło on 18/01/2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

/// Protocol for locators to enforce string representation.
///
/// Locators are nicer way to store and handle `XCUIElement` identifiers or labels.
/// Instead of using String literals as an identifier, the `Locator` object can be used.
///
/// **Example:**
///
/// ```swift
/// view.buttons[Locators.ok]
///
/// enum Locators: String, Locator {
///     case ok = "okButton"
/// }
/// ```
public protocol Locator {

    /// Element identifier.
    var identifier: String { get }
}

/// For any RawRepresentable thats rawValue is String type implementation is provided for free.
public extension Locator where Self: RawRepresentable, Self.RawValue == String {

    /// Element identifier.
    var identifier: String {
        return rawValue
    }
}
