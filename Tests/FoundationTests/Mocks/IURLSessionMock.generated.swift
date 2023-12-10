// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IURLSessionMock: IURLSession {

    // MARK: - data

    var dataForThrowableError: Error?
    var dataForCallsCount = 0
    var dataForCalled: Bool { dataForCallsCount > 0 }
    var dataForReceivedRequest: URLRequest?
    var dataForReceivedInvocations: [URLRequest] = []
    var dataForReturnValue: (Data, URLResponse)!
    var dataForClosure: ((URLRequest) async throws -> (Data, URLResponse))?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataForCallsCount += 1
        dataForReceivedRequest = request
        dataForReceivedInvocations.append(request)
        if let error = dataForThrowableError {
            throw error
        }
        if let dataForClosure = dataForClosure {
            return try await dataForClosure(request)
        } else {
            return dataForReturnValue
        }
    }

    // MARK: - download

    var downloadForThrowableError: Error?
    var downloadForCallsCount = 0
    var downloadForCalled: Bool { downloadForCallsCount > 0 }
    var downloadForReceivedRequest: URLRequest?
    var downloadForReceivedInvocations: [URLRequest] = []
    var downloadForReturnValue: URL!
    var downloadForClosure: ((URLRequest) async throws -> URL)?

    func download(for request: URLRequest) async throws -> URL {
        downloadForCallsCount += 1
        downloadForReceivedRequest = request
        downloadForReceivedInvocations.append(request)
        if let error = downloadForThrowableError {
            throw error
        }
        if let downloadForClosure = downloadForClosure {
            return try await downloadForClosure(request)
        } else {
            return downloadForReturnValue
        }
    }
}

// swiftlint:enable all
