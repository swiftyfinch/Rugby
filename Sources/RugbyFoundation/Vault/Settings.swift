//
//  Settings.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 18.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Fish

/// The general Rugby settings.
public struct Settings {
    /// The timeout interval to use when waiting for additional data.
    public let warmupTimeout = 60 // s
    /// The maximum number of simultaneous connections to make to a given host.
    public let warmupMaximumConnectionsPerHost = 10

    let hasBackupKey = "RUGBY_HAS_BACKUP"
    let storageUsedLimit = 50_000_000_000 // 50 Gb
}
