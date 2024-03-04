// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IProductHasherMock: IProductHasher {

    // MARK: - hashContext

    var hashContextCallsCount = 0
    var hashContextCalled: Bool { hashContextCallsCount > 0 }
    var hashContextReceivedProduct: Product?
    var hashContextReceivedInvocations: [Product] = []
    private let hashContextReceivedInvocationsLock = NSRecursiveLock()
    var hashContextReturnValue: [String: String?]!
    var hashContextClosure: ((Product) -> [String: String?])?

    func hashContext(_ product: Product) -> [String: String?] {
        hashContextCallsCount += 1
        hashContextReceivedProduct = product
        hashContextReceivedInvocationsLock.withLock {
            hashContextReceivedInvocations.append(product)
        }
        if let hashContextClosure = hashContextClosure {
            return hashContextClosure(product)
        } else {
            return hashContextReturnValue
        }
    }
}

// swiftlint:enable all
