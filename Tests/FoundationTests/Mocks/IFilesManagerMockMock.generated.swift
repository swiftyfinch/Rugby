// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import Fish

final class IFilesManagerMockMock: IFilesManagerMock {

    // MARK: - file

    public var fileAtThrowableError: Error?
    public var fileAtCallsCount = 0
    public var fileAtCalled: Bool { fileAtCallsCount > 0 }
    public var fileAtReceivedPath: String?
    public var fileAtReceivedInvocations: [String] = []
    public var fileAtReturnValue: IFile!
    public var fileAtClosure: ((String) throws -> IFile)?

    public func file(at path: String) throws -> IFile {
        if let error = fileAtThrowableError {
            throw error
        }
        fileAtCallsCount += 1
        fileAtReceivedPath = path
        fileAtReceivedInvocations.append(path)
        if let fileAtClosure = fileAtClosure {
            return try fileAtClosure(path)
        } else {
            return fileAtReturnValue
        }
    }

    // MARK: - files

    public var filesAtDeepThrowableError: Error?
    public var filesAtDeepCallsCount = 0
    public var filesAtDeepCalled: Bool { filesAtDeepCallsCount > 0 }
    public var filesAtDeepReceivedArguments: (path: String, deep: Bool)?
    public var filesAtDeepReceivedInvocations: [(path: String, deep: Bool)] = []
    public var filesAtDeepReturnValue: [IFile]!
    public var filesAtDeepClosure: ((String, Bool) throws -> [IFile])?

    public func files(at path: String, deep: Bool) throws -> [IFile] {
        if let error = filesAtDeepThrowableError {
            throw error
        }
        filesAtDeepCallsCount += 1
        filesAtDeepReceivedArguments = (path: path, deep: deep)
        filesAtDeepReceivedInvocations.append((path: path, deep: deep))
        if let filesAtDeepClosure = filesAtDeepClosure {
            return try filesAtDeepClosure(path, deep)
        } else {
            return filesAtDeepReturnValue
        }
    }

    // MARK: - createFile

    public var createFileAtContentsThrowableError: Error?
    public var createFileAtContentsCallsCount = 0
    public var createFileAtContentsCalled: Bool { createFileAtContentsCallsCount > 0 }
    public var createFileAtContentsReceivedArguments: (path: String, text: String?)?
    public var createFileAtContentsReceivedInvocations: [(path: String, text: String?)] = []
    public var createFileAtContentsReturnValue: IFile!
    public var createFileAtContentsClosure: ((String, String?) throws -> IFile)?

    @discardableResult
    public func createFile(at path: String, contents text: String?) throws -> IFile {
        if let error = createFileAtContentsThrowableError {
            throw error
        }
        createFileAtContentsCallsCount += 1
        createFileAtContentsReceivedArguments = (path: path, text: text)
        createFileAtContentsReceivedInvocations.append((path: path, text: text))
        if let createFileAtContentsClosure = createFileAtContentsClosure {
            return try createFileAtContentsClosure(path, text)
        } else {
            return createFileAtContentsReturnValue
        }
    }

    // MARK: - append

    public var appendToThrowableError: Error?
    public var appendToCallsCount = 0
    public var appendToCalled: Bool { appendToCallsCount > 0 }
    public var appendToReceivedArguments: (text: String, file: URL)?
    public var appendToReceivedInvocations: [(text: String, file: URL)] = []
    public var appendToClosure: ((String, URL) throws -> Void)?

    public func append(_ text: String, to file: URL) throws {
        if let error = appendToThrowableError {
            throw error
        }
        appendToCallsCount += 1
        appendToReceivedArguments = (text: text, file: file)
        appendToReceivedInvocations.append((text: text, file: file))
        try appendToClosure?(text, file)
    }

    // MARK: - write

    public var writeToThrowableError: Error?
    public var writeToCallsCount = 0
    public var writeToCalled: Bool { writeToCallsCount > 0 }
    public var writeToReceivedArguments: (text: String, file: URL)?
    public var writeToReceivedInvocations: [(text: String, file: URL)] = []
    public var writeToClosure: ((String, URL) throws -> Void)?

    public func write(_ text: String, to file: URL) throws {
        if let error = writeToThrowableError {
            throw error
        }
        writeToCallsCount += 1
        writeToReceivedArguments = (text: text, file: file)
        writeToReceivedInvocations.append((text: text, file: file))
        try writeToClosure?(text, file)
    }

    // MARK: - read

    public var readFileThrowableError: Error?
    public var readFileCallsCount = 0
    public var readFileCalled: Bool { readFileCallsCount > 0 }
    public var readFileReceivedFile: URL?
    public var readFileReceivedInvocations: [URL] = []
    public var readFileReturnValue: String!
    public var readFileClosure: ((URL) throws -> String)?

    public func read(file: URL) throws -> String {
        if let error = readFileThrowableError {
            throw error
        }
        readFileCallsCount += 1
        readFileReceivedFile = file
        readFileReceivedInvocations.append(file)
        if let readFileClosure = readFileClosure {
            return try readFileClosure(file)
        } else {
            return readFileReturnValue
        }
    }

    // MARK: - readData

    public var readDataFileThrowableError: Error?
    public var readDataFileCallsCount = 0
    public var readDataFileCalled: Bool { readDataFileCallsCount > 0 }
    public var readDataFileReceivedFile: URL?
    public var readDataFileReceivedInvocations: [URL] = []
    public var readDataFileReturnValue: Data!
    public var readDataFileClosure: ((URL) throws -> Data)?

    public func readData(file: URL) throws -> Data {
        if let error = readDataFileThrowableError {
            throw error
        }
        readDataFileCallsCount += 1
        readDataFileReceivedFile = file
        readDataFileReceivedInvocations.append(file)
        if let readDataFileClosure = readDataFileClosure {
            return try readDataFileClosure(file)
        } else {
            return readDataFileReturnValue
        }
    }

    // MARK: - currentFolder

    public var currentFolderThrowableError: Error?
    public var currentFolderCallsCount = 0
    public var currentFolderCalled: Bool { currentFolderCallsCount > 0 }
    public var currentFolderReturnValue: IFolder!
    public var currentFolderClosure: (() throws -> IFolder)?

    public func currentFolder() throws -> IFolder {
        if let error = currentFolderThrowableError {
            throw error
        }
        currentFolderCallsCount += 1
        if let currentFolderClosure = currentFolderClosure {
            return try currentFolderClosure()
        } else {
            return currentFolderReturnValue
        }
    }

    // MARK: - homeFolder

    public var homeFolderThrowableError: Error?
    public var homeFolderCallsCount = 0
    public var homeFolderCalled: Bool { homeFolderCallsCount > 0 }
    public var homeFolderReturnValue: IFolder!
    public var homeFolderClosure: (() throws -> IFolder)?

    public func homeFolder() throws -> IFolder {
        if let error = homeFolderThrowableError {
            throw error
        }
        homeFolderCallsCount += 1
        if let homeFolderClosure = homeFolderClosure {
            return try homeFolderClosure()
        } else {
            return homeFolderReturnValue
        }
    }

    // MARK: - isFolder

    public var isFolderAtCallsCount = 0
    public var isFolderAtCalled: Bool { isFolderAtCallsCount > 0 }
    public var isFolderAtReceivedPath: String?
    public var isFolderAtReceivedInvocations: [String] = []
    public var isFolderAtReturnValue: Bool!
    public var isFolderAtClosure: ((String) -> Bool)?

    public func isFolder(at path: String) -> Bool {
        isFolderAtCallsCount += 1
        isFolderAtReceivedPath = path
        isFolderAtReceivedInvocations.append(path)
        if let isFolderAtClosure = isFolderAtClosure {
            return isFolderAtClosure(path)
        } else {
            return isFolderAtReturnValue
        }
    }

    // MARK: - folder

    public var folderAtThrowableError: Error?
    public var folderAtCallsCount = 0
    public var folderAtCalled: Bool { folderAtCallsCount > 0 }
    public var folderAtReceivedPath: String?
    public var folderAtReceivedInvocations: [String] = []
    public var folderAtReturnValue: IFolder!
    public var folderAtClosure: ((String) throws -> IFolder)?

    public func folder(at path: String) throws -> IFolder {
        if let error = folderAtThrowableError {
            throw error
        }
        folderAtCallsCount += 1
        folderAtReceivedPath = path
        folderAtReceivedInvocations.append(path)
        if let folderAtClosure = folderAtClosure {
            return try folderAtClosure(path)
        } else {
            return folderAtReturnValue
        }
    }

    // MARK: - folders

    public var foldersAtDeepThrowableError: Error?
    public var foldersAtDeepCallsCount = 0
    public var foldersAtDeepCalled: Bool { foldersAtDeepCallsCount > 0 }
    public var foldersAtDeepReceivedArguments: (path: String, deep: Bool)?
    public var foldersAtDeepReceivedInvocations: [(path: String, deep: Bool)] = []
    public var foldersAtDeepReturnValue: [IFolder]!
    public var foldersAtDeepClosure: ((String, Bool) throws -> [IFolder])?

    public func folders(at path: String, deep: Bool) throws -> [IFolder] {
        if let error = foldersAtDeepThrowableError {
            throw error
        }
        foldersAtDeepCallsCount += 1
        foldersAtDeepReceivedArguments = (path: path, deep: deep)
        foldersAtDeepReceivedInvocations.append((path: path, deep: deep))
        if let foldersAtDeepClosure = foldersAtDeepClosure {
            return try foldersAtDeepClosure(path, deep)
        } else {
            return foldersAtDeepReturnValue
        }
    }

    // MARK: - createFolder

    public var createFolderAtThrowableError: Error?
    public var createFolderAtCallsCount = 0
    public var createFolderAtCalled: Bool { createFolderAtCallsCount > 0 }
    public var createFolderAtReceivedPath: String?
    public var createFolderAtReceivedInvocations: [String] = []
    public var createFolderAtReturnValue: IFolder!
    public var createFolderAtClosure: ((String) throws -> IFolder)?

    @discardableResult
    public func createFolder(at path: String) throws -> IFolder {
        if let error = createFolderAtThrowableError {
            throw error
        }
        createFolderAtCallsCount += 1
        createFolderAtReceivedPath = path
        createFolderAtReceivedInvocations.append(path)
        if let createFolderAtClosure = createFolderAtClosure {
            return try createFolderAtClosure(path)
        } else {
            return createFolderAtReturnValue
        }
    }

    // MARK: - isFolderEmpty

    public var isFolderEmptyAtThrowableError: Error?
    public var isFolderEmptyAtCallsCount = 0
    public var isFolderEmptyAtCalled: Bool { isFolderEmptyAtCallsCount > 0 }
    public var isFolderEmptyAtReceivedPath: String?
    public var isFolderEmptyAtReceivedInvocations: [String] = []
    public var isFolderEmptyAtReturnValue: Bool!
    public var isFolderEmptyAtClosure: ((String) throws -> Bool)?

    public func isFolderEmpty(at path: String) throws -> Bool {
        if let error = isFolderEmptyAtThrowableError {
            throw error
        }
        isFolderEmptyAtCallsCount += 1
        isFolderEmptyAtReceivedPath = path
        isFolderEmptyAtReceivedInvocations.append(path)
        if let isFolderEmptyAtClosure = isFolderEmptyAtClosure {
            return try isFolderEmptyAtClosure(path)
        } else {
            return isFolderEmptyAtReturnValue
        }
    }

    // MARK: - emptyFolder

    public var emptyFolderAtThrowableError: Error?
    public var emptyFolderAtCallsCount = 0
    public var emptyFolderAtCalled: Bool { emptyFolderAtCallsCount > 0 }
    public var emptyFolderAtReceivedPath: String?
    public var emptyFolderAtReceivedInvocations: [String] = []
    public var emptyFolderAtClosure: ((String) throws -> Void)?

    public func emptyFolder(at path: String) throws {
        if let error = emptyFolderAtThrowableError {
            throw error
        }
        emptyFolderAtCallsCount += 1
        emptyFolderAtReceivedPath = path
        emptyFolderAtReceivedInvocations.append(path)
        try emptyFolderAtClosure?(path)
    }

    // MARK: - folderSize

    public var folderSizeAtThrowableError: Error?
    public var folderSizeAtCallsCount = 0
    public var folderSizeAtCalled: Bool { folderSizeAtCallsCount > 0 }
    public var folderSizeAtReceivedPath: String?
    public var folderSizeAtReceivedInvocations: [String] = []
    public var folderSizeAtReturnValue: Int!
    public var folderSizeAtClosure: ((String) throws -> Int)?

    public func folderSize(at path: String) throws -> Int {
        if let error = folderSizeAtThrowableError {
            throw error
        }
        folderSizeAtCallsCount += 1
        folderSizeAtReceivedPath = path
        folderSizeAtReceivedInvocations.append(path)
        if let folderSizeAtClosure = folderSizeAtClosure {
            return try folderSizeAtClosure(path)
        } else {
            return folderSizeAtReturnValue
        }
    }

    // MARK: - isItemExist

    public var isItemExistAtCallsCount = 0
    public var isItemExistAtCalled: Bool { isItemExistAtCallsCount > 0 }
    public var isItemExistAtReceivedPath: String?
    public var isItemExistAtReceivedInvocations: [String] = []
    public var isItemExistAtReturnValue: Bool!
    public var isItemExistAtClosure: ((String) -> Bool)?

    public func isItemExist(at path: String) -> Bool {
        isItemExistAtCallsCount += 1
        isItemExistAtReceivedPath = path
        isItemExistAtReceivedInvocations.append(path)
        if let isItemExistAtClosure = isItemExistAtClosure {
            return isItemExistAtClosure(path)
        } else {
            return isItemExistAtReturnValue
        }
    }

    // MARK: - deleteItem

    public var deleteItemAtThrowableError: Error?
    public var deleteItemAtCallsCount = 0
    public var deleteItemAtCalled: Bool { deleteItemAtCallsCount > 0 }
    public var deleteItemAtReceivedPath: String?
    public var deleteItemAtReceivedInvocations: [String] = []
    public var deleteItemAtClosure: ((String) throws -> Void)?

    public func deleteItem(at path: String) throws {
        if let error = deleteItemAtThrowableError {
            throw error
        }
        deleteItemAtCallsCount += 1
        deleteItemAtReceivedPath = path
        deleteItemAtReceivedInvocations.append(path)
        try deleteItemAtClosure?(path)
    }

    // MARK: - moveItem

    public var moveItemAtToReplaceThrowableError: Error?
    public var moveItemAtToReplaceCallsCount = 0
    public var moveItemAtToReplaceCalled: Bool { moveItemAtToReplaceCallsCount > 0 }
    public var moveItemAtToReplaceReceivedArguments: (itemURL: URL, folderPath: String, replace: Bool)?
    public var moveItemAtToReplaceReceivedInvocations: [(itemURL: URL, folderPath: String, replace: Bool)] = []
    public var moveItemAtToReplaceClosure: ((URL, String, Bool) throws -> Void)?

    public func moveItem(at itemURL: URL, to folderPath: String, replace: Bool) throws {
        if let error = moveItemAtToReplaceThrowableError {
            throw error
        }
        moveItemAtToReplaceCallsCount += 1
        moveItemAtToReplaceReceivedArguments = (itemURL: itemURL, folderPath: folderPath, replace: replace)
        moveItemAtToReplaceReceivedInvocations.append((itemURL: itemURL, folderPath: folderPath, replace: replace))
        try moveItemAtToReplaceClosure?(itemURL, folderPath, replace)
    }

    // MARK: - copyItem

    public var copyItemAtToReplaceThrowableError: Error?
    public var copyItemAtToReplaceCallsCount = 0
    public var copyItemAtToReplaceCalled: Bool { copyItemAtToReplaceCallsCount > 0 }
    public var copyItemAtToReplaceReceivedArguments: (itemURL: URL, folderPath: String, replace: Bool)?
    public var copyItemAtToReplaceReceivedInvocations: [(itemURL: URL, folderPath: String, replace: Bool)] = []
    public var copyItemAtToReplaceClosure: ((URL, String, Bool) throws -> Void)?

    public func copyItem(at itemURL: URL, to folderPath: String, replace: Bool) throws {
        if let error = copyItemAtToReplaceThrowableError {
            throw error
        }
        copyItemAtToReplaceCallsCount += 1
        copyItemAtToReplaceReceivedArguments = (itemURL: itemURL, folderPath: folderPath, replace: replace)
        copyItemAtToReplaceReceivedInvocations.append((itemURL: itemURL, folderPath: folderPath, replace: replace))
        try copyItemAtToReplaceClosure?(itemURL, folderPath, replace)
    }
}

// swiftlint:enable all
