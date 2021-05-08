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
    let hideMetrics: Bool?
    let ignoreCache: Bool?
    let skipParents: Bool?
    let verbose: Bool?
}
