// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class FoundationHasherMock: FoundationHasher {

    // MARK: - hash

    var hashStringCallsCount = 0
    var hashStringCalled: Bool { hashStringCallsCount > 0 }
    var hashStringReceivedString: String?
    var hashStringReceivedInvocations: [String] = []
    var hashStringReturnValue: String!
    var hashStringClosure: ((String) -> String)?

    func hash(_ string: String) -> String {
        hashStringCallsCount += 1
        hashStringReceivedString = string
        hashStringReceivedInvocations.append(string)
        if let hashStringClosure = hashStringClosure {
            return hashStringClosure(string)
        } else {
            return hashStringReturnValue
        }
    }

    // MARK: - hash

    var hashArrayOfStringsCallsCount = 0
    var hashArrayOfStringsCalled: Bool { hashArrayOfStringsCallsCount > 0 }
    var hashArrayOfStringsReceivedArrayOfStrings: [String]?
    var hashArrayOfStringsReceivedInvocations: [[String]] = []
    var hashArrayOfStringsReturnValue: String!
    var hashArrayOfStringsClosure: (([String]) -> String)?

    func hash(_ arrayOfStrings: [String]) -> String {
        hashArrayOfStringsCallsCount += 1
        hashArrayOfStringsReceivedArrayOfStrings = arrayOfStrings
        hashArrayOfStringsReceivedInvocations.append(arrayOfStrings)
        if let hashArrayOfStringsClosure = hashArrayOfStringsClosure {
            return hashArrayOfStringsClosure(arrayOfStrings)
        } else {
            return hashArrayOfStringsReturnValue
        }
    }

    // MARK: - hash

    var hashDataCallsCount = 0
    var hashDataCalled: Bool { hashDataCallsCount > 0 }
    var hashDataReceivedData: Data?
    var hashDataReceivedInvocations: [Data] = []
    var hashDataReturnValue: String!
    var hashDataClosure: ((Data) -> String)?

    func hash(_ data: Data) -> String {
        hashDataCallsCount += 1
        hashDataReceivedData = data
        hashDataReceivedInvocations.append(data)
        if let hashDataClosure = hashDataClosure {
            return hashDataClosure(data)
        } else {
            return hashDataReturnValue
        }
    }
}

// swiftlint:enable all
