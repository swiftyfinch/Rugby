// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import SwiftShell

public final class ReadableStreamMock: ReadableStream {

    public init() {}
    public var encoding: String.Encoding {
        get { return underlyingEncoding }
        set(value) { underlyingEncoding = value }
    }
    public var underlyingEncoding: String.Encoding!
    public var filehandle: FileHandle {
        get { return underlyingFilehandle }
        set(value) { underlyingFilehandle = value }
    }
    public var underlyingFilehandle: FileHandle!
    public var context: Context {
        get { return underlyingContext }
        set(value) { underlyingContext = value }
    }
    public var underlyingContext: Context!

    // MARK: - readSome

    public var readSomeCallsCount = 0
    public var readSomeCalled: Bool { readSomeCallsCount > 0 }
    public var readSomeReturnValue: String?
    public var readSomeClosure: (() -> String?)?

    public func readSome() -> String? {
        readSomeCallsCount += 1
        if let readSomeClosure = readSomeClosure {
            return readSomeClosure()
        } else {
            return readSomeReturnValue
        }
    }

    // MARK: - read

    public var readCallsCount = 0
    public var readCalled: Bool { readCallsCount > 0 }
    public var readReturnValue: String!
    public var readClosure: (() -> String)?

    public func read() -> String {
        readCallsCount += 1
        if let readClosure = readClosure {
            return readClosure()
        } else {
            return readReturnValue
        }
    }
}

// swiftlint:enable all
