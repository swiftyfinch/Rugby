//
//  PBXTarget+Files.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 06.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension PBXTarget {
    var sourcesFiles: [PBXBuildFile] {
        (try? sourcesBuildPhase()?.files) ?? []
    }

    var resourcesFiles: [PBXBuildFile] {
        (try? resourcesBuildPhase()?.files) ?? []
    }
}
