//
//  Step.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

class Step {
    let verbose: Bool
    let progress: RugbyProgressBar

    init(name: String, logFile: File, verbose: Bool) {
        self.verbose = verbose
        self.progress = RugbyProgressBar(title: name, logFile: logFile, verbose: verbose)
    }

    func done() {
        progress.done()
        if verbose { print("------------------------------------------------".yellow) }
    }
}
