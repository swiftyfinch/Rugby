//
//  LocationAlert.swift
//  AutoMate
//
//  Created by Bartosz Janda on 15.02.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import Foundation
#if os(iOS)

// MARK: - Location protocols
/// Protocol defining location alert allow element.
public protocol LocationAlertAllow: SystemAlertAllow { }

/// Protocol defining location alert deny element.
public protocol LocationAlertDeny: SystemAlertDeny { }

/// Protocol defining location alert ok element.
public protocol LocationAlertOk: SystemAlertOk { }

/// Protocol defining location alert cancel element.
public protocol LocationAlertCancel: SystemAlertCancel { }

/// Protocol defining location alert allow always element.
public protocol LocationAlwaysAlertAllow: SystemAlertAllow { }

/// Protocol defining location alert when in use only element.
public protocol LocationAlwaysAlertAllowWhenInUseOnly: SystemAlertCancel { }

#endif
