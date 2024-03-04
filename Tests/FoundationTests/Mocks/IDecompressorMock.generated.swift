// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IDecompressorMock: IDecompressor {

    // MARK: - unzipFile

    var unzipFileDestinationThrowableError: Error?
    var unzipFileDestinationCallsCount = 0
    var unzipFileDestinationCalled: Bool { unzipFileDestinationCallsCount > 0 }
    var unzipFileDestinationReceivedArguments: (zipFilePath: URL, destination: URL)?
    var unzipFileDestinationReceivedInvocations: [(zipFilePath: URL, destination: URL)] = []
    private let unzipFileDestinationReceivedInvocationsLock = NSRecursiveLock()
    var unzipFileDestinationClosure: ((URL, URL) throws -> Void)?

    func unzipFile(_ zipFilePath: URL, destination: URL) throws {
        unzipFileDestinationCallsCount += 1
        unzipFileDestinationReceivedArguments = (zipFilePath: zipFilePath, destination: destination)
        unzipFileDestinationReceivedInvocationsLock.withLock {
            unzipFileDestinationReceivedInvocations.append((zipFilePath: zipFilePath, destination: destination))
        }
        if let error = unzipFileDestinationThrowableError {
            throw error
        }
        try unzipFileDestinationClosure?(zipFilePath, destination)
    }
}

// swiftlint:enable all
