//
//  PBXTarget+Files.swift
//  
//
//  Created by Vyacheslav Khorkov on 06.04.2021.
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
