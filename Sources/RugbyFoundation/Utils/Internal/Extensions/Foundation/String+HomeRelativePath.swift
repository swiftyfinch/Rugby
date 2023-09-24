//
//  String+HomeRelativePath.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 26.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

extension String {
    func homeEnvRelativePath() -> String {
        guard let homePath = ProcessInfo.processInfo.environment["HOME"] else { return self }
        return hasPrefix(homePath) ? "${HOME}\(dropFirst(homePath.count))" : self
    }
}
