// swiftlint:disable identifier_name type_body_length trailing_comma file_length line_length
/// Represents possible system service messages and label values on buttons.

import XCTest
#if os(iOS)

extension SystemAlertAllow {

    /// Represents all possible "allow" buttons in system service messages.
    public static var allow: [String] {
        return readMessages(from: "SystemAlertAllow")
    }
}

extension SystemAlertDeny {

    /// Represents all possible "deny" buttons in system service messages.
    public static var deny: [String] {
        return readMessages(from: "SystemAlertDeny")
    }
}

/// Represents `AddressBookAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = AddressBookAlert(element: alert) else {
///         XCTFail("Cannot create AddressBookAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct AddressBookAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `AddressBookAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `AddressBookAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `BluetoothPeripheralAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = BluetoothPeripheralAlert(element: alert) else {
///         XCTFail("Cannot create BluetoothPeripheralAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct BluetoothPeripheralAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `BluetoothPeripheralAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `BluetoothPeripheralAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `CalendarAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = CalendarAlert(element: alert) else {
///         XCTFail("Cannot create CalendarAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct CalendarAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `CalendarAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `CalendarAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `CallsAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = CallsAlert(element: alert) else {
///         XCTFail("Cannot create CallsAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct CallsAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `CallsAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `CallsAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `CameraAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = CameraAlert(element: alert) else {
///         XCTFail("Cannot create CameraAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct CameraAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `CameraAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `CameraAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `MediaLibraryAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = MediaLibraryAlert(element: alert) else {
///         XCTFail("Cannot create MediaLibraryAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct MediaLibraryAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `MediaLibraryAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `MediaLibraryAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `MicrophoneAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = MicrophoneAlert(element: alert) else {
///         XCTFail("Cannot create MicrophoneAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct MicrophoneAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `MicrophoneAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `MicrophoneAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `MotionAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = MotionAlert(element: alert) else {
///         XCTFail("Cannot create MotionAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct MotionAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `MotionAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `MotionAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `PhotosAddAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = PhotosAddAlert(element: alert) else {
///         XCTFail("Cannot create PhotosAddAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct PhotosAddAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `PhotosAddAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `PhotosAddAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `PhotosAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = PhotosAlert(element: alert) else {
///         XCTFail("Cannot create PhotosAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct PhotosAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `PhotosAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `PhotosAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `RemindersAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = RemindersAlert(element: alert) else {
///         XCTFail("Cannot create RemindersAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct RemindersAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `RemindersAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `RemindersAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `SiriAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = SiriAlert(element: alert) else {
///         XCTFail("Cannot create SiriAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct SiriAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `SiriAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `SiriAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `SpeechRecognitionAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = SpeechRecognitionAlert(element: alert) else {
///         XCTFail("Cannot create SpeechRecognitionAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct SpeechRecognitionAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `SpeechRecognitionAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `SpeechRecognitionAlert` with alert element.
    ///
    /// - Parameter element: An alert element.
    public init?(element: XCUIElement) {
        guard element.staticTexts.elements(withLabelsLike: type(of: self).messages).first != nil else {
            return nil
        }

        self.alert = element
    }
}

/// Represents `WillowAlert` service alert.
///
/// System alert supposed to be used in the handler of the `XCTestCase.addUIInterruptionMonitor(withDescription:handler:)` method.
///
/// **Example:**
///
/// ```swift
/// let token = addUIInterruptionMonitor(withDescription: "Alert") { (alert) -> Bool in
///     guard let alert = WillowAlert(element: alert) else {
///         XCTFail("Cannot create WillowAlert object")
///         return false
///     }
///
///     alert.denyElement.tap()
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
public struct WillowAlert: SystemAlert, SystemAlertAllow, SystemAlertDeny {

    /// Represents all possible messages in `WillowAlert` service alert.
    public static let messages = readMessages()

    /// System service alert element.
    public var alert: XCUIElement

    /// Initialize `WillowAlert` with alert element.
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
