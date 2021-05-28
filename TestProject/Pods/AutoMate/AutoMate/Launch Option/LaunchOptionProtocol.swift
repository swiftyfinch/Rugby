//
//  Options.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 19/05/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

// MARK: - LaunchOption protocol
/**
 Any type that implements this protocol can be used to configure application
 with TestLauncher. Type conforming to this protocol should override default implementation
 of *launchArguments* or *launchEnvironments*. Choice depends on which type of configuration
 option it represents.
 For more info about launch arguments and environment variables check:
 [here](https://developer.apple.com/library/ios/recipes/xcode_help-scheme_editor/Articles/SchemeRun.html)
 */
public protocol LaunchOption {
    /// Launch arguments provided by this option.
    var launchArguments: [String]? { get }

    /// Launch environment variables provided by this option.
    var launchEnvironments: [String: String]? { get }

    /// Unique value to use when comparing with other launch options.
    var uniqueIdentifier: String { get }
}

public extension LaunchOption {

    /// Unique value to use when comparing with other launch options.
    var uniqueIdentifier: String {
        return "\(type(of: self))"
    }
}
