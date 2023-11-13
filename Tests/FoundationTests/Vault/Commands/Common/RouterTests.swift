import Fish
@testable import RugbyFoundation
import XCTest

final class RouterTests: XCTestCase {
    private var sut: IRouter!
    private var workingDirectory: IFolderMock!
    private var sharedFolderPath: String!

    override func setUp() {
        super.setUp()
        workingDirectory = IFolderMock()
        sharedFolderPath = Folder.home.path
        sut = Router(workingDirectory: workingDirectory,
                     sharedFolderPath: sharedFolderPath)
    }

    override func tearDown() {
        super.tearDown()
        workingDirectory = nil
        sharedFolderPath = nil
        sut = nil
    }
}

extension RouterTests {
    func test_workingDirectory() {
        XCTAssertIdentical(sut.workingDirectory as? IFolderMock, workingDirectory)
    }

    func test_rugbySharedFolderPath() {
        XCTAssertEqual(sut.rugbySharedFolderPath, sharedFolderPath.subpath(".rugby"))
    }

    func test_binFolderPath() {
        XCTAssertEqual(sut.binFolderPath, sharedFolderPath.subpath(".rugby", "bin"))
    }

    func test_logsFolderPath() {
        XCTAssertEqual(sut.logsFolderPath, sharedFolderPath.subpath(".rugby", "logs"))
    }

    func test_podsPath() {
        workingDirectory.subpathReturnValue = "~/Developer/Rugby/Example/Pods"

        // Assert
        XCTAssertEqual(sut.podsPath, "~/Developer/Rugby/Example/Pods")
        XCTAssertEqual(workingDirectory.subpathReceivedPathComponents, ["Pods"])
    }

    func test_podsProjectPath() {
        workingDirectory.subpathReturnValue = "~/Developer/Rugby/Example/Pods/Pods.xcodeproj"

        // Assert
        XCTAssertEqual(sut.podsProjectPath, "~/Developer/Rugby/Example/Pods/Pods.xcodeproj")
        XCTAssertEqual(workingDirectory.subpathReceivedPathComponents, ["Pods", "Pods.xcodeproj"])
    }

    func test_rugbyPath() {
        workingDirectory.subpathReturnValue = "~/Developer/Rugby/Example/.rugby"

        // Assert
        XCTAssertEqual(sut.rugbyPath, "~/Developer/Rugby/Example/.rugby")
        XCTAssertEqual(workingDirectory.subpathReceivedPathComponents, [".rugby"])
    }

    func test_buildPath() {
        workingDirectory.subpathReturnValue = "~/Developer/Rugby/Example/.rugby/build"

        // Assert
        XCTAssertEqual(sut.buildPath, "~/Developer/Rugby/Example/.rugby/build")
        XCTAssertEqual(workingDirectory.subpathReceivedPathComponents, [".rugby", "build"])
    }

    func test_backupPath() {
        workingDirectory.subpathReturnValue = "~/Developer/Rugby/Example/.rugby/backup"

        // Assert
        XCTAssertEqual(sut.backupPath, "~/Developer/Rugby/Example/.rugby/backup")
        XCTAssertEqual(workingDirectory.subpathReceivedPathComponents, [".rugby", "backup"])
    }

    func test_rawLogPath() {
        XCTAssertEqual(
            sut.rawLogPath(subpath: "13.11.2023T18.09.50"),
            sharedFolderPath.subpath(".rugby", "logs", "13.11.2023T18.09.50", "rawBuild.log")
        )
    }

    func test_beautifiedLog() {
        XCTAssertEqual(
            sut.beautifiedLog(subpath: "13.11.2023T18.09.50"),
            sharedFolderPath.subpath(".rugby", "logs", "13.11.2023T18.09.50", "build.log")
        )
    }
}
