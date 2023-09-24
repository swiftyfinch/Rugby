//
//  Sequence+CaseInsensitiveSorted.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 30.10.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Sequence where Element: StringProtocol {
    func caseInsensitiveSorted() -> [Element] {
        sorted { lhs, rhs in lhs.caseInsensitiveCompare(rhs) == .orderedAscending }
    }
}
