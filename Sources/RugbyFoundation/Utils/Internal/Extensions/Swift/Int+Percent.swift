//
//  Int+Percent.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 07.01.2023.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Int {
    func percent(total: Int) -> Int {
        guard total != 0 else { return 0 }
        return Int(Double(self) / Double(total) * 100)
    }
}
