//
//  CacheError.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Foundation
import Rainbow

enum CacheError: Error, LocalizedError {
    case cantFindPodsTargets
    case cantFindXcodeCommandLineTools
    case buildFailed

    var errorDescription: String? {
        let output: String
        switch self {
        case .cantFindPodsTargets:
            output = "Couldn't find pods targets.\n".red
                + "🚑 Try to call pod install.".yellow
        case .cantFindXcodeCommandLineTools:
            output = "Couldn't find Xcode CLT.\n".red
                + "🚑 Check Xcode Preferences → Locations → Command Line Tools.".yellow
        case .buildFailed:
            let buildCommand = "cat \(String.rawBuildLog) | xcpretty"
            output = "Build failed.\n".red
                + "🚑 Run for more info: ".yellow + buildCommand.white
        }
        return output
    }
}
