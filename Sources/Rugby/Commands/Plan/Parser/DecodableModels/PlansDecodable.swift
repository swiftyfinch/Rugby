//
//  PlansDecodable.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.11.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

struct PlansDecodable: Decodable {
    let name: String
}

extension PlansReference {
    init(from decodable: PlansDecodable) {
        self.name = decodable.name
    }
}
