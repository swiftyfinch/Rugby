@testable import RugbyFoundation
import XCTest

final class DictionaryTests: XCTestCase {
    private let sut = ["00": 2000, "23": 2023, "89": 1989]
}

extension DictionaryTests {
    func test_contains() {
        XCTAssertTrue(sut.contains("23"))
    }

    func test_flatMapValues() {
        let result = sut.flatMapValues { value in
            [String(value): value]
        }

        // Assert
        XCTAssertEqual(result, ["2023": 2023, "2000": 2000, "1989": 1989])
    }

    func test_concurrentFlatMapValues() async {
        let result = await sut.concurrentFlatMapValues { value in
            [String(value): value]
        }

        // Assert
        XCTAssertEqual(result, ["2023": 2023, "2000": 2000, "1989": 1989])
    }

    func test_partition() {
        let (left, right) = sut.partition { _, value in
            value >= 2000
        }

        // Assert
        XCTAssertEqual(left, ["00": 2000, "23": 2023])
        XCTAssertEqual(right, ["89": 1989])
    }

    func test_subtract() {
        var sut = sut
        sut.subtract(["23": 2023])

        // Assert
        XCTAssertEqual(sut, ["89": 1989, "00": 2000])
    }

    func test_subtracting() {
        XCTAssertEqual(sut.subtracting(["89": 1989]), ["23": 2023, "00": 2000])
    }

    func test_merge() {
        var sut = sut
        sut.merge(["89": 89, "00": 00, "01": 01])

        // Assert
        XCTAssertEqual(sut, ["89": 89, "00": 00, "01": 01, "23": 2023])
    }

    func test_merging() {
        XCTAssertEqual(
            sut.merging(["89": 89, "00": 00, "01": 01]),
            ["89": 89, "00": 00, "01": 01, "23": 2023]
        )
    }

    func test_keysIntersection() {
        XCTAssertEqual(
            sut.keysIntersection(["00": 00, "89": 1989]),
            ["00": 2000, "89": 1989]
        )
    }
}
