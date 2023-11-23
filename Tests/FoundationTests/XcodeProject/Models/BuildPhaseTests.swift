import Fish
@testable import RugbyFoundation
import XcodeProj
import XCTest

final class BuildPhaseTests: XCTestCase {
    func test_init() throws {
        let localPodGroup = PBXGroup(sourceTree: .group, name: "LocalPod", path: "LocalPod")
        let developmentPodsGroup = PBXGroup(sourceTree: .sourceRoot, name: "Development Pods")
        localPodGroup.parent = developmentPodsGroup
        let resourcesGroup = PBXGroup(
            sourceTree: .group,
            name: "Resources",
            path: "Resources"
        )
        resourcesGroup.parent = localPodGroup
        
        // Dummy file without localization
        let dummyJSON = PBXFileElement.mock(
            name: "dummy.json",
            path: "dummy.json",
            parent: resourcesGroup
        )
        
        // Localization with two languages
        let localizationGroup = PBXGroup(
            sourceTree: .group,
            name: "Localization",
            path: "Localization")
        localizationGroup.parent = resourcesGroup
        
        let localizableStringsRu = PBXFileElement.mock(
            name: "Localizable.strings",
            path: "ru.lproj/Localizable.strings",
            parent: localizationGroup
        )
        let localizableStringsEn = PBXFileElement.mock(
            name: "Localizable.strings",
            path: "en.lproj/Localizable.strings",
            parent: localizationGroup
        )
        
        let localizableStrings = PBXVariantGroup.mock(
            children: [localizableStringsRu, localizableStringsEn],
            name: "Localizable.strings",
            path: ".'",
            parent: localizationGroup
        )
        let buildFiles = [
            dummyJSON,
            localizableStrings
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
            "\(Folder.current.path)/Pods/LocalPod/Resources/Localization"
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
