// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ITestplanEditorMock: ITestplanEditor {

    // MARK: - expandTestplanPath

    var expandTestplanPathThrowableError: Error?
    var expandTestplanPathCallsCount = 0
    var expandTestplanPathCalled: Bool { expandTestplanPathCallsCount > 0 }
    var expandTestplanPathReceivedPath: String?
    var expandTestplanPathReceivedInvocations: [String] = []
    var expandTestplanPathReturnValue: String!
    var expandTestplanPathClosure: ((String) throws -> String)?

    func expandTestplanPath(_ path: String) throws -> String {
        expandTestplanPathCallsCount += 1
        expandTestplanPathReceivedPath = path
        expandTestplanPathReceivedInvocations.append(path)
        if let error = expandTestplanPathThrowableError {
            throw error
        }
        if let expandTestplanPathClosure = expandTestplanPathClosure {
            return try expandTestplanPathClosure(path)
        } else {
            return expandTestplanPathReturnValue
        }
    }

    // MARK: - createTestplan

    var createTestplanTestplanTemplatePathTestTargetsInFolderPathThrowableError: Error?
    var createTestplanTestplanTemplatePathTestTargetsInFolderPathCallsCount = 0
    var createTestplanTestplanTemplatePathTestTargetsInFolderPathCalled: Bool { createTestplanTestplanTemplatePathTestTargetsInFolderPathCallsCount > 0 }
    var createTestplanTestplanTemplatePathTestTargetsInFolderPathReceivedArguments: (testplanTemplatePath: String, testTargets: TargetsMap, folderPath: String)?
    var createTestplanTestplanTemplatePathTestTargetsInFolderPathReceivedInvocations: [(testplanTemplatePath: String, testTargets: TargetsMap, folderPath: String)] = []
    var createTestplanTestplanTemplatePathTestTargetsInFolderPathReturnValue: URL!
    var createTestplanTestplanTemplatePathTestTargetsInFolderPathClosure: ((String, TargetsMap, String) throws -> URL)?

    func createTestplan(testplanTemplatePath: String, testTargets: TargetsMap, inFolderPath folderPath: String) throws -> URL {
        createTestplanTestplanTemplatePathTestTargetsInFolderPathCallsCount += 1
        createTestplanTestplanTemplatePathTestTargetsInFolderPathReceivedArguments = (testplanTemplatePath: testplanTemplatePath, testTargets: testTargets, folderPath: folderPath)
        createTestplanTestplanTemplatePathTestTargetsInFolderPathReceivedInvocations.append((testplanTemplatePath: testplanTemplatePath, testTargets: testTargets, folderPath: folderPath))
        if let error = createTestplanTestplanTemplatePathTestTargetsInFolderPathThrowableError {
            throw error
        }
        if let createTestplanTestplanTemplatePathTestTargetsInFolderPathClosure = createTestplanTestplanTemplatePathTestTargetsInFolderPathClosure {
            return try createTestplanTestplanTemplatePathTestTargetsInFolderPathClosure(testplanTemplatePath, testTargets, folderPath)
        } else {
            return createTestplanTestplanTemplatePathTestTargetsInFolderPathReturnValue
        }
    }
}

// swiftlint:enable all
