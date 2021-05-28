//
//  KeyboardLocator.swift
//  AutoMate
//
//  Created by Bartosz Janda on 03.03.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

/// iOS keyboard locators.
///
/// Contains known set of locators used by the system keyboard on the iOS.
///
/// - `shift`: Shift key.
/// - `delete`: Delete key.
/// - `more`: More, digits key.
/// - `dictation`: Dictation key.
/// - `return`: Return key.
/// - `go`: Go key.
/// - `google`: Google key.
/// - `join`: Join key.
/// - `next`: Next key.
/// - `route`: Route key.
/// - `search`: Search key.
/// - `send`: Send key.
/// - `yahoo`: Yahoo key.
/// - `done`: Done key.
/// - `emergencyCall`: Emergency call key
public enum KeyboardLocator: String, Locator {

    /// Shift key.
    case shift

    /// Delete key.
    case delete

    /// More, digits key.
    case more

    /// Dictation key.
    case dictation

    /// Return key.
    case `return` = "Return"

    /// Go key.
    case go = "Go"  // swiftlint:disable:this identifier_name

    /// Google key.
    case google = "Google"

    /// Join key.
    case join = "Join"

    /// Next key.
    case next = "Next"

    /// Route key.
    case route = "Route"

    /// Search key.
    case search = "Search"

    /// Send key.
    case send = "Send"

    /// Yahoo key.
    case yahoo = "Yahoo"

    /// Done key.
    case done = "Done"

    /// Emergency call key
    case emergencyCall = "Emergency call"
}
