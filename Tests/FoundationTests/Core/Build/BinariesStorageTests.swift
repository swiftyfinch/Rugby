import Fish
@testable import RugbyFoundation
import XcodeProj
import XCTest

final class BinariesStorageTests: XCTestCase {
    private var testsFolder: IFolder!
    private var sharedPath: String!
    private var logger: ILoggerMock!
    private var sut: IBinariesStorage!

    override func setUp() async throws {
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        testsFolder = try Folder.create(at: testsFolderURL.path)

        let sharedFolder = try testsFolder.createFolder(named: "shared")
        sharedPath = sharedFolder.path

        logger = ILoggerMock()
        sut = BinariesStorage(
            logger: logger,
            sharedPath: sharedPath,
            keepHashYamls: false
        )
    }

    override func tearDown() {
        super.tearDown()
        sharedPath = nil
        logger = nil
        sut = nil
    }
}

extension BinariesStorageTests {
    func test_sharedPath() {
        XCTAssertEqual(sut.sharedPath, sharedPath)
    }

    func test_binaryRelativePath() throws {
        let path = try sut.binaryRelativePath(rugbyTarget, buildOptions: options)

        // Assert
        XCTAssertEqual(path, "Rugby/Debug-iphonesimulator-arm64/36ff0bc")
    }

    func test_finderBinaryFolderPath() throws {
        let path = try sut.finderBinaryFolderPath(rugbyTarget, buildOptions: options)

        // Assert
        XCTAssertEqual(path, sharedPath + "/Rugby/Debug-iphonesimulator-arm64/36ff0bc")
    }

    func test_xcodeBinaryFolderPath() throws {
        let path = try sut.xcodeBinaryFolderPath(rugbyTarget)

        // Assert
        XCTAssertEqual(path, sharedPath + "/Rugby/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/36ff0bc")
    }
}

extension BinariesStorageTests {
    func test_findBinaries() throws {
        let sharedFolder = try Folder.at(sharedPath)
        try sharedFolder.createFolder(named: "Rugby/Debug-iphonesimulator-arm64/36ff0bc")

        // Act
        let (found, notFound) = try sut.findBinaries(
            ofTargets: [rugbyTarget.uuid: rugbyTarget, fishBundleTarget.uuid: fishBundleTarget],
            buildOptions: options
        )

        // Assert
        XCTAssertEqual(found.count, 1)
        XCTAssertEqual(found.first?.key, rugbyTarget.uuid)
        XCTAssertEqual(found.first?.value.uuid, rugbyTarget.uuid)
        XCTAssertEqual(notFound.count, 1)
        XCTAssertEqual(notFound.first?.key, fishBundleTarget.uuid)
        XCTAssertEqual(notFound.first?.value.uuid, fishBundleTarget.uuid)
    }

    func test_saveBinaries() async throws {
        let buildFolder = try testsFolder.createFolder(named: "build")
        try buildFolder.createFolder(named: "Debug-iphonesimulator/Rugby/Rugby.framework")
        try buildFolder.createFolder(named: "Debug-iphonesimulator/Fish/Fish.bundle")
        try buildFolder.createFolder(named: "Debug-iphonesimulator/Fish/Fish.framework")

        let xcodeBuildPaths = XcodeBuildPaths(
            project: "project",
            symroot: buildFolder.path,
            rawLog: "rawLog",
            beautifiedLog: "beautifiedLog"
        )

        // Act
        try await sut.saveBinaries(
            ofTargets: [
                rugbyTarget.uuid: rugbyTarget,
                fishBundleTarget.uuid: fishBundleTarget,
                fishTarget.uuid: fishTarget
            ],
            buildOptions: options,
            buildPaths: xcodeBuildPaths
        )

        // Assert
        XCTAssertTrue(Folder.isExist(at: sharedPath + "/Rugby/Debug-iphonesimulator-arm64/36ff0bc/Rugby.framework"))
        XCTAssertTrue(Folder.isExist(at: sharedPath + "/Fish/Debug-iphonesimulator-arm64/kf25ac1/Fish.bundle"))
        XCTAssertTrue(Folder.isExist(at: sharedPath + "/Fish/Debug-iphonesimulator-arm64/j312903/Fish.framework"))
    }
}

// MARK: - Stubs

extension BinariesStorageTests {
    private var options: XcodeBuildOptions {
        XcodeBuildOptions(sdk: .sim, config: "Debug", arch: "arm64", xcargs: [])
    }

    private var rugbyTarget: IInternalTargetMock {
        let target = IInternalTargetMock()
        target.name = "Rugby"
        target.uuid = "FAEEE7E885B9E4DB1C9624B817351F24"
        target.hash = "36ff0bc"
        target.product = .init(name: "Rugby", type: .framework, parentFolderName: "Rugby")
        return target
    }

    private var fishBundleTarget: IInternalTargetMock {
        let target = IInternalTargetMock()
        target.name = "Fish"
        target.uuid = "B1C9624B817351F24FAEEE7E885B9E4D"
        target.hash = "kf25ac1"
        target.product = .init(name: "Fish", type: .bundle, parentFolderName: "Fish")
        return target
    }

    private var fishTarget: IInternalTargetMock {
        let target = IInternalTargetMock()
        target.name = "Fish"
        target.uuid = "817351F24FAEEE7B1C9624BE885B9E4D"
        target.hash = "j312903"
        target.product = .init(name: "Fish", type: .framework, parentFolderName: "Fish")
        return target
    }
}
