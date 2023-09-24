//
//  CocoaPodsScriptsHasher.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 03.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Fish

final class CocoaPodsScriptsHasher {
    private let fileContentHasher: FileContentHasher

    init(fileContentHasher: FileContentHasher) {
        self.fileContentHasher = fileContentHasher
    }

    func hashContext(_ target: Target) async throws -> [String] {
        let paths = [target.resourcesScriptPath, target.frameworksScriptPath]
            .compactMap()
            .filter(File.isExist)
        return try await fileContentHasher.hashContext(paths: paths)
    }
}
