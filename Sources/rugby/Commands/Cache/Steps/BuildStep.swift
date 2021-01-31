//
//  BuildStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

final class BuildStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Build", logFile: logFile, verbose: verbose)
    }

    func run(scheme: String?, checksums: [String]) throws {
        if let scheme = scheme {
            try XcodeBuild(project: .podsProject, scheme: scheme).build()
        }
        let checksumsFile = try Folder.current.createFileIfNeeded(at: .cachedChecksums)
        try checksumsFile.write("SPEC CHECKSUMS:\n" + checksums.joined(separator: "\n") + "\n\n")
        done()
    }
}
