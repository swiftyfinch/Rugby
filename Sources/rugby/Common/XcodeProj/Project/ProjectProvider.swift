//
//  ProjectProvider.swift
//  
//
//  Created by Vyacheslav Khorkov on 16.05.2021.
//

import XcodeProj

final class ProjectProvider {
    static let shared = ProjectProvider()
    private var cache: [String: XcodeProj] = [:]

    // Singleton
    private init() {}

    func readProject(_ path: String) throws -> XcodeProj {
        if let cachedProject = cache[path] { return cachedProject }
        let project = try XcodeProj(pathString: path)
        cache[path] = project
        return project
    }
}
