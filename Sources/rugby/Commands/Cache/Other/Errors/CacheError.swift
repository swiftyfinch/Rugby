//
//  CacheError.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Foundation
import Rainbow

enum CacheError: Error, LocalizedError {
    case cantParsePodfileLock
    case cantParseCachedChecksums
    case cantFindRemotePodsTargets
    case cantFineXcodeCommandLineTools
    case buildFailed

    var errorDescription: String? {
        let output: String
        switch self {
        case .cantParsePodfileLock:
            output = "Couldn't parse Podfile.lock.".red
        case .cantParseCachedChecksums:
            output = "Couldn't parse cached checksums.".red
        case .cantFindRemotePodsTargets:
            output = "Couldn't find remote pods targets.\n".red
                + "🚑 Try to call pod install.".yellow
        case .cantFineXcodeCommandLineTools:
            output = "Couldn't find Xcode CLT.\n".red
                + "🚑 Check Xcode Preferences → Locations → Command Line Tools.".yellow
        case .buildFailed:
            let buildCommand = "cat \(String.buildLog) | xcpretty"
            output = "Build failed.\n".red
                + "🚑 Run for more information: ".white + buildCommand.yellow
        }
        return output
    }
}
