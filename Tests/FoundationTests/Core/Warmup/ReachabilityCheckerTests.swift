@testable import RugbyFoundation
import XCTest

final class ReachabilityCheckerTests: XCTestCase {
    private var sut: IReachabilityChecker!
    private var urlSession: IURLSessionMock!

    override func setUp() {
        super.setUp()
        urlSession = IURLSessionMock()
        sut = ReachabilityChecker(urlSession: urlSession)
    }

    override func tearDown() {
        super.tearDown()
        urlSession = nil
        sut = nil
    }
}

extension ReachabilityCheckerTests {
    func test_checkIfURLIsReachable_200() async throws {
        let url: URL! = URL(string: "https://github.com/swiftyfinch/Rugby")
        let data: Data! = "test_data".data(using: .utf8)
        let response: URLResponse! = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        urlSession.dataForReturnValue = (data, response)

        // Act
        let reachable = try await sut.checkIfURLIsReachable(url, headers: ["test_field": "test_value"])

        // Assert
        XCTAssertTrue(reachable)
        XCTAssertEqual(urlSession.dataForCallsCount, 1)
        XCTAssertEqual(urlSession.dataForReceivedRequest?.url, url)
        XCTAssertEqual(urlSession.dataForReceivedRequest?.httpMethod, "HEAD")
        XCTAssertEqual(urlSession.dataForReceivedRequest?.allHTTPHeaderFields?.count, 1)
        XCTAssertEqual(urlSession.dataForReceivedRequest?.allHTTPHeaderFields?["test_field"], "test_value")
    }

    func test_checkIfURLIsReachable_404() async throws {
        let url: URL! = URL(string: "https://github.com/swiftyfinch/Rugby")
        let data: Data! = "test_data".data(using: .utf8)
        let response: URLResponse! = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
        urlSession.dataForReturnValue = (data, response)

        // Act
        let reachable = try await sut.checkIfURLIsReachable(url, headers: [:])

        // Assert
        XCTAssertFalse(reachable)
        XCTAssertEqual(urlSession.dataForCallsCount, 1)
    }

    func test_checkIfURLIsReachable_error() async throws {
        let url: URL! = URL(string: "https://github.com/swiftyfinch/Rugby")
        let data: Data! = "test_data".data(using: .utf8)
        urlSession.dataForReturnValue = (
            data,
            URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        )

        // Act
        var resultError: Error?
        do {
            _ = try await sut.checkIfURLIsReachable(url, headers: [:])
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(urlSession.dataForCallsCount, 1)
        XCTAssertEqual(resultError as? ReachabilityCheckerError, .urlUnreachable(url))
        XCTAssertEqual(resultError?.localizedDescription, "https://github.com/swiftyfinch/Rugby unreachable.")
    }
}
