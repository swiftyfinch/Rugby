//
//  SystemAlert.swift
//  AutoMate
//
//  Created by Ewelina Cyło on 20/01/2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation
import XCTest
#if os(iOS)

// MARK: - System Messages helper protocol

/// Helper protocol used to reads localized messages from JSON files.
public protocol SystemMessages {
    /// Returns all localized texts from a JSON file.
    ///
    /// - Parameter json: JSON file name, without the `json` extension.
    /// - Returns: All localized tests read from the JSON.
    static func readMessages(from jsonFile: String) -> [String]
}

extension SystemMessages {
    /// Returns all localized texts from a JSON file.
    ///
    /// - Parameter json: JSON file name, without the `json` extension.
    /// - Returns: All localized tests read from the JSON.
    public static func readMessages(from jsonFile: String = String(describing: Self.self)) -> [String] {
        guard let url = Bundle.autoMate.url(forResource: jsonFile, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONDecoder().decode(Dictionary<String, [String]>.self, from: data) else {
                return []
        }
        return json.flatMap({ $0.value }).unique()
    }
}

// MARK: - System alert protocols
/// Protocol defining system alert allow element.
public protocol SystemAlertAllow: SystemMessages {
    /// Allow messages.
    static var allow: [String] { get }
    /// Allow element.
    var allowElement: XCUIElement { get }
}

/// Protocol defining system alert deny element.
public protocol SystemAlertDeny: SystemMessages {
    /// Deny messages.
    static var deny: [String] { get }
    /// Deny element.
    var denyElement: XCUIElement { get }
}

/// Protocol defining system alert ok element.
public protocol SystemAlertOk: SystemMessages {
    /// OK messages.
    static var ok: [String] { get }
    /// OK element.
    var okElement: XCUIElement { get }
}

/// Protocol defining system alert cancel element.
public protocol SystemAlertCancel: SystemMessages {
    /// Cancel messages.
    static var cancel: [String] { get }
    /// Cancel element.
    var cancelElement: XCUIElement { get }
}

/// Protocol defining system service request alert.
/// Provides essential definitions for system alerts giving the ability to handle them in the UI tests.
///
/// System alerts supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
/// Additional protocols, `SystemAlertAllow`, `SystemAlertDeny`, `SystemAlertOk` and `SystemAlertCancel` provides
/// definition and default implementation for handling buttons on the alert view.
///
/// - note:
/// `AutoMate` provides an implementation for several different system alerts.
/// Check the documentation for full list of supported system alerts.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Contacts") { (alert) -> Bool in
///     guard let alert = AddressBookAlert(element: alert) else {
///         XCTFail("Cannot create AddressBookAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
///     return true
/// }
///
/// mainPage.goToPermissionsPageMenu()
/// // Interruption won't happen without some kind of action.
/// app.tap()
/// removeUIInterruptionMonitor(token)
/// ```
///
/// - note:
/// Handlers should return `true` if they handled the UI, `false` if they did not.
public protocol SystemAlert: SystemMessages {
    /// Collection of messages possible to receive due to system service request.
    static var messages: [String] { get }
    /// Alert element.
    var alert: XCUIElement { get set }

    // MARK: Initializers
    /// Initialize system alert with interrupting element.
    ///
    /// - note:
    ///   Method returns `nil` if the `element` doesn't represent specified system alert.
    ///
    /// - Parameter element: Interrupting element containing system alert.
    init?(element: XCUIElement)
}

// MARK: - Default implementation
extension SystemAlertAllow where Self: SystemAlert {
    /// Allow element.
    public var allowElement: XCUIElement {
        guard let button = alert.buttons.elements(withLabelsMatching: type(of: self).allow).first else {
            preconditionFailure("Cannot find allow button.")
        }

        return button
    }
}

extension SystemAlertDeny where Self: SystemAlert {
    /// Deny element.
    public var denyElement: XCUIElement {
        guard let button = alert.buttons.elements(withLabelsMatching: type(of: self).deny).first else {
            preconditionFailure("Cannot find deny button.")
        }

        return button
    }
}

extension SystemAlertOk where Self: SystemAlert {
    /// OK element.
    public var okElement: XCUIElement {
        guard let button = alert.buttons.elements(withLabelsMatching: type(of: self).ok).first else {
            preconditionFailure("Cannot find ok button.")
        }

        return button
    }
}

extension SystemAlertCancel where Self: SystemAlert {
    /// Cancel element.
    public var cancelElement: XCUIElement {
        guard let button = alert.buttons.elements(withLabelsMatching: type(of: self).cancel).first else {
            preconditionFailure("Cannot find cancel button.")
        }

        return button
    }
}
#endif
