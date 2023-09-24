//
//  Routing.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 27.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Fish
import RugbyFoundation

extension Router {
    var podsProjectRelativePath: String {
        Folder.current.subpath("Pods", "Pods.xcodeproj")
            .relativePath(to: Folder.current.path)
    }

    var plansRelativePath: String { ".rugby/plans.yml" }
}
