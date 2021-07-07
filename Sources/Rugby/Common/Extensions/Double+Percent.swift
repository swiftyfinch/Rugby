//
//  Double+Percent.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 23.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

extension Double {
    func outputPercent() -> String {
        String(Int(self * 100.0)) + "%"
    }
}
