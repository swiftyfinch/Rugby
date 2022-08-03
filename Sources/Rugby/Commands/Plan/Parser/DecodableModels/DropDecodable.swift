//
//  DropDecodable.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 24.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
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
    @BoolableIntDecodable var verbose: Int?
    let quiet: Bool?
    let nonInteractive: Bool?
}

extension Drop {
    init(from decodable: DropDecodable) {
        self.targets = decodable.targets ?? []
        self.invert = decodable.invert ?? false
        self.project = decodable.project ?? .podsProject
        self.testFlight = decodable.testFlight ?? false
        self.keepSources = decodable.keepSources ?? false
        self.exclude = decodable.exclude ?? []

        self.flags = .init()
        self.flags.bell = decodable.bell ?? true
        self.flags.hideMetrics = decodable.hideMetrics ?? false
        self.flags.verbose = decodable.verbose ?? 0
        self.flags.quiet = decodable.quiet ?? false
        self.flags.nonInteractive = decodable.nonInteractive ?? false
    }
}
