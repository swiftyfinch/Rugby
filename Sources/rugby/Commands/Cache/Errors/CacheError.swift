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

    var errorDescription: String? {
        let output: String
        switch self {
        case .cantParsePodfileLock:
            output = "Couldn't parse Podfile.lock.".red
        case .cantParseCachedChecksums:
            output = "Couldn't parse cached checksums.".red
        case .cantFindRemotePodsTargets:
            output = "Couldn't find any targets.\n".red
                + "🚑 Try to call pod install.".yellow
        }
        // Need to clear color because in _errorLabel we don't do that
        return "\u{1B}[0m" + output
    }
}
