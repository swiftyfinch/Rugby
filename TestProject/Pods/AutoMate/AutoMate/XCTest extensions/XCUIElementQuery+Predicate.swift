//
//  XCUIElementQuery+Predicate.swift
//  AutoMate
//
//  Created by Bartosz Janda on 03.04.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation
import XCTest

public extension XCUIElementQuery {

    // MARK: Predicates
    /// Returns predicate with identifier and label matching one of provided values.
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
    /// let predicate = XCUIElementQuery.predicate(withIdentifier: "title", labels: ["Z miłością przez", "Made with love by"])
    /// let label = app.staticTexts.element(matching: predicate)
    /// ```
    ///
    /// - Parameters:
    ///   - identifier: Identifier of element to search for.
    ///   - labels: Labels of element to search for.
    ///   - labelComparisonOperator: Operation to use when performing comparison.
    /// - Returns: An predicate which matches element which identifier and label match given texts.
    class func predicate(withIdentifier identifier: String, labels: [String], labelComparisonOperator: StringComparisonOperator = .equals) -> NSPredicate {
        let identifierPredicate = NSPredicate(format: "identifier == %@", identifier)
        let labelsPredicates = labels.map { NSPredicate(format: "label \(labelComparisonOperator.rawValue) %@", $0) }
        let labelPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: labelsPredicates)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [identifierPredicate, labelPredicate])
    }
}
