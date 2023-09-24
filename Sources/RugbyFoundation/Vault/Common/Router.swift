//
//  Router.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 27.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Fish

/// The service providing all paths for Rugby infrastructure.
public final class Router {
    /// The general paths to Rugby shared folders.
    public let paths = Paths(
        sharedFolder: Folder.home.subpath(.rugby),
        binFolder: Folder.home.subpath(.rugby, .bin),
        logsFolder: Folder.home.subpath(.rugby, .logs)
    )

    func paths(relativeTo workingDirectory: IFolder) -> PathRouter {
        PathRouter(workingDirectory: workingDirectory)
    }
}

// MARK: - Paths

extension Router {
    /// The structure describing the general paths to Rugby shared folders.
    public struct Paths {
        /// The path to the main shared folder.
        public let sharedFolder: String
        /// The path to the binaries folder.
        public let binFolder: String
        /// The path to the logs folder.
        public let logsFolder: String
    }
}

struct PathRouter {
    private let workingDirectory: IFolder

    init(workingDirectory: IFolder) {
        self.workingDirectory = workingDirectory
    }

    var pods: String {
        workingDirectory.subpath(.pods)
    }

    var podsProject: String {
        workingDirectory.subpath(.pods, .podsProject)
    }

    var build: String {
        workingDirectory.subpath(.rugby, .build)
    }

    var rawLog: String {
        workingDirectory.subpath(.rawBuildLog)
    }

    var beautifiedLog: String {
        workingDirectory.subpath(.buildLog)
    }

    var backup: String {
        workingDirectory.subpath(.rugby, .backup)
    }

    var rugby: String {
        workingDirectory.subpath(.rugby)
    }
}

// MARK: - Constants

private extension String {
    static let rugby = ".rugby"
    static let logs = "logs"
    static let bin = "bin"
    static let pods = "Pods"
    static let podsProject = "Pods.xcodeproj"
    static let build = "build"
    static let rawBuildLog = "rawBuild.log"
    static let buildLog = "build.log"
    static let backup = "backup"
}
