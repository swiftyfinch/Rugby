// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import XcbeautifyLib
@testable import RugbyFoundation

final class IBuildLogFormatterMock: IBuildLogFormatter {

    // MARK: - format

    var formatLineOutputThrowableError: Error?
    var formatLineOutputCallsCount = 0
    var formatLineOutputCalled: Bool { formatLineOutputCallsCount > 0 }
    var formatLineOutputReceivedArguments: (line: String, output: (String, OutputType) throws -> Void)?
    var formatLineOutputReceivedInvocations: [(line: String, output: (String, OutputType) throws -> Void)] = []
    var formatLineOutputClosure: ((String, @escaping (String, OutputType) throws -> Void) throws -> Void)?

    func format(line: String, output: @escaping (String, OutputType) throws -> Void) throws {
        formatLineOutputCallsCount += 1
        formatLineOutputReceivedArguments = (line: line, output: output)
        formatLineOutputReceivedInvocations.append((line: line, output: output))
        if let error = formatLineOutputThrowableError {
            throw error
        }
        try formatLineOutputClosure?(line, output)
    }

    // MARK: - finish

    var finishOutputThrowableError: Error?
    var finishOutputCallsCount = 0
    var finishOutputCalled: Bool { finishOutputCallsCount > 0 }
    var finishOutputReceivedOutput: ((String, OutputType) throws -> Void)?
    var finishOutputReceivedInvocations: [((String, OutputType) throws -> Void)] = []
    var finishOutputClosure: ((@escaping (String, OutputType) throws -> Void) throws -> Void)?

    func finish(output: @escaping (String, OutputType) throws -> Void) throws {
        finishOutputCallsCount += 1
        finishOutputReceivedOutput = output
        finishOutputReceivedInvocations.append(output)
        if let error = finishOutputThrowableError {
            throw error
        }
        try finishOutputClosure?(output)
    }
}

// swiftlint:enable all
