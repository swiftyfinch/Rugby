// swiftlint:disable identifier_name type_body_length trailing_comma file_length line_length
/// Represents possible location service messages and label values on buttons.

import XCTest
#if os(iOS)

extension LocationAlertAllow {

    /// Represents all possible "allow" buttons in location service messages.
    public static var allow: [String] {
        return readMessages(from: "LocationAlertAllow")
    }
}

extension LocationAlertCancel {

    /// Represents all possible "cancel" buttons in location service messages.
    public static var cancel: [String] {
        return readMessages(from: "LocationAlertCancel")
    }
}

extension LocationAlertDeny {

    /// Represents all possible "deny" buttons in location service messages.
    public static var deny: [String] {
        return readMessages(from: "LocationAlertDeny")
    }
}

extension LocationAlertOk {

    /// Represents all possible "ok" buttons in location service messages.
    public static var ok: [String] {
        return readMessages(from: "LocationAlertOk")
    }
}

extension LocationAlwaysAlertAllow {

    /// Represents all possible "allow" buttons in location service messages.
    public static var allow: [String] {
        return readMessages(from: "LocationAlwaysAlertAllow")
    }
}

extension LocationAlwaysAlertAllowWhenInUseOnly {

    /// Represents all possible "cancel" buttons in location service messages.
    public static var cancel: [String] {
        return readMessages(from: "LocationAlwaysAlertAllowWhenInUseOnly")
    }
}

/// Represents `LocationAlwaysAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = LocationAlwaysAlert(element: alert) else {
///         XCTFail("Cannot create LocationAlwaysAlert object")
///         return false
///     }
///
///     alert.allowElement.tap()
///     return true
/// }
///
/// mainPage.goToPermissionsPageMenu()
/// // Interruption won't happen without some kind of action.
/// app.tap()
/// removeUIInterruptionMonitor(token)
/// ```
///
/// - note:
/// Handlers should return `true` if they handled the UI, `false` if they did not.
public struct LocationAlwaysAlert: SystemAlert, LocationAlwaysAlertAllow, LocationAlwaysAlertAllowWhenInUseOnly, LocationAlertDeny {

    /// Represents all possible messages in `LocationAlwaysAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `LocationAlwaysAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `LocationUpgradeWhenInUseAlwaysAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = LocationUpgradeWhenInUseAlwaysAlert(element: alert) else {
///         XCTFail("Cannot create LocationUpgradeWhenInUseAlwaysAlert object")
///         return false
///     }
///
///     alert.allowElement.tap()
///     return true
/// }
///
/// mainPage.goToPermissionsPageMenu()
/// // Interruption won't happen without some kind of action.
/// app.tap()
/// removeUIInterruptionMonitor(token)
/// ```
///
/// - note:
/// Handlers should return `true` if they handled the UI, `false` if they did not.
public struct LocationUpgradeWhenInUseAlwaysAlert: SystemAlert, LocationAlwaysAlertAllow, LocationAlwaysAlertAllowWhenInUseOnly {

    /// Represents all possible messages in `LocationUpgradeWhenInUseAlwaysAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `LocationUpgradeWhenInUseAlwaysAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `LocationWhenInUseAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = LocationWhenInUseAlert(element: alert) else {
///         XCTFail("Cannot create LocationWhenInUseAlert object")
///         return false
///     }
///
///     alert.allowElement.tap()
///     return true
/// }
///
/// mainPage.goToPermissionsPageMenu()
/// // Interruption won't happen without some kind of action.
/// app.tap()
/// removeUIInterruptionMonitor(token)
/// ```
///
/// - note:
/// Handlers should return `true` if they handled the UI, `false` if they did not.
public struct LocationWhenInUseAlert: SystemAlert, LocationAlertAllow, LocationAlertDeny {

    /// Represents all possible messages in `LocationWhenInUseAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `LocationWhenInUseAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}
#endif
