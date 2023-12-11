// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import RugbyFoundation

public final class IEnvironmentMock: IEnvironment {

    public init() {}
    public var all: [String: String] = [:]
    public var keepHashYamls: Bool {
        get { return underlyingKeepHashYamls }
        set(value) { underlyingKeepHashYamls = value }
    }
    public var underlyingKeepHashYamls: Bool!
    public var printMissingBinaries: Bool {
        get { return underlyingPrintMissingBinaries }
        set(value) { underlyingPrintMissingBinaries = value }
    }
    public var underlyingPrintMissingBinaries: Bool!
    public var sharedFolderParentPath: String {
        get { return underlyingSharedFolderParentPath }
        set(value) { underlyingSharedFolderParentPath = value }
    }
    public var underlyingSharedFolderParentPath: String!
}

// swiftlint:enable all
