//
//  DropYML.swift
//  
//
//  Created by Vyacheslav Khorkov on 24.04.2021.
//

struct DropYML: Decodable {
    let targets: [String]?
    let invert: Bool?
    let project: String?
    let testFlight: Bool?
    let keepSources: Bool?
    let exclude: [String]?
    let hideMetrics: Bool?
    let verbose: Bool?
}
