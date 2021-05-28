//
//  XCUIElementQuery+Locator.swift
//  AutoMate
//
//  Created by Bartosz Janda on 31.03.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation
import XCTest

public extension XCUIElementQuery {
    // MARK: Locator methods
    /// Returns `XCUIElement` that matches the type and locator.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let button = app.buttons[Locators.ok]
    /// ```
    ///
    /// - Parameter locator: `Locator` used to find element
    subscript(locator: Locator) -> XCUIElement {
        return self[locator.identifier]
    }

    /// Returns element with label matching provided string.
    ///
    /// - note:
    /// String matching is customizable with operators available in `NSPredicate` specification.
    /// Check the `StringComparisonOperator` for available options.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let text = app.staticTexts.element(withLabelMatchingLocator: Locators.john, comparisonOperator: .like)
    /// XCTAssertTrue(text.exists)
    /// ```
    ///
    /// - Parameters:
    ///   - locator: Locator to search for.
    ///   - comparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that label matches given locator.
    func element(withLabelMatchingLocator locator: Locator, comparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        return element(withLabelMatching: locator.identifier, comparisonOperator: comparisonOperator)
    }

    /// Returns element with identifier and label matching provided values.
    ///
    /// Can be used to find a cell which `UILabel`, with provided `identifier`, contains text provided by `label`.
    ///
    /// - note:
    /// String matching is customizable with operators available in `NSPredicate` specification.
    /// Check the `StringComparisonOperator` for available options.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let label = app.staticTexts.element(withLocator: Locators.title, label: Locators.madeWithLove)
    /// ```
    ///
    /// - Parameters:
    ///   - locator: Identifier of element to search for.
    ///   - label: Label of element to search for.
    ///   - labelComparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that identifier and label match to given locators.
    func element(withLocator locator: Locator, label: Locator, labelComparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        return element(withLocator: locator, label: label.identifier, labelComparisonOperator: labelComparisonOperator)
    }

    /// Returns element with identifier and label matching provided values.
    ///
    /// Can be used to find a cell which `UILabel`, with provided `identifier`, contains text provided by `label`.
    ///
    /// - note:
    /// String matching is customizable with operators available in `NSPredicate` specification.
    /// Check the `StringComparisonOperator` for available options.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let label = app.staticTexts.element(withLocator: Locators.title, label: "Made with love")
    /// ```
    ///
    /// - Parameters:
    ///   - locator: Identifier of element to search for.
    ///   - label: Label of element to search for.
    ///   - labelComparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that identifier and label match to given locator and text.
    func element(withLocator locator: Locator, label: String, labelComparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        return element(withIdentifier: locator.identifier, label: label, labelComparisonOperator: labelComparisonOperator)
    }

    /// Returns element with identifier and label matching one of provided values.
    ///
    /// Can be used to find a `UILabel` with given identifier and localized labels.
    /// Localized texts are provided in the `labels` parameter.
    ///
    /// - note:
    /// String matching is customizable with operators available in `NSPredicate` specification.
    /// Check the `StringComparisonOperator` for available options.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let label = app.staticTexts.element(withLocator: Locators.title, labels: ["Z miłością przez", "Made with love by"])
    /// ```
    ///
    /// - Parameters:
    ///   - locator: Identifier of element to search for.
    ///   - labels: Labels of element to search for.
    ///   - labelComparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that identifier and label match given texts.
    func element(withLocator locator: Locator, labels: [String], labelComparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        return element(withIdentifier: locator.identifier, labels: labels, labelComparisonOperator: labelComparisonOperator)
    }

    /// Returns element that contains children matching provided locator-label dictionary.
    ///
    /// Searches for element that has sub-elements matching provided "locator:label" pairs.
    /// Especially useful for table views and collection views where cells will have the same identifier.
    ///
    /// - note:
    /// String matching is customizable with operators available in `NSPredicate` specification.
    /// Check the `StringComparisonOperator` for available options.
    ///
    /// - note: This method is intended to be used with table and collection views, where cells have to be identified by their contents.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let tableView = app.tables.element
    /// let cell = tableView.cells.element(containingLabels: [Locators.name: "John*", Locators.email: "*.com"], labelsComparisonOperator: .like)
    /// XCTAssertTrue(cell.exists)
    /// ```
    ///
    /// - Parameters:
    ///   - dictionary: Dictionary of locators and labels to search for.
    ///   - labelsComparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that identifiers and labels match to given locators and texts.
    func element <LocatorItem: Locator> (containingLabels dictionary: [LocatorItem: String], labelsComparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        let dict = dictionary.reduce([:]) { $0.union([$1.key.identifier: $1.value]) }
        return element(containingLabels: dict, labelsComparisonOperator: labelsComparisonOperator)
    }

    /// Returns element that contains children matching provided locator-label dictionary.
    ///
    /// Searches for element that has sub-elements matching provided "locator:label" pairs.
    /// Especially useful for table views and collection views where cells will have the same identifier.
    ///
    /// - note:
    /// String matching is customizable with operators available in `NSPredicate` specification.
    /// Check the `StringComparisonOperator` for available options.
    ///
    /// - note: This method is intended to be used with table and collection views, where cells have to be identified by their contents.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let tableView = app.tables.element
    /// let cell = tableView.cells.element(containingLabels: [Locators.name: ["John*", "Jan*"], Locators.email: ["Free*", "Wolny*"]], labelsComparisonOperator: .like)
    /// XCTAssertTrue(cell.exists)
    /// ```
    ///
    /// - Parameters:
    ///   - dictionary: Dictionary of locators and labels to search for.
    ///   - labelsComparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that identifiers and labels match to given locators and texts.
    func element <LocatorItem: Locator> (containingLabels dictionary: [LocatorItem: [String]], labelsComparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        let dict = dictionary.reduce([:]) { $0.union([$1.key.identifier: $1.value]) }
        return element(containingLabels: dict, labelsComparisonOperator: labelsComparisonOperator)
    }

    // MARK: Locator shorted methods
    /// Returns element with label which begins with provided Locator.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let text = app.staticTexts.element(withLabelPrefixed: Locators.john)
    /// XCTAssertTrue(text.exists)
    /// ```
    ///
    /// - Parameter locator: Object conforming to Locator.
    /// - Returns: `XCUIElement` that label begins with given locator.
    func element(withLabelPrefixed locator: Locator) -> XCUIElement {
        return element(withLabelPrefixed: locator.identifier)
    }

    /// Returns element with label which contains provided Locator.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let text = app.staticTexts.element(withLabelContaining: Locators.john)
    /// XCTAssertTrue(text.exists)
    /// ```
    ///
    /// - Parameter locator: Object conforming to Locator.
    /// - Returns: `XCUIElement` that label contains given locator.
    func element(withLabelContaining locator: Locator) -> XCUIElement {
        return element(withLabelContaining: locator.identifier)
    }
}
