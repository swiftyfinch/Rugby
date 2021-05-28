// swiftlint:disable identifier_name type_body_length trailing_comma file_length line_length
/// Represents possible health service messages and label values on buttons.

import XCTest
#if os(iOS)

extension HealthAlertAllow {

    /// Represents all possible "allow" buttons in HealthKit permission view.
    public static var allow: [String] {
        return readMessages(from: "HealthAlertAllow")
    }
}

extension HealthAlertDeny {

    /// Represents all possible "deny" buttons in HealthKit permission view.
    public static var deny: [String] {
        return readMessages(from: "HealthAlertDeny")
    }
}

extension HealthAlertOk {

    /// Represents all possible "ok" buttons in HealthKit permission view.
    public static var ok: [String] {
        return readMessages(from: "HealthAlertOk")
    }
}

extension HealthAlertTurnOffAll {

    /// Represents all possible "turnOffAll" buttons in HealthKit permission view.
    public static var turnOffAll: [String] {
        return readMessages(from: "HealthAlertTurnOffAll")
    }
}

extension HealthAlertTurnOnAll {

    /// Represents all possible "turnOnAll" buttons in HealthKit permission view.
    public static var turnOnAll: [String] {
        return readMessages(from: "HealthAlertTurnOnAll")
    }
}

extension HealthPermissionPage {

    /// Represents all possible messages in HealthKit permission view.
    public static var messages: [String] {
        return readMessages(from: "HealthPermissionPage")
    }
}

/// Represents `HealthAuthorizationDontAllowAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = HealthAuthorizationDontAllowAlert(element: alert) else {
///         XCTFail("Cannot create HealthAuthorizationDontAllowAlert object")
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
/// - warning:
/// The alert seems to be visible in view hierarchy and work without an "interruption monitor dance".
/// Check working example here: [AutoMateExample `PermissionsTests -testHealthKitAlert`](https://github.com/PGSSoft/AutoMate/blob/master/AutoMateExample/AutoMateExampleUITests/PermissionsTests.swift)
public struct HealthAuthorizationDontAllowAlert: SystemAlert, HealthAlertOk {

    /// Represents all possible messages in `HealthAuthorizationDontAllowAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `HealthAuthorizationDontAllowAlert` with alert element.
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
