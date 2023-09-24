//
//  Vault+Delete.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 05.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Fish

extension Vault {
    /// The manager to delete targets from Xcode project.
    /// - Parameter workingDirectory: A directory with Xcode project.
    public func deleteTargetsManager(workingDirectory: IFolder,
                                     projectPath: String) -> IDeleteTargetsManager {
        DeleteTargetsManager(logger: logger,
                             xcodeProject: xcode.project(projectPath: projectPath),
                             backupManager: backupManager(workingDirectory: workingDirectory))
    }
}
