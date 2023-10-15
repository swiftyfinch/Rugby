// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import Fish

public final class IFolderMock: IFolder {

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

    // MARK: - subpath

    public var subpathCallsCount = 0
    public var subpathCalled: Bool { subpathCallsCount > 0 }
    public var subpathReceivedPathComponents: [String]!
    public var subpathReceivedInvocations: [[String]] = []
    public var subpathReturnValue: String!
    public var subpathClosure: (([String]) -> String)?

    public func subpath(_ pathComponents: String...) -> String {
        subpathCallsCount += 1
        subpathReceivedPathComponents = pathComponents
        subpathReceivedInvocations.append(pathComponents)
        if let subpathClosure = subpathClosure {
            return subpathClosure(pathComponents)
        } else {
            return subpathReturnValue
        }
    }

    // MARK: - file

    public var fileNamedThrowableError: Error?
    public var fileNamedCallsCount = 0
    public var fileNamedCalled: Bool { fileNamedCallsCount > 0 }
    public var fileNamedReceivedName: String?
    public var fileNamedReceivedInvocations: [String] = []
    public var fileNamedReturnValue: IFile!
    public var fileNamedClosure: ((String) throws -> IFile)?

    public func file(named name: String) throws -> IFile {
        if let error = fileNamedThrowableError {
            throw error
        }
        fileNamedCallsCount += 1
        fileNamedReceivedName = name
        fileNamedReceivedInvocations.append(name)
        if let fileNamedClosure = fileNamedClosure {
            return try fileNamedClosure(name)
        } else {
            return fileNamedReturnValue
        }
    }

    // MARK: - files

    public var filesDeepThrowableError: Error?
    public var filesDeepCallsCount = 0
    public var filesDeepCalled: Bool { filesDeepCallsCount > 0 }
    public var filesDeepReceivedDeep: Bool?
    public var filesDeepReceivedInvocations: [Bool] = []
    public var filesDeepReturnValue: [IFile]!
    public var filesDeepClosure: ((Bool) throws -> [IFile])?

    public func files(deep: Bool) throws -> [IFile] {
        if let error = filesDeepThrowableError {
            throw error
        }
        filesDeepCallsCount += 1
        filesDeepReceivedDeep = deep
        filesDeepReceivedInvocations.append(deep)
        if let filesDeepClosure = filesDeepClosure {
            return try filesDeepClosure(deep)
        } else {
            return filesDeepReturnValue
        }
    }

    // MARK: - folders

    public var foldersDeepThrowableError: Error?
    public var foldersDeepCallsCount = 0
    public var foldersDeepCalled: Bool { foldersDeepCallsCount > 0 }
    public var foldersDeepReceivedDeep: Bool?
    public var foldersDeepReceivedInvocations: [Bool] = []
    public var foldersDeepReturnValue: [IFolder]!
    public var foldersDeepClosure: ((Bool) throws -> [IFolder])?

    public func folders(deep: Bool) throws -> [IFolder] {
        if let error = foldersDeepThrowableError {
            throw error
        }
        foldersDeepCallsCount += 1
        foldersDeepReceivedDeep = deep
        foldersDeepReceivedInvocations.append(deep)
        if let foldersDeepClosure = foldersDeepClosure {
            return try foldersDeepClosure(deep)
        } else {
            return foldersDeepReturnValue
        }
    }

    // MARK: - createFile

    public var createFileNamedContentsThrowableError: Error?
    public var createFileNamedContentsCallsCount = 0
    public var createFileNamedContentsCalled: Bool { createFileNamedContentsCallsCount > 0 }
    public var createFileNamedContentsReceivedArguments: (name: String, text: String?)?
    public var createFileNamedContentsReceivedInvocations: [(name: String, text: String?)] = []
    public var createFileNamedContentsReturnValue: IFile!
    public var createFileNamedContentsClosure: ((String, String?) throws -> IFile)?

    @discardableResult
    public func createFile(named name: String, contents text: String?) throws -> IFile {
        if let error = createFileNamedContentsThrowableError {
            throw error
        }
        createFileNamedContentsCallsCount += 1
        createFileNamedContentsReceivedArguments = (name: name, text: text)
        createFileNamedContentsReceivedInvocations.append((name: name, text: text))
        if let createFileNamedContentsClosure = createFileNamedContentsClosure {
            return try createFileNamedContentsClosure(name, text)
        } else {
            return createFileNamedContentsReturnValue
        }
    }

    // MARK: - createFolder

    public var createFolderNamedThrowableError: Error?
    public var createFolderNamedCallsCount = 0
    public var createFolderNamedCalled: Bool { createFolderNamedCallsCount > 0 }
    public var createFolderNamedReceivedName: String?
    public var createFolderNamedReceivedInvocations: [String] = []
    public var createFolderNamedReturnValue: IFolder!
    public var createFolderNamedClosure: ((String) throws -> IFolder)?

    @discardableResult
    public func createFolder(named name: String) throws -> IFolder {
        if let error = createFolderNamedThrowableError {
            throw error
        }
        createFolderNamedCallsCount += 1
        createFolderNamedReceivedName = name
        createFolderNamedReceivedInvocations.append(name)
        if let createFolderNamedClosure = createFolderNamedClosure {
            return try createFolderNamedClosure(name)
        } else {
            return createFolderNamedReturnValue
        }
    }

    // MARK: - isEmpty

    public var isEmptyThrowableError: Error?
    public var isEmptyCallsCount = 0
    public var isEmptyCalled: Bool { isEmptyCallsCount > 0 }
    public var isEmptyReturnValue: Bool!
    public var isEmptyClosure: (() throws -> Bool)?

    public func isEmpty() throws -> Bool {
        if let error = isEmptyThrowableError {
            throw error
        }
        isEmptyCallsCount += 1
        if let isEmptyClosure = isEmptyClosure {
            return try isEmptyClosure()
        } else {
            return isEmptyReturnValue
        }
    }

    // MARK: - emptyFolder

    public var emptyFolderThrowableError: Error?
    public var emptyFolderCallsCount = 0
    public var emptyFolderCalled: Bool { emptyFolderCallsCount > 0 }
    public var emptyFolderClosure: (() throws -> Void)?

    public func emptyFolder() throws {
        if let error = emptyFolderThrowableError {
            throw error
        }
        emptyFolderCallsCount += 1
        try emptyFolderClosure?()
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
