import Fish
@testable import RugbyFoundation
import XCTest

final class PlansParserTests: XCTestCase {
    private var sut: IPlansParser!
    private var fishSharedStorage: IFilesManagerMock!
    private var envVariablesResolver: IEnvVariablesResolverMock!

    override func setUp() {
        super.setUp()
        fishSharedStorage = IFilesManagerMock()
        let backupFishSharedStorage = Fish.sharedStorage
        Fish.sharedStorage = fishSharedStorage
        addTeardownBlock {
            Fish.sharedStorage = backupFishSharedStorage
        }
        envVariablesResolver = IEnvVariablesResolverMock()
        sut = PlansParser(envVariablesResolver: envVariablesResolver)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        fishSharedStorage.readFileClosure = nil
        fishSharedStorage = nil
        envVariablesResolver = nil
    }
}

// MARK: - Top Plan

extension PlansParserTests {
    func test_top_plan() async throws {
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
        envVariablesResolver.resolveAdditionalEnvClosure = { string, _ in string }

        // Act
        let result = try await sut.topPlan(atPath: path)

        // Assert
        XCTAssertEqual(result, expected)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_top_plan_cached() async throws {
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
        envVariablesResolver.resolveAdditionalEnvClosure = { string, _ in string }

        // Act
        let result = try await sut.topPlan(atPath: path)
        let result2 = try await sut.topPlan(atPath: path)

        // Assert
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result2, expected)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_top_plan_arguments() async throws {
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
        envVariablesResolver.resolveAdditionalEnvClosure = { string, _ in string }

        // Act
        let result = try await sut.topPlan(atPath: path)

        // Assert
        XCTAssertEqual(result, expected)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_top_plan_noPlans() async throws {
        let expectedError = PlansParserError.noPlans
        fishSharedStorage.readFileClosure = { _ in "" }
        let path = "test"
        let pathURL = URL(fileURLWithPath: path)

        // Act
        var result: Plan?
        var resultError: Error?
        do {
            result = try await sut.topPlan(atPath: path)
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
    func test_named_plan() async throws {
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
        envVariablesResolver.resolveAdditionalEnvClosure = { string, _ in string }

        // Act
        let result = try await sut.planNamed("tests", path: path)

        // Assert
        XCTAssertEqual(result, expected)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_named_plan_noPlanWithName() async throws {
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
            result = try await sut.planNamed(planName, path: path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(resultError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_named_plan_missedCommandType() async throws {
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
            result = try await sut.planNamed(planName, path: path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(resultError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_named_plan_incorrectFormat() async throws {
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
            result = try await sut.planNamed(planName, path: path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(resultError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_named_plan_unknownArgumentType() async throws {
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
            result = try await sut.planNamed(planName, path: path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(resultError?.localizedDescription, expectedError.localizedDescription)
        XCTAssertEqual(fishSharedStorage.readFileCallsCount, 1)
        XCTAssertEqual(fishSharedStorage.readFileReceivedFile, pathURL)
    }

    func test_resolveEnvVariablesInStrings() async throws {
        fishSharedStorage.readFileClosure = { _ in
            """
            plan_with_env:
            - command: warmup
              argument: s3.eu-west-2.amazonaws.com
              timeout: 120
              headers: "secret_key: ${SECRET_KEY}"
              targets: [Alamofire, $ANOTHER_TARGET]
              except: $(ENV_VARIABLE)
              config: $(SHARED_CONFIG)
            """
        }
        envVariablesResolver.resolveAdditionalEnvClosure = { string, _ in string }

        // Act
        let result = try await sut.planNamed("plan_with_env", path: "")

        // Assert
        XCTAssertEqual(
            Set(envVariablesResolver.resolveAdditionalEnvReceivedInvocations.map(\.string)),
            [
                "s3.eu-west-2.amazonaws.com",
                "$(SHARED_CONFIG)",
                "$(ENV_VARIABLE)",
                "secret_key: ${SECRET_KEY}",
                "Alamofire",
                "$ANOTHER_TARGET"
            ]
        )
    }
}
