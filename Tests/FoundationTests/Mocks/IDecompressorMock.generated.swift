// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IDecompressorMock: IDecompressor {

    // MARK: - unarchiveFile

    var unarchiveFileDestinationThrowableError: Error?
    var unarchiveFileDestinationCallsCount = 0
    var unarchiveFileDestinationCalled: Bool { unarchiveFileDestinationCallsCount > 0 }
    var unarchiveFileDestinationReceivedArguments: (archiveFilePath: URL, destination: URL)?
    var unarchiveFileDestinationReceivedInvocations: [(archiveFilePath: URL, destination: URL)] = []
    private let unarchiveFileDestinationReceivedInvocationsLock = NSRecursiveLock()
    var unarchiveFileDestinationClosure: ((URL, URL) throws -> Void)?

    func unarchiveFile(_ archiveFilePath: URL, destination: URL) throws {
        unarchiveFileDestinationCallsCount += 1
        unarchiveFileDestinationReceivedArguments = (archiveFilePath: archiveFilePath, destination: destination)
        unarchiveFileDestinationReceivedInvocationsLock.withLock {
            unarchiveFileDestinationReceivedInvocations.append((archiveFilePath: archiveFilePath, destination: destination))
        }
        if let error = unarchiveFileDestinationThrowableError {
            throw error
        }
        try unarchiveFileDestinationClosure?(archiveFilePath, destination)
    }
}

// swiftlint:enable all
