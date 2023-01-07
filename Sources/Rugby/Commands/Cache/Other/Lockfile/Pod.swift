//
//  Pod.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 23.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

protocol Pod {
    var name: String { get }
    var checksum: Checksum { get }
}

struct LocalPod: Pod {
    let name: String
    let path: String
    let checksum: Checksum
	let isGitClean: Bool
}

struct RemotePod: Pod {
    let name: String
    let repo: String?
    let options: [String: String]
    let checksum: Checksum

    init(name: String,
         repo: String? = nil,
         options: [String: String] = [:],
         checksum: Checksum) {
        self.name = name
        self.repo = repo
        self.options = options
        self.checksum = checksum
    }
}
