//
//  Set+Contains.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 29.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Set {
    func contains(_ member: Element?) -> Bool {
        guard let member = member else { return false }
        return contains(member)
    }
}
