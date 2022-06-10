//
//  Error+BeautifulError.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 10.06.2022.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

extension Error {
    var beautifulDescription: String {
        let localizedDescription = (self as? LocalizedError)?.errorDescription
        return localizedDescription ?? String(describing: self)
    }
}
