// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation
import XcodeProj

final class IProjectMock: IProject {
    var uuidCallsCount = 0
    var uuidCalled: Bool {
        return uuidCallsCount > 0
    }

    var uuid: String {
        get throws {
            if let error = uuidThrowableError {
                throw error
            }
            uuidCallsCount += 1
            if let uuidClosure = uuidClosure {
                return try uuidClosure()
            } else {
                return underlyingUuid
            }
        }
    }
    var underlyingUuid: String!
    var uuidThrowableError: Error?
    var uuidClosure: (() throws -> String)?
    var xcodeProj: XcodeProj {
        get { return underlyingXcodeProj }
        set(value) { underlyingXcodeProj = value }
    }
    var underlyingXcodeProj: XcodeProj!
    var reference: PBXFileReference?
    var path: String {
        get { return underlyingPath }
        set(value) { underlyingPath = value }
    }
    var underlyingPath: String!
    var pbxProj: PBXProj {
        get { return underlyingPbxProj }
        set(value) { underlyingPbxProj = value }
    }
    var underlyingPbxProj: PBXProj!
    var pbxProjectCallsCount = 0
    var pbxProjectCalled: Bool {
        return pbxProjectCallsCount > 0
    }

    var pbxProject: PBXProject {
        get throws {
            if let error = pbxProjectThrowableError {
                throw error
            }
            pbxProjectCallsCount += 1
            if let pbxProjectClosure = pbxProjectClosure {
                return try pbxProjectClosure()
            } else {
                return underlyingPbxProject
            }
        }
    }
    var underlyingPbxProject: PBXProject!
    var pbxProjectThrowableError: Error?
    var pbxProjectClosure: (() throws -> PBXProject)?
    var buildConfigurationListCallsCount = 0
    var buildConfigurationListCalled: Bool {
        return buildConfigurationListCallsCount > 0
    }

    var buildConfigurationList: XCConfigurationList {
        get throws {
            if let error = buildConfigurationListThrowableError {
                throw error
            }
            buildConfigurationListCallsCount += 1
            if let buildConfigurationListClosure = buildConfigurationListClosure {
                return try buildConfigurationListClosure()
            } else {
                return underlyingBuildConfigurationList
            }
        }
    }
    var underlyingBuildConfigurationList: XCConfigurationList!
    var buildConfigurationListThrowableError: Error?
    var buildConfigurationListClosure: (() throws -> XCConfigurationList)?
    var buildConfigurationsCallsCount = 0
    var buildConfigurationsCalled: Bool {
        return buildConfigurationsCallsCount > 0
    }

    var buildConfigurations: [String: XCBuildConfiguration] {
        get async throws {
            if let error = buildConfigurationsThrowableError {
                throw error
            }
            buildConfigurationsCallsCount += 1
            if let buildConfigurationsClosure = buildConfigurationsClosure {
                return try await buildConfigurationsClosure()
            } else {
                return underlyingBuildConfigurations
            }
        }
    }
    var underlyingBuildConfigurations: [String: XCBuildConfiguration]!
    var buildConfigurationsThrowableError: Error?
    var buildConfigurationsClosure: (() async throws -> [String: XCBuildConfiguration])?
}

// swiftlint:enable all
