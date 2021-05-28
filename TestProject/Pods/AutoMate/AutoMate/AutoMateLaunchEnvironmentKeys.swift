//
//  AutoMateLaunchEnvironmentKeys.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 10/02/2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation

/// Set of LaunchEnvironment keys for predefined options implemented by AutoMate.
///
/// - `animation`: Key to pass with `AnimationLaunchEnvironment`.
/// - `contacts`: Key to pass with `ContactLaunchEnvironment`
/// - `events`: Key to pass with `EventLaunchEnvironment`.
/// - `reminders`: Key to pass with `ReminderLaunchEnvironment`.
/// - `isInUITest`: Key to pass with `IsInUITestLaunchEnvironment`.
public enum AutoMateKey: String {
    /// Key to pass with `AnimationLaunchEnvironment`.
    case animation = "AM_ANIMATION_KEY"

    /// Key to pass with `ContactLaunchEnvironment`
    case contacts = "AM_CONTACTS_KEY"

    /// Key to pass with `EventLaunchEnvironment`.
    case events = "AM_EVENTS_KEY"

    /// Key to pass with `ReminderLaunchEnvironment`.
    case reminders = "AM_REMINDERS_KEY"

    /// Key to pass with `IsInUITestLaunchEnvironment`.
    case isInUITest = "AM_IS_IN_UI_TEST"
}
