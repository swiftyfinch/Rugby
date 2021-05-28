//
//  AppUITestCase.swift
//  AutoMate
//
//  Created by Bartosz Janda on 31.01.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation
import XCTest

/// `XCTestCase` subclass which creates and store `XCUIApplication` object for duration of the test.
///
///  **Example:**
///
/// ```swift
/// class AdditionalExtensionsTests: AppUITestCase {
///     override func setUp() {
///         super.setUp()
///         TestLauncher.configure(app).launch()
///     }
/// }
/// ```
///
/// - remark:
///   Every call to `XCUIApplication` creates new instance of this object.
///   This is why the `XCUIApplication` object is created at the beginning of the test and stored in the `app` variable.
open class AppUITestCase: XCTestCase {

    // MARK: Properties
    /// Stores `XCUIApplication` for the duration of the test.
    open var app: XCUIApplication!

    // MARK: Methods
    /// Setup method called before the invocation of each test method in the class.
    override open func setUp() {
        super.setUp()
        app = XCUIApplication()
        continueAfterFailure = false
    }

    /// Teardown method called after the invocation of each test method in the class.
    override open func tearDown() {
        app = nil
        super.tearDown()
    }
}
