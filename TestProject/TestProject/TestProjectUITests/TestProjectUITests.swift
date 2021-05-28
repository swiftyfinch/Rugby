//
//  TestProjectUITests.swift
//  TestProjectUITests
//
//  Created by Vyacheslav Khorkov on 21.03.2021.
//

import XCTest

final class TestProjectUITests: XCTestCase {
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.state, .runningForeground)
    }
}
