//
//  AutoMateLaunchEnvironments.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 26/01/2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

// MARK: - AutoMateLaunchEnvironment
/// Protocol adapted by all launch enviroment options predefined in `AutoMate`.
/// It also assures that default handling is provided by [AutoMate - AppBuddy](https://github.com/PGSSoft/AutoMate-AppBuddy).
public protocol AutoMateLaunchEnvironment {
    // MARK: Properties
    /// Readable unique key that is passed with launch enviroment.
    static var key: AutoMateKey { get }
}

/// Default implementations for `AutoMateLaunchEnvironment` that can handle multiple resource values.
public extension AutoMateLaunchEnvironment where Self: LaunchEnvironmentWithMultipleValues, Self.Value == LaunchEnvironmentResourceValue {

    // MARK: Properties
    /// Implementation overriding `uniqueIdentifier` property from `LaunchOption` protocol to use `rawValue` of `AutoMateKey`.
    var uniqueIdentifier: String {
        return Self.key.rawValue
    }

    // MARK: Initialization
    /// Intializes `AutoMateLaunchEnvironment` with tuples describing `LaunchEnvironmentResourceValue`.
    ///
    /// - Parameter resources: `(String, String?)` tuples describing `LaunchEnvironmentResourceValue`
    init(resources: (fileName: String, bundleName: String?)...) {
        self.init(valuesCollection: resources.map(Value.init))
    }
}

/// Default implementations for `AutoMateLaunchEnvironment` that handle single value.
public extension AutoMateLaunchEnvironment where Self: LaunchEnvironmentWithSingleValue {

    // MARK: Properties
    /// Implementation of `key` property from `LaunchEnvironmentWithSingleValue` protocol to use `rawValue` of `AutoMateKey`.
    var key: String {
        return Self.key.rawValue
    }
}

// MARK: - Event Launch Environment
/// Launch environment supporting `EventKit` events.
/// Expects bundle and file name for every file containing data of events to be added into calendar at test launch. 
/// Structure is defined in example project's file _events.json_.
///
/// **Example:**
///
/// ```swift
/// let recurringEvents: EventLaunchEnvironment = [ LaunchEnvironmentResourceValue(fileName: "monthly_events", bundleName: "Data") ]
/// let nearEvents = EventLaunchEnvironment(resources: (fileName: "todays_events", bundleName: "Test data"), (fileName: "this_week_events", bundleName: nil))
/// let nearEvents = EventLaunchEnvironment(shouldCleanBefore: true, resources: (fileName: "todays_events", bundleName: "Test data"), (fileName: "this_week_events", bundleName: nil))
/// ```
///
/// - warning:
///   Setting `shouldCleanBefore` to `true` will remove all events from a device.
public struct EventLaunchEnvironment: CleanableLaunchEnvironmentWithMultipleValues, AutoMateLaunchEnvironment {

    // MARK: Typealiases
    /// Defines associated type from `LaunchEnvironmentProtocol` to be `LaunchEnvironmentResourceValue`.
    public typealias Value = LaunchEnvironmentResourceValue

    // MARK: Properties
    /// Defines `LaunchEnvironmentResourceValue` as `AutoMateKey.events`.
    public static let key: AutoMateKey = .events
    /// Array to store all resource values from which launch enviroment value is composed.
    public let valuesCollection: [Value]
    /// Flag that indicates if all `EKEvent`s should be removed before saving new ones.
    public let shouldCleanBefore: Bool

    // MARK: Initialization
    /// Initializes `EventLaunchEnvironment` that can be passed to `TestLauncher`.
    /// If handler is added to `LaunchEnvironmentManager` default handling is provided 
    /// by [AutoMate - AppBuddy](https://github.com/PGSSoft/AutoMate-AppBuddy).
    ///
    /// - Parameters:
    ///   - shouldCleanBefore: `Bool` flag indicating if `EKEvent`s should be removed before saving new ones.
    ///   - valuesCollection: `Array` of all resource values to be passed.
    public init(shouldCleanBefore: Bool, valuesCollection: [Value]) {
        self.valuesCollection = valuesCollection
        self.shouldCleanBefore = shouldCleanBefore
    }
}

// MARK: - Reminder Launch Environment
/// Launch environment supporting `EventKit` reminders.
/// Expects bundle and file name for every file containing data of reminders to be added into calendar at test launch. 
/// Structure is defined in example project's file _reminders.json_.
///
/// **Example:**
///
/// ```swift
/// let recurringReminders: ReminderLaunchEnvironment = [ LaunchEnvironmentResourceValue(fileName: "johnys_birthday_reminder", bundleName: "Data") ]
/// let highPriorityReminders = ReminderLaunchEnvironment(resources: (fileName: "automate_release_reminders", bundleName: "Test data"), (fileName: "wwdc_reminders", bundleName: nil))
/// let highPriorityReminders = ReminderLaunchEnvironment(shouldCleanBefore: true, resources: (fileName: "automate_release_reminders", bundleName: "Test data"), (fileName: "wwdc_reminders", bundleName: nil))
/// ```
///
/// - warning:
///   Setting `shouldCleanBefore` to `true` will remove all reminders from a device.
public struct ReminderLaunchEnvironment: CleanableLaunchEnvironmentWithMultipleValues, AutoMateLaunchEnvironment {

    // MARK: Typealiases
    /// Defines associated type from `LaunchEnvironmentProtocol` to be `LaunchEnvironmentResourceValue`.
    public typealias Value = LaunchEnvironmentResourceValue

    // MARK: Properties
    /// Defines `LaunchEnvironmentResourceValue` as `AutoMateKey.reminders`.
    public static let key: AutoMateKey = .reminders
    /// Array to store all resource values from which launch enviroment value is composed.
    public let valuesCollection: [Value]
    /// Flag that indicates if all `EKReminder`s should be removed before saving new ones.
    public let shouldCleanBefore: Bool

    // MARK: Initialization
    /// Initializes `EventLaunchEnvironment` that can be passed to `TestLauncher`.
    /// If handler is added to `LaunchEnvironmentManager` default handling is provided
    /// by [AutoMate - AppBuddy](https://github.com/PGSSoft/AutoMate-AppBuddy).
    ///
    /// - Parameters:
    ///   - shouldCleanBefore: `Bool` flag indicating if `EKReminder`s should be removed before saving new ones.
    ///   - valuesCollection: `Array` of all resource values to be passed.
    public init(shouldCleanBefore: Bool, valuesCollection: [Value]) {
        self.valuesCollection = valuesCollection
        self.shouldCleanBefore = shouldCleanBefore
    }
}

// MARK: - Contacts Launch Environment
/// Launch environment supporting `Contacts`.
/// Expects bundle and file name for every file containing data of contacts to be added to address book at test launch.
/// Structure is defined in example project's file _contacts.json_.
///
/// **Example:**
///
/// ```swift
/// let johnContacts: ContactLaunchEnvironment = [ LaunchEnvironmentResourceValue(fileName: "john", bundleName: "Data") ]
/// let severalContacts = ContactLaunchEnvironment(resources: (fileName: "michael", bundleName: "Test data"), (fileName: "emma", bundleName: nil))
/// let severalContacts = ContactLaunchEnvironment(shouldCleanBefore: true, resources: (fileName: "michael", bundleName: "Test data"), (fileName: "emma", bundleName: nil))
/// ```
///
/// - warning:
///   Setting `shouldCleanBefore` to `true` will remove all contacts from a device.
public struct ContactLaunchEnvironment: CleanableLaunchEnvironmentWithMultipleValues, AutoMateLaunchEnvironment {

    // MARK: Typealiases
    /// Defines associated type from `LaunchEnvironmentProtocol` to be `LaunchEnvironmentResourceValue`.
    public typealias Value = LaunchEnvironmentResourceValue

    // MARK: Properties
    /// Defines `LaunchEnvironmentResourceValue` as `AutoMateKey.contacts`.
    public static let key: AutoMateKey = .contacts
    /// Array to store all resource values from which launch enviroment value is composed.
    public let valuesCollection: [LaunchEnvironmentResourceValue]
    /// Flag that indicates if all `CNContact`s should be removed before saving new ones.
    public let shouldCleanBefore: Bool

    // MARK: Initialization
    /// Initializes `EventLaunchEnvironment` that can be passed to `TestLauncher`.
    /// If handler is added to `LaunchEnvironmentManager` default handling is provided
    /// by [AutoMate - AppBuddy](https://github.com/PGSSoft/AutoMate-AppBuddy).
    ///
    /// - Parameters:
    ///   - shouldCleanBefore: `Bool` flag indicating if `CNContact`s should be removed before saving new ones.
    ///   - valuesCollection: `Array` of all resource values to be passed.
    public init(shouldCleanBefore: Bool, valuesCollection: [Value]) {
        self.valuesCollection = valuesCollection
        self.shouldCleanBefore = shouldCleanBefore
    }
}

// MARK: - Turn off animation launch environment
/// Launch environment disabling `UIKit` animation.
///
/// **Example:**
///
/// ```swift
/// let disableAnimation = AnimationLaunchEnvironment()
/// ```
public struct AnimationLaunchEnvironment: LaunchEnvironmentWithSingleValue, AutoMateLaunchEnvironment {

    // MARK: Typealiases
    /// Defines associated type from `LaunchEnvironmentProtocol` to be `BooleanLaunchEnvironmentValue`.
    public typealias Value = BooleanLaunchEnvironmentValue

    // MARK: Properties
    /// Defines `LaunchEnvironmentResourceValue` as `AutoMateKey.animation`.
    public static let key: AutoMateKey = .animation

    /// Value from which is used as launch enviroment value.
    public var value: Value

    // MARK: Initialization
    /// Initialize launch option. By default disable animation (`false`).
    ///
    /// - Parameter animation: `false` (default) if the animation should be disabled.
    public init(animation: Value = false) {
        value = animation
    }
}

// MARK: - In in UI test launch environment
/// Launch environment informing application that is running in UI test.
///
/// **Example:**
///
/// ```swift
/// let isInUITest = IsInUITestLaunchEnvironment()
/// ```
public struct IsInUITestLaunchEnvironment: LaunchEnvironmentWithSingleValue, AutoMateLaunchEnvironment {

    // MARK: Typealiases
    /// Defines associated type from `LaunchEnvironmentProtocol` to be `BooleanLaunchEnvironmentValue`.
    public typealias Value = BooleanLaunchEnvironmentValue

    // MARK: Properties
    /// Defines `LaunchEnvironmentResourceValue` as `AutoMateKey.animation`.
    public static let key: AutoMateKey = .isInUITest

    /// Value from which is used as launch enviroment value.
    public var value: Value

    // MARK: Initialization
    /// Initialize launch option. By default inform application that it is running in UI test (`true`).
    ///
    /// - Parameter running: `true` (default) if the application should know if it is running in UI test.
    public init(inUITest: Value = true) {
        value = inUITest
    }
}
