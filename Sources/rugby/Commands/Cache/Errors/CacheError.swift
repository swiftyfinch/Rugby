//
//  CacheError.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Foundation

enum CacheError: Error, LocalizedError {
    case cantParsePodfileLock
    case cantParseCachedChecksums

    var errorDescription: String? {
        switch self {
        case .cantParsePodfileLock:
            return "Can't parse Podfile.lock."
        case .cantParseCachedChecksums:
            return "Can't parse cached checksums."
        }
    }
}
