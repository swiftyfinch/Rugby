//
//  XCUIElement.swift
//  AutoMate
//
//  Created by Pawel Szot on 29/07/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

import Foundation
import XCTest

public extension XCUIElement {

    // MARK: Properties
    /// Indicates if the element is currently visible on the screen.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let button = app.buttons.element
    /// button.tap()
    /// XCTAssertTrue(button.isVisible)
    /// ```
    var isVisible: Bool {
        // When accessing properties of XCUIElement, XCTest works differently than in a case of actions on elements
        // - there is no waiting for the app to idle and to finish all animations.
        // This can lead to problems and test flakiness as the test will evaluate a query before e.g. view transition has been completed.
        return exists && isHittable
    }

    /// Returns `value` as a String
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let textField = app.textFields.element
    /// let text = textField.text
    /// ```
    ///
    /// - note:
    /// It will fail if `value` is not a `String` type.
    var text: String {
        guard let text = value as? String else {
            preconditionFailure("Value: \(String(describing: value)) is not a String")
        }
        return text
    }

    #if os(iOS)
    // MARK: Methods
    /// Remove text from textField or secureTextField.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let textField = app.textFields.element
    /// textField.clearTextField()
    /// ```
    func clearTextField() {
        // Since iOS 9.1 the keyboard identifiers are available.
        // On iOS 9.0 the special character `\u{8}` (backspace) is used.
        if #available(iOS 9.1, *) {
            let app = XCUIApplication()
            let deleteButton = app.keys[KeyboardLocator.delete]
            var previousValueLength = 0
            while self.text.count != previousValueLength {
                // Keep removing characters until text is empty, or removing them is not allowed.
                previousValueLength = self.text.count
                deleteButton.tap()
            }
        } else {
            var previousValueLength = 0
            while self.text.count != previousValueLength {
                // Keep removing characters until text is empty, or removing them is not allowed.
                previousValueLength = self.text.count
                typeText("\u{8}")
            }
        }
    }
    #endif

    #if os(iOS)
    /// Remove text from textField and enter new value.
    ///
    /// Useful if there is chance that the element contains text already.
    /// This helper method will execute `clearTextField` and then type the provided string.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let textField = app.textFields.element
    /// textField.clear(andType: "text")
    /// ```
    ///
    /// - Parameter text: Text to type after clearing old value.
    func clear(andType text: String) {
        tap()
        clearTextField()
        typeText(text)
    }
    #endif
}
