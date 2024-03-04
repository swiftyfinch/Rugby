// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ICacheDownloaderMock: ICacheDownloader {

    // MARK: - checkIfBinaryIsReachable

    var checkIfBinaryIsReachableUrlCallsCount = 0
    var checkIfBinaryIsReachableUrlCalled: Bool { checkIfBinaryIsReachableUrlCallsCount > 0 }
    var checkIfBinaryIsReachableUrlReceivedUrl: URL?
    var checkIfBinaryIsReachableUrlReceivedInvocations: [URL] = []
    private let checkIfBinaryIsReachableUrlReceivedInvocationsLock = NSRecursiveLock()
    var checkIfBinaryIsReachableUrlReturnValue: Bool!
    var checkIfBinaryIsReachableUrlClosure: ((URL) async -> Bool)?

    func checkIfBinaryIsReachable(url: URL) async -> Bool {
        checkIfBinaryIsReachableUrlCallsCount += 1
        checkIfBinaryIsReachableUrlReceivedUrl = url
        checkIfBinaryIsReachableUrlReceivedInvocationsLock.withLock {
            checkIfBinaryIsReachableUrlReceivedInvocations.append(url)
        }
        if let checkIfBinaryIsReachableUrlClosure = checkIfBinaryIsReachableUrlClosure {
            return await checkIfBinaryIsReachableUrlClosure(url)
        } else {
            return checkIfBinaryIsReachableUrlReturnValue
        }
    }

    // MARK: - downloadBinary

    var downloadBinaryUrlToCallsCount = 0
    var downloadBinaryUrlToCalled: Bool { downloadBinaryUrlToCallsCount > 0 }
    var downloadBinaryUrlToReceivedArguments: (url: URL, folderURL: URL)?
    var downloadBinaryUrlToReceivedInvocations: [(url: URL, folderURL: URL)] = []
    private let downloadBinaryUrlToReceivedInvocationsLock = NSRecursiveLock()
    var downloadBinaryUrlToReturnValue: Bool!
    var downloadBinaryUrlToClosure: ((URL, URL) async -> Bool)?

    func downloadBinary(url: URL, to folderURL: URL) async -> Bool {
        downloadBinaryUrlToCallsCount += 1
        downloadBinaryUrlToReceivedArguments = (url: url, folderURL: folderURL)
        downloadBinaryUrlToReceivedInvocationsLock.withLock {
            downloadBinaryUrlToReceivedInvocations.append((url: url, folderURL: folderURL))
        }
        if let downloadBinaryUrlToClosure = downloadBinaryUrlToClosure {
            return await downloadBinaryUrlToClosure(url, folderURL)
        } else {
            return downloadBinaryUrlToReturnValue
        }
    }
}

// swiftlint:enable all
