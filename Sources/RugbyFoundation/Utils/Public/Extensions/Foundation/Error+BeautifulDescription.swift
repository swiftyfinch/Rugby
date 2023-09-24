//
//  Error+BeautifulDescription.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 04.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

extension Error {
    /// Returns error description in beautiful way.
    public var beautifulDescription: String {
        let localizedDescription = (self as? LocalizedError)?.errorDescription
        return localizedDescription ?? String(describing: self)
    }
}
