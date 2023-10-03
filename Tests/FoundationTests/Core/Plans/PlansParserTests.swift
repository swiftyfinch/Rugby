import Fish
@testable import RugbyFoundation
import XCTest

final class PlansParserTests: XCTestCase {
    private var sut: IPlansParser!
    private var fishSharedStorage: IFilesManagerMockMock!

    override func setUp() {
        super.setUp()
        fishSharedStorage = IFilesManagerMockMock()
        Fish.sharedStorage = fishSharedStorage
        sut = PlansParser()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        fishSharedStorage.readFileClosure = nil
        fishSharedStorage = nil
    }
}

// MARK: - Top Plan

extension PlansParserTests {
    func test_top_plan() throws {
        let expected = Plan(
            name: "usual",
            commands: [Plan.Command(name: "cache", args: ["--arch", "x86_64", "--strip"])]
        )
        fishSharedStorage.readFileClosure = { _ in
            """
            usual:
            - command: cache
              arch: x86_64
              strip: true
            """
        }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        let result = try sut.top(path: path)

        // Assert
        XCTAssertEqual(result, expected)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_top_plan_cached() throws {
        let expected = Plan(
            name: "usual",
            commands: [Plan.Command(name: "cache", args: ["--arch", "x86_64", "--strip"])]
        )
        fishSharedStorage.readFileClosure = { _ in
            """
            usual:
            - command: cache
              arch: x86_64
              strip: true
            """
        }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        let result = try sut.top(path: path)
        let result2 = try sut.top(path: path)

        // Assert
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result2, expected)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_top_plan_arguments() throws {
        let expected = Plan(
            name: "usual",
            commands: [Plan.Command(name: "cache", args: ["A", "B"])]
        )
        fishSharedStorage.readFileClosure = { _ in
            """
            usual:
            - command: cache
              argument:
              - "A"
              - "B"
            """
        }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        let result = try sut.top(path: path)

        // Assert
        XCTAssertEqual(result, expected)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_top_plan_noPlans() throws {
        let expectedError = PlansParserError.noPlans
        fishSharedStorage.readFileClosure = { _ in "" }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        var result: Plan?
        var resultError: Error?
        do {
            result = try sut.top(path: path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(resultError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }
}

// MARK: - Named Plan

extension PlansParserTests {
    func test_named_plan() throws {
        let expected = Plan(
            name: "tests",
            commands: [Plan.Command(name: "warmup", args: ["s3.eu-west-2.amazonaws.com", "--timeout", "120"])]
        )
        fishSharedStorage.readFileClosure = { _ in
            """
            usual:
            - command: cache
              arch: x86_64
              targets: ["Alamofire", "SnapKit"]
            tests:
            - command: warmup
              argument: s3.eu-west-2.amazonaws.com
              timeout: 120
            """
        }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        let result = try sut.named("tests", path: path)

        // Assert
        XCTAssertEqual(result, expected)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_named_plan_noPlanWithName() throws {
        let planName = "ci"
        let expectedError = PlansParserError.noPlanWithName(planName)
        fishSharedStorage.readFileClosure = { _ in
            """
            usual:
            - command: cache
            """
        }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        var result: Plan?
        var resultError: Error?
        do {
            result = try sut.named(planName, path: path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(resultError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_named_plan_missedCommandType() throws {
        let planName = "ci"
        let expectedError = PlansParserError.missedCommandType
        fishSharedStorage.readFileClosure = { _ in
            """
            usual:
            - sdk: ios
            """
        }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        var result: Plan?
        var resultError: Error?
        do {
            result = try sut.named(planName, path: path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(resultError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_named_plan_incorrectFormat() throws {
        let planName = "ci"
        let expectedError = PlansParserError.incorrectFormat
        fishSharedStorage.readFileClosure = { _ in
            """
            usual:
            """
        }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        var result: Plan?
        var resultError: Error?
        do {
            result = try sut.named(planName, path: path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(resultError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_named_plan_unknownArgumentType() throws {
        let planName = "ci"
        let testValue = 0.3
        let expectedError = PlansParserError.unknownArgumentType(testValue)
        fishSharedStorage.readFileClosure = { _ in
            """
            usual:
            - command: delete
              douleValue: \(testValue)
            """
        }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        var result: Plan?
        var resultError: Error?
        do {
            result = try sut.named(planName, path: path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(resultError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }
}
