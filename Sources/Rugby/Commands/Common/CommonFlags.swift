//
//  CommonFlags.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 05.11.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

enum CommonFlags {
    static let version = "--version"
    static let help: Set = ["-h", "--help"]
    static let all = help.union([version])
}
