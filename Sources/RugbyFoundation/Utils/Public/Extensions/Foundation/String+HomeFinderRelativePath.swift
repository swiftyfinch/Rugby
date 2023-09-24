//
//  String+HomeFinderRelativePath.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 18.08.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

extension String {
    /// Replaces the prefix with tilda if it equals to the home directory path.
    public func homeFinderRelativePath() -> String {
        guard let homePath = ProcessInfo.processInfo.environment["HOME"] else { return self }
        return hasPrefix(homePath) ? "~\(dropFirst(homePath.count))" : self
    }
}
