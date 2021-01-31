//
//  CleanStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

final class CleanStep: Step {
    init(logFile: File, verbose: Bool, isLast: Bool) {
        super.init(name: "Clean", logFile: logFile, verbose: verbose, isLast: isLast)
    }

    func run() throws {
        try? Folder.current.subfolder(at: .supportFolder).delete()
        done()
    }
}
