//
//  FocusDecodable.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

struct FocusDecodable: Decodable {
    let targets: [String]?
    let project: String?
    let testFlight: Bool?
    let keepSources: Bool?
    let bell: Bool?
    let hideMetrics: Bool?
    @BoolableIntDecodable var verbose: Int?
}

extension Focus {
    init(from decodable: FocusDecodable) {
        self.targets = decodable.targets ?? []
        self.project = decodable.project ?? .podsProject
        self.testFlight = decodable.testFlight ?? false
        self.keepSources = decodable.keepSources ?? false

        self.flags = .init()
        self.flags.bell = decodable.bell ?? true
        self.flags.hideMetrics = decodable.hideMetrics ?? false
        self.flags.verbose = decodable.verbose ?? 0
    }
}
