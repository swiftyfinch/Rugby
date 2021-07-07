//
//  CacheDecodable.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 24.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

struct CacheDecodable: Decodable {
    let arch: String?
    let sdk: SDK?
    let keepSources: Bool?
    let exclude: [String]?
    let ignoreChecksums: Bool?
    let include: [String]?
    let focus: [String]?
    let graph: Bool?
    let bell: Bool?
    let hideMetrics: Bool?
    @BoolableIntDecodable var verbose: Int?
}

extension Cache {
    init(from decodable: CacheDecodable) {
        self.arch = decodable.arch
        self.sdk = decodable.sdk ?? .sim
        self.keepSources = decodable.keepSources ?? false
        self.exclude = decodable.exclude ?? []
        self.ignoreChecksums = decodable.ignoreChecksums ?? false
        self.include = decodable.include ?? []
        self.focus = decodable.focus ?? []
        self.graph = decodable.graph ?? true
        self.bell = decodable.bell ?? true
        self.hideMetrics = decodable.hideMetrics ?? false
        self.verbose = decodable.verbose ?? 0
    }
}
