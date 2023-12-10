@testable import RugbyFoundation
import XCTest

final class ProcessInterruptionTaskTests: XCTestCase {
    private var sut: ProcessInterruptionTask!
    private var jobCallsCount = 0

    override func setUp() {
        super.setUp()
        sut = ProcessInterruptionTask(job: { [weak self] in self?.jobCallsCount += 1 })
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        jobCallsCount = 0
    }
}

extension ProcessInterruptionTaskTests {
    func test_run() {
        sut.run()

        // Assert
        XCTAssertTrue(sut.isDone)
        XCTAssertEqual(jobCallsCount, 1)
    }

    func test_cancel() {
        sut.cancel()

        // Assert
        XCTAssertTrue(sut.isCancelled)
    }

    func test_runAfterCancel() {
        sut.cancel()
        sut.run()

        // Assert
        XCTAssertFalse(sut.isDone)
        XCTAssertEqual(jobCallsCount, 0)
        XCTAssertTrue(sut.isCancelled)
    }

    func test_runTwice() {
        sut.run()
        sut.run()

        // Assert
        XCTAssertTrue(sut.isDone)
        XCTAssertEqual(jobCallsCount, 1)
    }
}
