//
//  Collection+Sort.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 27.02.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

extension Collection where Element: StringProtocol {
    func caseInsensitiveSorted(result: ComparisonResult = .orderedAscending) -> [Element] {
        sorted { $0.caseInsensitiveCompare($1) == result }
    }
}
