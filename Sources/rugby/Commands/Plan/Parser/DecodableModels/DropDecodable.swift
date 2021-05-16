//
//  DropDecodable.swift
//  
//
//  Created by Vyacheslav Khorkov on 24.04.2021.
//

struct DropDecodable: Decodable {
    let targets: [String]?
    let invert: Bool?
    let project: String?
    let testFlight: Bool?
    let keepSources: Bool?
    let exclude: [String]?
    let bell: Bool?
    let hideMetrics: Bool?
    let verbose: Bool?
}

extension Drop {
    init(from decodable: DropDecodable) {
        self.targets = decodable.targets ?? []
        self.invert = decodable.invert ?? false
        self.project = decodable.project ?? .podsProject
        self.testFlight = decodable.testFlight ?? false
        self.keepSources = decodable.keepSources ?? false
        self.exclude = decodable.exclude ?? []
        self.bell = decodable.bell ?? true
        self.hideMetrics = decodable.hideMetrics ?? false
        self.verbose = decodable.verbose ?? false
    }
}
