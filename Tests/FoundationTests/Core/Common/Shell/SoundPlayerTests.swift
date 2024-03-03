@testable import RugbyFoundation
import XCTest

final class SoundPlayerTests: XCTestCase {
    private var sut: ISoundPlayer!
    private var shellExecutor: IShellExecutorMock!

    override func setUp() {
        super.setUp()
        shellExecutor = IShellExecutorMock()
        sut = SoundPlayer(shellExecutor: shellExecutor)
    }

    override func tearDown() {
        super.tearDown()
        shellExecutor = nil
        sut = nil
    }
}

extension SoundPlayerTests {
    func test_playBell() throws {
        sut.playBell()

        // Assert
        let printShellArgsReceivedArguments = try XCTUnwrap(shellExecutor.printShellArgsReceivedArguments)
        XCTAssertEqual(printShellArgsReceivedArguments.command, "tput bel")
        let args = try XCTUnwrap(printShellArgsReceivedArguments.args as? [Any])
        XCTAssertTrue(args.isEmpty)
    }
}
