//
//  Scheme.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 29.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

struct Scheme {
    let xcscheme: XCScheme
    let path: String

    var name: String { xcscheme.name }

    init(path: String) throws {
        self.xcscheme = try XCScheme(path: .init(path))
        self.path = path
    }
}

// MARK: - Hashable

extension Scheme: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}
