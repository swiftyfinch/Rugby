//
//  Bool+IfTrue.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 01.04.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

extension Bool {
    func ifTrue(do job: () throws -> Void) rethrows {
        guard self else { return }
        try job()
    }

    func ifFalse(do job: () throws -> Void) rethrows {
        guard !self else { return }
        try job()
    }
}
