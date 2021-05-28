//
//  XCUIElement.swift
//  AutoMate
//
//  Created by Pawel Szot on 02/08/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

import Foundation
import XCTest

/// Represents available types of devices.
///
/// Enum value corresponding to device screen size.
///
/// - `iPhone35`: iPhone 3.5"
/// - `iPhone40`: iPhone 4.0"
/// - `iPhone47`: iPhone 4.7"
/// - `iPhone55`: iPhone 5.5"
/// - `iPhone58`: iPhone 5.8"
/// - `iPad`: iPad
/// - `iPadPro105`: iPad Pro 10.5"
/// - `iPadPro12`: iPad Pro 12"
public enum DeviceType {
    /// iPhone 3.5"
    case iPhone35

    /// iPhone 4.0"
    case iPhone40

    /// iPhone 4.7"
    case iPhone47

    /// iPhone 5.5"
    case iPhone55

    /// iPhone 5.8"
    case iPhone58

    /// iPhone 6.1"
    case iPhone61

    /// iPhone 6.5"
    case iPhone65

    /// iPad
    case iPad

    /// iPad Pro 10.5"
    case iPadPro105

    /// iPad Pro 12"
    case iPadPro12
}

public extension XCUIApplication {

    // MARK: Properties
    /// Type of current device, based on running's app window size.
    ///
    /// Uses screen size to guess device that tests are running on. May be useful if there is some device specific behaviour that has to be checked.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// if app.deviceType == .iPhone35 {
    ///     let button = app.buttons["more"]
    ///     button.tap()
    /// }
    /// ```
    ///
    /// - note:
    ///   `XCUIApplication` already has `verticalSizeClass` and `horizontalSizeClass` that can be used to distinguish between different layouts from interface designer.
    /// - note:
    ///   iPhone6 and iPhone6+ have "Zoom" feature, which will make the resultion smaller. In this case iPhone6 would appear as iPhone 5,
    /// and iPhone6+ as iPhone 6.
    /// - note:
    /// iPhone XS Max and XR have the same size in points, outside of UI tests you could differenciate them by scale (3x for XS Max and 2x for XR). For this reason property returns `iPhone61` for both.
    var deviceType: DeviceType {
        let window = windows.element(boundBy: 0)
        let size = window.frame.size
        let portraitSize = size.height > size.width ? size : CGSize(width: size.height, height: size.width)

        switch (round(portraitSize.width), round(portraitSize.height)) {
        case (320, 480):
            return .iPhone35
        case (320, 568):
            return .iPhone40
        case (375, 667):
            return .iPhone47
        case (414, 736):
            return .iPhone55
        case (375, 812):
            return .iPhone58
        case (414, 896):
            return .iPhone61
        case (768, 1024):
            return .iPad
        case (834, 1112):
            return .iPadPro105
        case (1024, 1365..<1367):
            return .iPadPro12
        default:
            fatalError("Unrecognized device type")
        }
    }

    /// A Boolean value indicating whether app is currently running on iPad.
    ///
    /// Indicates if the current device is an iPad, by checking the `deviceType` property.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// if app.isRunningOnIpad {
    ///     button.tap()
    /// }
    /// ```
    var isRunningOnIpad: Bool {
        switch deviceType {
        case .iPad, .iPadPro105, .iPadPro12:
            return true
        case .iPhone35, .iPhone40, .iPhone47, .iPhone55, .iPhone58,
             .iPhone61, .iPhone65:
            return false
        }
    }

    /// A Boolean value indicating whether app is currently running on iPhone.
    ///
    /// Indicates if the current device is an iPhone, by checking the `deviceType` property.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// if app.isRunningOnIphone {
    ///     button.tap()
    /// }
    /// ```
    var isRunningOnIphone: Bool {
        switch deviceType {
        case .iPad, .iPadPro105, .iPadPro12:
            return false
        case .iPhone35, .iPhone40, .iPhone47, .iPhone55, .iPhone58,
             .iPhone61, .iPhone65:
            return true
        }
    }

    /// A Boolean value indicating whether app is currently running on simulator.
    ///
    /// Indicates if tests are running inside iOS simulator, by looking for specific environment variable.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// if app.isRunningOnSimulator {
    ///     print("Running on simulator")
    /// }
    /// ```
    var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    /// Returns machine identifier string in a form of "name,major,minor", i.e. "iPhone,8,2".
    private var machineIdentifier: String {
        if isRunningOnSimulator {
            guard let value = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] else {
                fatalError("Failed to determine simulator type.")
            }
            return value
        }

        var systemInfo = utsname()
        uname(&systemInfo)
        let value = withUnsafePointer(to: &systemInfo.machine) {
            String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
        }
        return value
    }

    /// Type of current device, ignoring "Zoom" feature.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// if app.actualDeviceType == .iPhone47 && app.deviceType == .iPhone40 {
    ///     print("Detected iPhone 6 in zoom mode")
    /// }
    /// ```
    var actualDeviceType: DeviceType {
        // Determine device type by checking machineIdentifier directly.
        switch machineIdentifier {
        case "iPhone7,1", "iPhone8,2":
            return .iPhone55
        case "iPhone7,2", "iPhone8,1":
            return .iPhone47
        case "iPhone10,3":
            return .iPhone58
        default:
            return deviceType
        }
    }

    // MARK: Methods
    /// Checks if current device is of provided type.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// if app.isRunningOn(.iPhone35) {
    ///     button.tap()
    /// }
    /// ```
    ///
    /// - Parameter deviceType: Type of device to check for.
    /// - Returns: Boolean value indicating whether current device is of the expected type.
    func isRunningOn(_ deviceType: DeviceType) -> Bool {
        return self.deviceType == deviceType
    }
}
