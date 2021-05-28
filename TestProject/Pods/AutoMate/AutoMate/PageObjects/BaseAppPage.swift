//
//  BaseAppPage.swift
//  AutoMate
//
//  Created by Bartosz Janda on 31.01.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation
import XCTest

// MARK: - BaseAppPageProtocol
/// Base page object protocol. Defines basic properties and methods required by all page objects.
///
/// **Example:**
///
/// ```swift
/// class MainPage: BaseAppPageProtocol {
///     var view: XCUIElement
///     public init(in view: XCUIElement) {
///         self.view = view
///     }
/// }
/// ```
public protocol BaseAppPageProtocol {

    // MARK: Properties
    /// The container view on which all elements will be placed.
    ///
    /// - note:
    /// `view` can be an instance of `XCUIApplication` class.
    var view: XCUIElement { get }
}

// MARK: - BaseAppPage
/// Base implementation of the `BaseAppPageProtocol`. All page objects can inherit from this class.
///
/// **Example:**
///
/// ```swift
/// class MainPage: BaseAppPage {
///     var tableView: XCUIElement {
///         return view.tables[Locators.tableView]
///      }
/// }
///
/// private extension MainPage {
///     enum Locators: String, Locator {
///         case tableView
///     }
/// }
/// ```
open class BaseAppPage: BaseAppPageProtocol {

    // MARK: Properties
    /// The container view on which all elements will be placed.
    ///
    /// - note:
    /// `view` can be an instance of `XCUIApplication` class.
    open var view: XCUIElement

    // MARK: Initialization
    /// Initialize page object with container view.
    ///
    /// - Parameter view: Container view which contains all its page object elements.
    ///
    /// - note:
    /// This view can be an instance of `XCUIApplication` class.
    public init(in view: XCUIElement) {
        self.view = view
    }
}
