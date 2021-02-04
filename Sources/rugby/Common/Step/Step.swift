//
//  Step.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

class Step {
    private let verbose: Bool
    private let isLast: Bool
    let progress: RugbyProgressBar

    init(name: String, logFile: File? = nil, verbose: Bool, isLast: Bool = false) {
        self.verbose = verbose
        self.isLast = isLast
        self.progress = RugbyProgressBar(title: name,
                                         logFile: logFile,
                                         verbose: verbose)
    }

    func done() {
        progress.done()
        if verbose && !isLast { print("------------------------------------------------".yellow) }
    }
}
