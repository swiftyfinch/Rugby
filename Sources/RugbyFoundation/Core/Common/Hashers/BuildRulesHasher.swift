//
//  BuildRulesHasher.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 03.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

final class BuildRulesHasher {
    private let foundationHasher: FoundationHasher
    private let fileContentHasher: FileContentHasher

    init(foundationHasher: FoundationHasher,
         fileContentHasher: FileContentHasher) {
        self.foundationHasher = foundationHasher
        self.fileContentHasher = fileContentHasher
    }

    func hashContext(_ buildRules: [BuildRule]) async throws -> [Any] {
        try await buildRules.concurrentMap(hashContext)
    }

    // MARK: - Private

    private func hashContext(_ buildRule: BuildRule) async throws -> [String: Any?] {
        await ["name": buildRule.name,
               "compilerSpec": buildRule.compilerSpec,
               "filePatterns": buildRule.filePatterns,
               "fileType": buildRule.fileType,
               "isEditable": buildRule.isEditable,
               "outputFiles": try fileContentHasher.hashContext(paths: buildRule.outputFiles),
               "inputFiles": try buildRule.inputFiles.map(fileContentHasher.hashContext),
               "outputFilesCompilerFlags": buildRule.outputFilesCompilerFlags,
               "script": buildRule.script,
               "runOncePerArchitecture": buildRule.runOncePerArchitecture]
    }
}
