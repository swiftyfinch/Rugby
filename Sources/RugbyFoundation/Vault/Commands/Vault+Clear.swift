//
//  Vault+Clear.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 05.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Fish

extension Vault {
    /// The manager to clean Rugby folders.
    /// - Parameter workingDirectory: A directory with Pods folder.
    public func cleaner(workingDirectory: IFolder) -> IСleaner {
        Сleaner(sharedBinariesPath: router.paths.binFolder,
                buildFolderPath: router.paths(relativeTo: workingDirectory).build)
    }
}
