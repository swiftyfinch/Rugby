//
//  XCUIElementQuery.swift
//  AutoMate
//
//  Created by Pawel Szot on 02/08/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

import Foundation
import XCTest

/// Represents available string comparison operations to perform with `NSPredicate` API.
///
/// Enum value describing NSPredicate string comparison operator.
///
/// - `equals`: `==` operator
/// - `beginsWith`: `BEGINSWITH` operator
/// - `contains`: `CONTAINS` operator
/// - `endsWith`: `ENDSWITH` operator
/// - `like`: `LIKE` operator
/// - `matches`: `MATCHES` operator
/// - `other`: Custom operator
public enum StringComparisonOperator: RawRepresentable {
    /// `==` operator
    case equals

    /// `BEGINSWITH` operator
    case beginsWith

    /// `CONTAINS` operator
    case contains

    /// `ENDSWITH` operator
    case endsWith

    /// `LIKE` operator
    case like

    /// `MATCHES` operator
    case matches

    /// Custom string operator.
    case other(comparisonOperator: String)

    /// String representation of the `self`.
    public var rawValue: String {
        switch self {
        case .equals: return "=="
        case .beginsWith: return "BEGINSWITH"
        case .contains: return "CONTAINS"
        case .endsWith: return "ENDSWITH"
        case .like: return "LIKE"
        case .matches: return "MATCHES"
        case .other(let comparisonOperator): return comparisonOperator
        }
    }

    /// Initialize comparison operator with string.
    ///
    /// - Parameter rawValue: String to use. If it doesn't match any preexisting cases, it will be parsed as `.other`.
    public init(rawValue: String) {
        switch rawValue {
        case "==": self = .equals
        case "BEGINSWITH": self = .beginsWith
        case "CONTAINS": self = .contains
        case "ENDSWITH": self = .endsWith
        case "LIKE": self = .like
        case "MATCHES": self = .matches
        default: self = .other(comparisonOperator: rawValue)
        }
    }
}

public extension XCUIElementQuery {

    // MARK: Methods
    /// Returns element with label matching provided string.
    ///
    /// - note:
    /// String matching is customizable with operators available in `NSPredicate` specification.
    /// Check the `StringComparisonOperator` for available options.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let text = app.staticTexts.element(withLabelMatching: "John*", comparisonOperator: .like)
    /// XCTAssertTrue(text.exists)
    /// ```
    ///
    /// - Parameters:
    ///   - text: String to search for.
    ///   - comparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that label matches to given text.
    func element(withLabelMatching text: String, comparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        return element(matching: NSPredicate(format: "label \(comparisonOperator.rawValue) %@", text))
    }

    /// Returns array of existing elements matching given labels.
    ///
    /// Can be used when looking for an element which label can match to one from many texts.
    ///
    /// - note:
    /// String matching is customizable with operators available in `NSPredicate` specification.
    /// Check the `StringComparisonOperator` for available options.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let texts = ["Ok", "Done", "Go"]
    /// let elements = app.buttons.elements(withLabelsMatching: texts, comparisonOperator: .equals)
    /// ```
    ///
    /// - Parameters:
    ///   - texts: List of labels.
    ///   - comparisonOperator: Operation to use when performing comparison.
    /// - Returns: Array of `XCUIElement` elements.
    func elements(withLabelsMatching texts: [String], comparisonOperator: StringComparisonOperator = .equals) -> [XCUIElement] {
        return texts
            .compactMap({ element(withLabelMatching: $0, comparisonOperator: comparisonOperator) })
            .filter { $0.exists }
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
    /// let label = app.staticTexts.element(withIdentifier: "title", label: "Made with love")
    /// ```
    ///
    /// - Parameters:
    ///   - identifier: Identifier of element to search for.
    ///   - label: Label of element to search for.
    ///   - labelComparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that identifier and label match given texts.
    func element(withIdentifier identifier: String, label: String, labelComparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier == %@ AND label \(labelComparisonOperator.rawValue) %@", identifier, label)
        return element(matching: predicate)
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
    /// let label = app.staticTexts.element(withIdentifier: "title", labels: ["Z miłością przez", "Made with love by"])
    /// ```
    ///
    /// - Parameters:
    ///   - identifier: Identifier of element to search for.
    ///   - labels: Labels of element to search for.
    ///   - labelComparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that identifier and label match given texts.
    func element(withIdentifier identifier: String, labels: [String], labelComparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        let predicate = type(of: self).predicate(withIdentifier: identifier, labels: labels, labelComparisonOperator: labelComparisonOperator)
        return element(matching: predicate)
    }

    /// Returns element that contains children matching provided identifier-label dictionary.
    ///
    /// Searches for element that has sub-elements matching provided "identifier:label" pairs.
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
    /// let cell = tableView.cells.element(containingLabels: ["name": "John*", "email": "*.com"], labelsComparisonOperator: .like)
    /// XCTAssertTrue(cell.exists)
    /// ```
    ///
    /// - Parameters:
    ///   - dictionary: Dictionary of identifiers and labels to search for.
    ///   - comparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that identifiers and labels match given texts.
    func element(containingLabels dictionary: [String: String], labelsComparisonOperator comparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        let predicateString = "identifier == %@ AND label \(comparisonOperator.rawValue) %@"
        var query = self
        for (identifier, label) in dictionary {
            let predicate = NSPredicate(format: predicateString, argumentArray: [identifier, label])
            query = query.containing(predicate)
        }

        return query.element
    }

    /// Returns element that contains children matching provided identifier-labels dictionary.
    ///
    /// Searches for element that has sub-elements matching provided "identifier:labels" pairs.
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
    /// let cell = tableView.cells.element(containingLabels: ["name": ["John*", "Jan*"], "email": ["Free*", "Wolny*"]], labelsComparisonOperator: .like)
    /// XCTAssertTrue(cell.exists)
    /// ```
    ///
    /// - Parameters:
    ///   - dictionary: Dictionary of identifiers and labels to search for.
    ///   - comparisonOperator: Operation to use when performing comparison.
    /// - Returns: `XCUIElement` that identifiers and labels match given texts.
    func element(containingLabels dictionary: [String: [String]], labelsComparisonOperator comparisonOperator: StringComparisonOperator = .equals) -> XCUIElement {
        var query = self
        for (identifier, labels) in dictionary {
            let predicate = type(of: self).predicate(withIdentifier: identifier, labels: labels, labelComparisonOperator: comparisonOperator)
            query = query.containing(predicate)
        }

        return query.element
    }
}

public extension XCUIElementQuery {
    // MARK: Shorted
    /// Returns element with label which begins with provided string.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let text = app.staticTexts.element(withLabelPrefixed: "John")
    /// XCTAssertTrue(text.exists)
    /// ```
    ///
    /// - Parameter text: String to search for.
    /// - Returns: `XCUIElement` that label begins with given text.
    func element(withLabelPrefixed text: String) -> XCUIElement {
        return element(withLabelMatching: text, comparisonOperator: .beginsWith)
    }

    /// Returns element with label which contains provided string.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let text = app.staticTexts.element(withLabelContaining: "John")
    /// XCTAssertTrue(text.exists)
    /// ```
    ///
    /// - Parameter text: String to search for.
    /// - Returns: `XCUIElement` that label contains given text.
    func element(withLabelContaining text: String) -> XCUIElement {
        return element(withLabelMatching: text, comparisonOperator: .contains)
    }

    /// Returns array of existing elements containing given labels.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let texts = ["Ok", "Done", "Go"]
    /// let elements = app.buttons.elements(withLabelsContaining: texts)
    /// ```
    ///
    /// - Parameter texts: List of labels.
    /// - Returns: Array of `XCUIElement` elements.
    func elements(withLabelsContaining texts: [String]) -> [XCUIElement] {
        return elements(withLabelsMatching: texts, comparisonOperator: .contains)
    }

    /// Returns array of existing elements `like` given labels.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let texts = ["Ok", ".*Done", "Go"]
    /// let elements = app.buttons.elements(withLabelsLike: texts)
    /// ```
    ///
    /// - Parameter texts: List of labels.
    /// - Returns: Array of `XCUIElement` elements.
    func elements(withLabelsLike texts: [String]) -> [XCUIElement] {
        return elements(withLabelsMatching: texts, comparisonOperator: .like)
    }
}
