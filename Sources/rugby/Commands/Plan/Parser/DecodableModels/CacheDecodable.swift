//
//  CacheDecodable.swift
//  
//
//  Created by Vyacheslav Khorkov on 24.04.2021.
//

struct CacheDecodable: Decodable {
    let arch: String?
    let sdk: SDK?
    let keepSources: Bool?
    let exclude: [String]?
    let ignoreChecksums: Bool?
    let graph: Bool?
    let focus: [String]?
    let bell: Bool?
    let hideMetrics: Bool?
    let verbose: Bool?
}

extension Cache {
    init(from decodable: CacheDecodable) {
        self.arch = decodable.arch
        self.sdk = decodable.sdk ?? .sim
        self.keepSources = decodable.keepSources ?? false
        self.exclude = decodable.exclude ?? []
        self.ignoreChecksums = decodable.ignoreChecksums ?? false
        self.focus = decodable.focus ?? []
        self.graph = decodable.graph ?? false
        self.bell = decodable.bell ?? true
        self.hideMetrics = decodable.hideMetrics ?? false
        self.verbose = decodable.verbose ?? false
    }
}
