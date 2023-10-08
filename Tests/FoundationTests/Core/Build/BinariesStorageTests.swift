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
        try await super.setUp()
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        testsFolder = try Folder.create(at: testsFolderURL.path)

        let sharedFolder = try testsFolder.createFolder(named: "shared")
        sharedPath = sharedFolder.path

        logger = ILoggerMock()
        sut = BinariesStorage(
            logger: logger,
            sharedPath: sharedPath,
            keepHashYamls: true
        )
    }

    override func tearDown() {
        super.tearDown()
        testsFolder = nil
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
        let path = try sut.binaryRelativePath(Target.rugbyFramework, buildOptions: options)

        // Assert
        XCTAssertEqual(path, "Rugby/Debug-iphonesimulator-arm64/7108f75")
    }

    func test_binaryRelativePath_error() throws {
        let expectedError = BinariesStorageError.targetHasNotProduct("Rugby")
        let expectedErrorDescription = expectedError.localizedDescription
        let target = Target.rugbyFramework
        target.product = nil

        // Act
        var errorDescription: String?
        try XCTAssertThrowsError(sut.binaryRelativePath(target, buildOptions: options)) {
            errorDescription = $0.localizedDescription
        }

        // Assert
        XCTAssertEqual(errorDescription, expectedErrorDescription)
    }

    func test_finderBinaryFolderPath() throws {
        let path = try sut.finderBinaryFolderPath(Target.rugbyFramework, buildOptions: options)

        // Assert
        XCTAssertEqual(path, sharedPath + "/Rugby/Debug-iphonesimulator-arm64/7108f75")
    }

    func test_xcodeBinaryFolderPath() throws {
        let path = try sut.xcodeBinaryFolderPath(Target.rugbyFramework)

        // Assert
        XCTAssertEqual(path, sharedPath + "/Rugby/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}-${ARCHS}/7108f75")
    }
}

extension BinariesStorageTests {
    func test_findBinaries() throws {
        let sharedFolder = try Folder.at(sharedPath)
        try sharedFolder.createFolder(named: "Rugby/Debug-iphonesimulator-arm64/7108f75")
        let rugbyFramework = Target.rugbyFramework
        let fishBundle = Target.fishBundle

        // Act
        let (found, notFound) = try sut.findBinaries(
            ofTargets: [rugbyFramework.uuid: rugbyFramework, fishBundle.uuid: fishBundle],
            buildOptions: options
        )

        // Assert
        XCTAssertEqual(found.count, 1)
        XCTAssertEqual(found.first?.key, rugbyFramework.uuid)
        XCTAssertEqual(found.first?.value.uuid, rugbyFramework.uuid)
        XCTAssertEqual(notFound.count, 1)
        XCTAssertEqual(notFound.first?.key, fishBundle.uuid)
        XCTAssertEqual(notFound.first?.value.uuid, fishBundle.uuid)
    }

    func test_saveBinaries() async throws {
        let buildFolder = try testsFolder.createFolder(named: "build")
        try buildFolder.createFolder(named: "Debug-iphonesimulator/Rugby/Rugby.framework")
        try buildFolder.createFolder(named: "Debug-iphonesimulator/Fish/Fish.bundle")
        try buildFolder.createFolder(named: "Debug-iphonesimulator/Fish/Fish.framework")
        try buildFolder.createFolder(named: "Debug-iphonesimulator/Fish/Fish.framework.dSYM")
        let rugbyFramework = Target.rugbyFramework
        let fishBundle = Target.fishBundle
        let fishFramework = Target.fishFramework

        // Act
        try await sut.saveBinaries(
            ofTargets: [
                rugbyFramework.uuid: rugbyFramework,
                fishBundle.uuid: fishBundle,
                fishFramework.uuid: fishFramework
            ],
            buildOptions: options,
            buildPaths: xcodeBuildPaths(symroot: buildFolder.path)
        )

        // Assert
        XCTAssertTrue(Folder.isExist(at: sharedPath + "/Rugby/Debug-iphonesimulator-arm64/7108f75/Rugby.framework"))
        XCTAssertTrue(File.isExist(at: sharedPath + "/Rugby/Debug-iphonesimulator-arm64/7108f75/7108f75.yml"))
        XCTAssertTrue(Folder.isExist(at: sharedPath + "/Fish/Debug-iphonesimulator-arm64/f577d09/Fish.bundle"))
        XCTAssertTrue(File.isExist(at: sharedPath + "/Fish/Debug-iphonesimulator-arm64/f577d09/f577d09.yml"))
        XCTAssertTrue(Folder.isExist(at: sharedPath + "/Fish/Debug-iphonesimulator-arm64/3c6ddd5/Fish.framework"))
        XCTAssertTrue(Folder.isExist(at: sharedPath + "/Fish/Debug-iphonesimulator-arm64/3c6ddd5/Fish.framework.dSYM"))
        XCTAssertTrue(File.isExist(at: sharedPath + "/Fish/Debug-iphonesimulator-arm64/3c6ddd5/3c6ddd5.yml"))
    }

    func test_saveBinaries_error() async throws {
        let expectedError = BinariesStorageError.targetHasNotProduct("Rugby")
        let expectedErrorDescription = expectedError.localizedDescription
        let rugbyFramework = Target.rugbyFramework
        rugbyFramework.product = nil

        // Act
        var errorDescription: String?
        do {
            try await sut.saveBinaries(
                ofTargets: [rugbyFramework.uuid: rugbyFramework],
                buildOptions: options,
                buildPaths: xcodeBuildPaths()
            )
        } catch {
            errorDescription = error.localizedDescription
        }

        // Assert
        XCTAssertEqual(errorDescription, expectedErrorDescription)
    }
}

extension BinariesStorageTests {
    func test_saveBinaries_testsResources() async throws {
        let expectedPath = "/LocalPodTestsResources/Debug-iphonesimulator-arm64/1534311/LocalPodTestsResources.bundle"
        let buildFolder = try testsFolder.createFolder(named: "build")
        try buildFolder.createFolder(named: "Debug-iphonesimulator/LocalPodTestsResources.bundle")
        let target = IInternalTargetMock()
        target.name = "LocalPod-LocalPodTestsResources"
        target.uuid = "85AE4DBF351F24EE7E81C9624B817B9E"
        target.hashContext = "LocalPodTestsResources_context"
        target.hash = "1534311"
        target.product = .init(name: "LocalPodTestsResources", moduleName: nil, type: .bundle, parentFolderName: nil)

        // Act
        try await sut.saveBinaries(
            ofTargets: [target.uuid: target],
            buildOptions: options,
            buildPaths: xcodeBuildPaths(symroot: buildFolder.path)
        )

        // Assert
        XCTAssertTrue(Folder.isExist(at: sharedPath + expectedPath))
    }

    func test_saveBinaries_library() async throws {
        let build = try testsFolder.createFolder(named: "build")
        try build.createFolder(named: "Debug-iphonesimulator/Keyboard+LayoutGuide")
        try build.createFile(named: "Debug-iphonesimulator/Keyboard+LayoutGuide/Keyboard+LayoutGuide-umbrella.h")
        try build.createFile(named: "Debug-iphonesimulator/Keyboard+LayoutGuide/KeyboardLayoutGuide.modulemap")
        try build.createFolder(named: "Debug-iphonesimulator/Keyboard+LayoutGuide/KeyboardLayoutGuide.swiftmodule")
        try build.createFile(named: "Debug-iphonesimulator/Keyboard+LayoutGuide/libKeyboard+LayoutGuide.a")
        try build.createFolder(named: "Debug-iphonesimulator/Keyboard+LayoutGuide/Swift Compatibility Header")
        let keyboardLayoutGuideLib = Target.keyboardLayoutGuideLib

        // Act
        try await sut.saveBinaries(
            ofTargets: [keyboardLayoutGuideLib.uuid: keyboardLayoutGuideLib],
            buildOptions: options,
            buildPaths: xcodeBuildPaths(symroot: build.path)
        )

        // Assert
        XCTAssertTrue(File.isExist(
            at: sharedPath + "/Keyboard+LayoutGuide/Debug-iphonesimulator-arm64/e4d65a6/Keyboard+LayoutGuide-umbrella.h"
        ))
        XCTAssertTrue(File.isExist(
            at: sharedPath + "/Keyboard+LayoutGuide/Debug-iphonesimulator-arm64/e4d65a6/KeyboardLayoutGuide.modulemap"
        ))
        XCTAssertTrue(Folder.isExist(
            at: sharedPath + "/Keyboard+LayoutGuide/Debug-iphonesimulator-arm64/e4d65a6/KeyboardLayoutGuide.swiftmodule"
        ))
        XCTAssertTrue(File.isExist(
            at: sharedPath + "/Keyboard+LayoutGuide/Debug-iphonesimulator-arm64/e4d65a6/libKeyboard+LayoutGuide.a"
        ))
        XCTAssertTrue(Folder.isExist(
            at: sharedPath + "/Keyboard+LayoutGuide/Debug-iphonesimulator-arm64/e4d65a6/Swift Compatibility Header"
        ))
        XCTAssertTrue(File.isExist(
            at: sharedPath + "/Keyboard+LayoutGuide/Debug-iphonesimulator-arm64/e4d65a6/e4d65a6.yml"
        ))
    }

    func test_saveBinaries_patchModuleMap() async throws {
        let build = try testsFolder.createFolder(named: "build")
        try build.createFolder(named: "Debug-iphonesimulator/Keyboard+LayoutGuide")
        let productPath = build.subpath("Debug-iphonesimulator/Keyboard+LayoutGuide")
        try build.createFile(
            named: "Debug-iphonesimulator/Keyboard+LayoutGuide/KeyboardLayoutGuide.modulemap",
            contents: keyboardLayoutGuideModuleMap(path: "\(productPath)/")
        )
        let keyboardLayoutGuideLib = Target.keyboardLayoutGuideLib

        // Act
        try await sut.saveBinaries(
            ofTargets: [keyboardLayoutGuideLib.uuid: keyboardLayoutGuideLib],
            buildOptions: options,
            buildPaths: xcodeBuildPaths(symroot: build.path)
        )

        // Assert
        let moduleMap = try File.at(
            sharedPath + "/Keyboard+LayoutGuide/Debug-iphonesimulator-arm64/e4d65a6/KeyboardLayoutGuide.modulemap"
        )
        XCTAssertEqual(try moduleMap.read(), keyboardLayoutGuideModuleMap())
    }
}

// MARK: - Stubs

extension BinariesStorageTests {
    private var options: XcodeBuildOptions {
        XcodeBuildOptions(sdk: .sim, config: "Debug", arch: "arm64", xcargs: [])
    }

    private func xcodeBuildPaths(symroot: String = "symroot") -> XcodeBuildPaths {
        .init(
            project: "project",
            symroot: symroot,
            rawLog: "rawLog",
            beautifiedLog: "beautifiedLog"
        )
    }

    private func keyboardLayoutGuideModuleMap(path: String = "") -> String {
        """
        module KeyboardLayoutGuide {
            umbrella header "Keyboard+LayoutGuide-umbrella.h"

            export *
            module * { export * }
        }

        module KeyboardLayoutGuide.Swift {
            header "\(path)Swift Compatibility Header/KeyboardLayoutGuide-Swift.h"
            requires objc
        }
        """
    }
}
