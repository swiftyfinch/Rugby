//
//  ShellDecodable.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 07.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

struct ShellDecodable: Decodable {
    let run: String
    @BoolableIntDecodable var verbose: Int?
}

extension Shell {
    init(from decodable: ShellDecodable) {
        self.run = decodable.run
        self.verbose = decodable.verbose ?? 0
    }
}
