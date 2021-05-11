//
//  FocusDecodable.swift
//  
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//

struct FocusDecodable: Decodable {
    let targets: [String]?
    let project: String?
    let testFlight: Bool?
    let keepSources: Bool?
    let hideMetrics: Bool?
    let verbose: Bool?
}

extension Focus {
    init(from decodable: FocusDecodable) {
        self.targets = decodable.targets ?? []
        self.project = decodable.project ?? .podsProject
        self.testFlight = decodable.testFlight ?? false
        self.keepSources = decodable.keepSources ?? false
        self.hideMetrics = decodable.hideMetrics ?? false
        self.verbose = decodable.verbose ?? false
    }
}
