//
//  PushedPage.swift
//  AutoMate
//
//  Created by Bartosz Janda on 31.01.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation
import XCTest

// MARK: - PushedPage protocol
/// Page object protocol describing behaviour of pushed.
///
/// Default implementation use "back" as `accessibilityIdentifier`.
///
/// **Example:**
///
/// ```swift
/// class AboutTheAppPage: BaseAppPage, PushedPage {}
///
/// let aboutTheAppPage = AboutTheAppPage(in: containerView)
/// aboutTheAppPage.goBack()
/// ```
///
/// - requires:
/// It is required to use "back" as `accessibilityIdentifier` in custom back button in the application to work with default implementation of this protocol.
public protocol PushedPage: BaseAppPageProtocol {

    // MARK: Elements
    /// Back button element.
    var backButton: XCUIElement { get }

    // MARK: Actions
    /// Pop view action.
    func goBack()
}

// MARK: Default implementation
/// Default implementation of the `PushedPage` protocol.
public extension PushedPage {

    // MARK: Elements
    /// Back button.
    ///
    /// - note:
    /// The button with "back" as `accessibilityIdentifier` is used.
    var backButton: XCUIElement {
        return view.navigationBars.buttons.firstMatch
    }

    // MARK: Actions
    /// Pop view by tapping on `backButton` button.
    #if !os(tvOS)
    func goBack() {
        #if os(iOS)
        backButton.tap()
        #elseif os(macOS)
        backButton.click()
        #endif
    }
    #endif
}

// MARK: - Locators
private enum Locators: String, Locator {
    case backButton = "back"
}
