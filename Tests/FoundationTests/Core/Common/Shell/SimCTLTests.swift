@testable import RugbyFoundation
import XCTest

final class SimCTLTests: XCTestCase {
    private enum TestError: Error { case test }

    private var sut: ISimCTL!
    private var shellExecutor: IShellExecutorMock!

    override func setUp() {
        super.setUp()
        shellExecutor = IShellExecutorMock()
        sut = SimCTL(shellExecutor: shellExecutor)
    }

    override func tearDown() {
        super.tearDown()
        shellExecutor = nil
        sut = nil
    }
}

extension SimCTLTests {
    func test_availableDevices_error() async throws {
        shellExecutor.throwingShellArgsThrowableError = TestError.test

        // Act
        var resultError: Error?
        do {
            _ = try sut.availableDevices()
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? TestError, .test)
        XCTAssertFalse(shellExecutor.throwingShellArgsCalled)
    }

    func test_availableDevices_nilOutputError() throws {
        shellExecutor.throwingShellArgsReturnValue = nil

        // Act
        var resultError: Error?
        do {
            _ = try sut.availableDevices()
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? SimCTLError, .nilOutput)
        XCTAssertEqual((resultError as? SimCTLError)?.localizedDescription, "The simctl command returned nil.")
        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        XCTAssertEqual(shellExecutor.throwingShellArgsReceivedArguments?.command,
                       "xcrun simctl list devices available --json")
        let args = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments?.args as? [Any])
        XCTAssertTrue(args.isEmpty)
    }

    func test_availableDevices_unexpectedOutput() throws {
        shellExecutor.throwingShellArgsReturnValue = "{}"

        // Act
        var resultError: Error?
        do {
            _ = try sut.availableDevices()
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? SimCTLError, .unexpectedOutput)
        XCTAssertEqual((resultError as? SimCTLError)?.localizedDescription,
                       "The simctl command returned an unexpected output.")
        XCTAssertEqual(shellExecutor.throwingShellArgsCallsCount, 1)
        XCTAssertEqual(shellExecutor.throwingShellArgsReceivedArguments?.command,
                       "xcrun simctl list devices available --json")
        let args = try XCTUnwrap(shellExecutor.throwingShellArgsReceivedArguments?.args as? [Any])
        XCTAssertTrue(args.isEmpty)
    }

    func test_availableDevices() async throws {
        shellExecutor.throwingShellArgsReturnValue = """
        {
          "devices" : {
            "com.apple.CoreSimulator.SimRuntime.iOS-16-1" : [],
            "com.apple.CoreSimulator.SimRuntime.iOS-17-0" : [
              {
                "dataPathSize" : 13258752,
                "logPath" : "/Users/swiftyfinch/Library/Logs/CoreSimulator/FBACA33B-857E-4061-A3E9-14BF4D4E4A02",
                "udid" : "FBACA33B-857E-4061-A3E9-14BF4D4E4A02",
                "deviceTypeIdentifier" : "com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation",
                "state" : "Shutdown",
                "name" : "iPhone SE (3rd generation)"
              },
              {
                "lastBootedAt" : "2024-03-03T09:49:03Z",
                "dataPathSize" : 2920554496,
                "logPath" : "/Users/swiftyfinch/Library/Logs/CoreSimulator/DF48893A-FD66-478A-A540-BACC2FC2C1E9",
                "udid" : "DF48893A-FD66-478A-A540-BACC2FC2C1E9",
                "isAvailable" : true,
                "logPathSize" : 634880,
                "deviceTypeIdentifier" : "com.apple.CoreSimulator.SimDeviceType.iPhone-15",
                "state" : "Booted",
                "name" : "iPhone 15"
              }
            ]
          }
        }
        """

        // Act
        let devices = try sut.availableDevices()

        // Assert
        XCTAssertEqual(devices.count, 1)
        XCTAssertEqual(
            devices,
            [
                Device(
                    udid: "DF48893A-FD66-478A-A540-BACC2FC2C1E9",
                    isAvailable: true,
                    state: "Booted",
                    name: "iPhone 15",
                    runtime: "com.apple.CoreSimulator.SimRuntime.iOS-17-0"
                )
            ]
        )
    }
}
