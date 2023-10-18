import Fish
@testable import RugbyFoundation
import XcodeProj
import XCTest

final class BuildPhaseTests: XCTestCase {
    func test_init() throws {
        let localPodGroup = PBXGroup(name: "LocalPod")
        let developmentPodsGroup = PBXGroup(name: "Development Pods")
        localPodGroup.parent = developmentPodsGroup
        let dummyJSON = PBXFileElement.mock(
            name: "dummy.json",
            path: "LocalPod/Resources/dummy.json",
            parent: localPodGroup
        )
        let localizableStrings = PBXFileElement.mock(
            name: "Localizable.strings",
            path: "LocalPod/Resources/Localizable.strings",
            parent: localPodGroup
        )
        let localizableStringsdict = PBXFileElement.mock(
            name: "Localizable.stringsdict",
            path: "Example", // Broken path
            parent: localPodGroup
        )
        let buildFiles = [
            dummyJSON,
            localizableStrings,
            localizableStringsdict
        ].map(PBXBuildFile.mock(file:))
        let pbxPhase = PBXResourcesBuildPhase(
            files: buildFiles,
            inputFileListPaths: nil,
            outputFileListPaths: nil,
            buildActionMask: PBXBuildPhase.defaultBuildActionMask,
            runOnlyForDeploymentPostprocessing: false
        )
        let expectedFiles = [
            "\(Folder.current.path)/Pods/LocalPod/Resources/dummy.json",
            "\(Folder.current.path)/Pods/LocalPod/Resources/Localizable.strings"
        ]

        // Act
        let phase = BuildPhase(pbxPhase)

        // Assert
        let result = try XCTUnwrap(phase)
        XCTAssertEqual(result.name, "Resources")
        XCTAssertEqual(result.type, .resources)
        XCTAssertEqual(result.buildActionMask, 2_147_483_647)
        XCTAssertFalse(result.runOnlyForDeploymentPostprocessing)
        XCTAssertTrue(result.inputFileListPaths.isEmpty)
        XCTAssertTrue(result.outputFileListPaths.isEmpty)
        XCTAssertEqual(result.files, expectedFiles)
    }
}
