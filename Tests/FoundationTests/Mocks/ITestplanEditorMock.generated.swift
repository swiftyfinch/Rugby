// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ITestplanEditorMock: ITestplanEditor {

    // MARK: - createTestplan

    var createTestplanWithRelativeTemplatePathTestTargetsInFolderPathThrowableError: Error?
    var createTestplanWithRelativeTemplatePathTestTargetsInFolderPathCallsCount = 0
    var createTestplanWithRelativeTemplatePathTestTargetsInFolderPathCalled: Bool { createTestplanWithRelativeTemplatePathTestTargetsInFolderPathCallsCount > 0 }
    var createTestplanWithRelativeTemplatePathTestTargetsInFolderPathReceivedArguments: (relativeTemplatePath: String, testTargets: TargetsMap, folderPath: String)?
    var createTestplanWithRelativeTemplatePathTestTargetsInFolderPathReceivedInvocations: [(relativeTemplatePath: String, testTargets: TargetsMap, folderPath: String)] = []
    var createTestplanWithRelativeTemplatePathTestTargetsInFolderPathReturnValue: URL!
    var createTestplanWithRelativeTemplatePathTestTargetsInFolderPathClosure: ((String, TargetsMap, String) throws -> URL)?

    func createTestplan(withRelativeTemplatePath relativeTemplatePath: String, testTargets: TargetsMap, inFolderPath folderPath: String) throws -> URL {
        if let error = createTestplanWithRelativeTemplatePathTestTargetsInFolderPathThrowableError {
            throw error
        }
        createTestplanWithRelativeTemplatePathTestTargetsInFolderPathCallsCount += 1
        createTestplanWithRelativeTemplatePathTestTargetsInFolderPathReceivedArguments = (relativeTemplatePath: relativeTemplatePath, testTargets: testTargets, folderPath: folderPath)
        createTestplanWithRelativeTemplatePathTestTargetsInFolderPathReceivedInvocations.append((relativeTemplatePath: relativeTemplatePath, testTargets: testTargets, folderPath: folderPath))
        if let createTestplanWithRelativeTemplatePathTestTargetsInFolderPathClosure = createTestplanWithRelativeTemplatePathTestTargetsInFolderPathClosure {
            return try createTestplanWithRelativeTemplatePathTestTargetsInFolderPathClosure(relativeTemplatePath, testTargets, folderPath)
        } else {
            return createTestplanWithRelativeTemplatePathTestTargetsInFolderPathReturnValue
        }
    }
}

// swiftlint:enable all
