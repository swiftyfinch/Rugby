// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import Fish

public final class IFileMock: IFile {

    public init() {}
    public var path: String {
        get { return underlyingPath }
        set(value) { underlyingPath = value }
    }
    public var underlyingPath: String!
    public var pathExtension: String {
        get { return underlyingPathExtension }
        set(value) { underlyingPathExtension = value }
    }
    public var underlyingPathExtension: String!
    public var name: String {
        get { return underlyingName }
        set(value) { underlyingName = value }
    }
    public var underlyingName: String!
    public var nameExcludingExtension: String {
        get { return underlyingNameExcludingExtension }
        set(value) { underlyingNameExcludingExtension = value }
    }
    public var underlyingNameExcludingExtension: String!
    public var parent: IFolder?

    // MARK: - append

    public var appendThrowableError: Error?
    public var appendCallsCount = 0
    public var appendCalled: Bool { appendCallsCount > 0 }
    public var appendReceivedText: String?
    public var appendReceivedInvocations: [String] = []
    public var appendClosure: ((String) throws -> Void)?

    public func append(_ text: String) throws {
        if let error = appendThrowableError {
            throw error
        }
        appendCallsCount += 1
        appendReceivedText = text
        appendReceivedInvocations.append(text)
        try appendClosure?(text)
    }

    // MARK: - write

    public var writeThrowableError: Error?
    public var writeCallsCount = 0
    public var writeCalled: Bool { writeCallsCount > 0 }
    public var writeReceivedText: String?
    public var writeReceivedInvocations: [String] = []
    public var writeClosure: ((String) throws -> Void)?

    public func write(_ text: String) throws {
        if let error = writeThrowableError {
            throw error
        }
        writeCallsCount += 1
        writeReceivedText = text
        writeReceivedInvocations.append(text)
        try writeClosure?(text)
    }

    // MARK: - read

    public var readThrowableError: Error?
    public var readCallsCount = 0
    public var readCalled: Bool { readCallsCount > 0 }
    public var readReturnValue: String!
    public var readClosure: (() throws -> String)?

    public func read() throws -> String {
        if let error = readThrowableError {
            throw error
        }
        readCallsCount += 1
        if let readClosure = readClosure {
            return try readClosure()
        } else {
            return readReturnValue
        }
    }

    // MARK: - readData

    public var readDataThrowableError: Error?
    public var readDataCallsCount = 0
    public var readDataCalled: Bool { readDataCallsCount > 0 }
    public var readDataReturnValue: Data!
    public var readDataClosure: (() throws -> Data)?

    public func readData() throws -> Data {
        if let error = readDataThrowableError {
            throw error
        }
        readDataCallsCount += 1
        if let readDataClosure = readDataClosure {
            return try readDataClosure()
        } else {
            return readDataReturnValue
        }
    }

    // MARK: - creationDate

    public var creationDateThrowableError: Error?
    public var creationDateCallsCount = 0
    public var creationDateCalled: Bool { creationDateCallsCount > 0 }
    public var creationDateReturnValue: Date!
    public var creationDateClosure: (() throws -> Date)?

    public func creationDate() throws -> Date {
        if let error = creationDateThrowableError {
            throw error
        }
        creationDateCallsCount += 1
        if let creationDateClosure = creationDateClosure {
            return try creationDateClosure()
        } else {
            return creationDateReturnValue
        }
    }

    // MARK: - size

    public var sizeThrowableError: Error?
    public var sizeCallsCount = 0
    public var sizeCalled: Bool { sizeCallsCount > 0 }
    public var sizeReturnValue: Int!
    public var sizeClosure: (() throws -> Int)?

    public func size() throws -> Int {
        if let error = sizeThrowableError {
            throw error
        }
        sizeCallsCount += 1
        if let sizeClosure = sizeClosure {
            return try sizeClosure()
        } else {
            return sizeReturnValue
        }
    }

    // MARK: - relativePath

    public var relativePathToCallsCount = 0
    public var relativePathToCalled: Bool { relativePathToCallsCount > 0 }
    public var relativePathToReceivedFolder: IFolder?
    public var relativePathToReceivedInvocations: [IFolder] = []
    public var relativePathToReturnValue: String!
    public var relativePathToClosure: ((IFolder) -> String)?

    public func relativePath(to folder: IFolder) -> String {
        relativePathToCallsCount += 1
        relativePathToReceivedFolder = folder
        relativePathToReceivedInvocations.append(folder)
        if let relativePathToClosure = relativePathToClosure {
            return relativePathToClosure(folder)
        } else {
            return relativePathToReturnValue
        }
    }

    // MARK: - delete

    public var deleteThrowableError: Error?
    public var deleteCallsCount = 0
    public var deleteCalled: Bool { deleteCallsCount > 0 }
    public var deleteClosure: (() throws -> Void)?

    public func delete() throws {
        if let error = deleteThrowableError {
            throw error
        }
        deleteCallsCount += 1
        try deleteClosure?()
    }

    // MARK: - move

    public var moveToReplaceThrowableError: Error?
    public var moveToReplaceCallsCount = 0
    public var moveToReplaceCalled: Bool { moveToReplaceCallsCount > 0 }
    public var moveToReplaceReceivedArguments: (folderPath: String, replace: Bool)?
    public var moveToReplaceReceivedInvocations: [(folderPath: String, replace: Bool)] = []
    public var moveToReplaceClosure: ((String, Bool) throws -> Void)?

    public func move(to folderPath: String, replace: Bool) throws {
        if let error = moveToReplaceThrowableError {
            throw error
        }
        moveToReplaceCallsCount += 1
        moveToReplaceReceivedArguments = (folderPath: folderPath, replace: replace)
        moveToReplaceReceivedInvocations.append((folderPath: folderPath, replace: replace))
        try moveToReplaceClosure?(folderPath, replace)
    }

    // MARK: - copy

    public var copyToReplaceThrowableError: Error?
    public var copyToReplaceCallsCount = 0
    public var copyToReplaceCalled: Bool { copyToReplaceCallsCount > 0 }
    public var copyToReplaceReceivedArguments: (folderPath: String, replace: Bool)?
    public var copyToReplaceReceivedInvocations: [(folderPath: String, replace: Bool)] = []
    public var copyToReplaceClosure: ((String, Bool) throws -> Void)?

    public func copy(to folderPath: String, replace: Bool) throws {
        if let error = copyToReplaceThrowableError {
            throw error
        }
        copyToReplaceCallsCount += 1
        copyToReplaceReceivedArguments = (folderPath: folderPath, replace: replace)
        copyToReplaceReceivedInvocations.append((folderPath: folderPath, replace: replace))
        try copyToReplaceClosure?(folderPath, replace)
    }
}

// swiftlint:enable all
