// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ICacheDownloaderMock: ICacheDownloader {

    // MARK: - checkIfBinaryIsReachable

    var checkIfBinaryIsReachableUrlHeadersCallsCount = 0
    var checkIfBinaryIsReachableUrlHeadersCalled: Bool { checkIfBinaryIsReachableUrlHeadersCallsCount > 0 }
    var checkIfBinaryIsReachableUrlHeadersReceivedArguments: (url: URL, headers: [String: String])?
    var checkIfBinaryIsReachableUrlHeadersReceivedInvocations: [(url: URL, headers: [String: String])] = []
    private let checkIfBinaryIsReachableUrlHeadersReceivedInvocationsLock = NSRecursiveLock()
    var checkIfBinaryIsReachableUrlHeadersReturnValue: Bool!
    var checkIfBinaryIsReachableUrlHeadersClosure: ((URL, [String: String]) async -> Bool)?

    func checkIfBinaryIsReachable(url: URL, headers: [String: String]) async -> Bool {
        checkIfBinaryIsReachableUrlHeadersCallsCount += 1
        checkIfBinaryIsReachableUrlHeadersReceivedArguments = (url: url, headers: headers)
        checkIfBinaryIsReachableUrlHeadersReceivedInvocationsLock.withLock {
            checkIfBinaryIsReachableUrlHeadersReceivedInvocations.append((url: url, headers: headers))
        }
        if let checkIfBinaryIsReachableUrlHeadersClosure = checkIfBinaryIsReachableUrlHeadersClosure {
            return await checkIfBinaryIsReachableUrlHeadersClosure(url, headers)
        } else {
            return checkIfBinaryIsReachableUrlHeadersReturnValue
        }
    }

    // MARK: - downloadBinary

    var downloadBinaryUrlHeadersToCallsCount = 0
    var downloadBinaryUrlHeadersToCalled: Bool { downloadBinaryUrlHeadersToCallsCount > 0 }
    var downloadBinaryUrlHeadersToReceivedArguments: (url: URL, headers: [String: String], folderURL: URL)?
    var downloadBinaryUrlHeadersToReceivedInvocations: [(url: URL, headers: [String: String], folderURL: URL)] = []
    private let downloadBinaryUrlHeadersToReceivedInvocationsLock = NSRecursiveLock()
    var downloadBinaryUrlHeadersToReturnValue: Bool!
    var downloadBinaryUrlHeadersToClosure: ((URL, [String: String], URL) async -> Bool)?

    func downloadBinary(url: URL, headers: [String: String], to folderURL: URL) async -> Bool {
        downloadBinaryUrlHeadersToCallsCount += 1
        downloadBinaryUrlHeadersToReceivedArguments = (url: url, headers: headers, folderURL: folderURL)
        downloadBinaryUrlHeadersToReceivedInvocationsLock.withLock {
            downloadBinaryUrlHeadersToReceivedInvocations.append((url: url, headers: headers, folderURL: folderURL))
        }
        if let downloadBinaryUrlHeadersToClosure = downloadBinaryUrlHeadersToClosure {
            return await downloadBinaryUrlHeadersToClosure(url, headers, folderURL)
        } else {
            return downloadBinaryUrlHeadersToReturnValue
        }
    }
}

// swiftlint:enable all
