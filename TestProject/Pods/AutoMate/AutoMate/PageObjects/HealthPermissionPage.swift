//
//  HealthPermissionPage.swift
//  AutoMate
//
//  Created by Bartosz Janda on 15.02.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation
import XCTest

// MARK: - HealthPermissionPage
#if os(iOS)
/// Page object representing HealthKit permission view.
///
/// It can only allow to tap on buttons:
///
/// - Allow
/// - Deny
/// - Turn on all permissions
/// - Turn off all permissions
///
/// **Example:**
///
/// ```swift
/// let healthPermissionPage = HealthPermissionPage(in: self.app)
/// healthPermissionPage.turnOnAllElement.tap()
/// healthPermissionPage.allowElement.tap()
/// ```
open class HealthPermissionPage: BaseAppPage, HealthAlertAllow, HealthAlertDeny, HealthAlertTurnOnAll, HealthAlertTurnOffAll {

    // MARK: Elements
    /// Navigation bar on HealthKit permission view.
    ///
    /// This bar can be used to identify if the permission view is visible.
    open var healthAccessElement: XCUIElement {
        return view.navigationBars[Locators.healthAccess]
    }
}

// MARK: - IdentifiableByElement
extension HealthPermissionPage: IdentifiableByElement {

    /// Identifing `XCUIElement`.
    ///
    /// The `healthAccessElement` is used.
    public var identifingElement: XCUIElement {
        return healthAccessElement
    }
}

// MARK: - Locators
public extension HealthPermissionPage {

    /// Locators used in the HealthKit permission view.
    ///
    /// - `healthAccess`: Navigation bar identifier.
    enum Locators: String, Locator {
        /// Navigation bar identifier.
        case healthAccess = "Health Access"
    }
}

// MARK: - Health protocols
/// Protocol defining health alert allow element and messages.
public protocol HealthAlertAllow: SystemMessages {
    /// Allow messages.
    static var allow: [String] { get }
    /// Allow element.
    var allowElement: XCUIElement { get }
}

/// Protocol defining health alert deny element and messages.
public protocol HealthAlertDeny: SystemMessages {
    /// Deny messages.
    static var deny: [String] { get }
    /// Deny element.
    var denyElement: XCUIElement { get }
}

/// Protocol defining health alert "turn on all" element and messages.
public protocol HealthAlertTurnOnAll: SystemMessages {
    /// Turn On All messages.
    static var turnOnAll: [String] { get }
    /// Turn On All element.
    var turnOnAllElement: XCUIElement { get }
}

/// Protocol defining health alert "turn off all" element and messages.
public protocol HealthAlertTurnOffAll: SystemMessages {
    /// Turn Off All messages.
    static var turnOffAll: [String] { get }
    /// Turn Off All element.
    var turnOffAllElement: XCUIElement { get }
}

// MARK: - Default implementation
extension HealthAlertAllow where Self: BaseAppPage {
    /// Allow element.
    public var allowElement: XCUIElement {
        guard let button = view.buttons.elements(withLabelsMatching: type(of: self).allow).first else {
            preconditionFailure("Cannot find allow button.")
        }

        return button
    }
}

extension HealthAlertDeny where Self: BaseAppPage {
    /// Deny element.
    public var denyElement: XCUIElement {
        guard let button = view.buttons.elements(withLabelsMatching: type(of: self).deny).first else {
            preconditionFailure("Cannot find deny button.")
        }

        return button
    }
}

extension HealthAlertTurnOnAll where Self: BaseAppPage {
    /// Turn On All element.
    public var turnOnAllElement: XCUIElement {
        guard let button = view.staticTexts.elements(withLabelsMatching: type(of: self).turnOnAll).first else {
            preconditionFailure("Cannot find turn on all button.")
        }

        return button
    }
}

extension HealthAlertTurnOffAll where Self: BaseAppPage {
    /// Turn Off All element.
    public var turnOffAllElement: XCUIElement {
        guard let button = view.staticTexts.elements(withLabelsMatching: type(of: self).turnOffAll).first else {
            preconditionFailure("Cannot find turn off all button.")
        }

        return button
    }
}
#endif
