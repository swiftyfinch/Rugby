import Fish
@testable import RugbyFoundation
import XcodeProj
import XCTest

final class BuildPhaseTests: XCTestCase {
    func test_init() throws {
        let localPodGroup = PBXGroup(sourceTree: .group, name: "LocalPod", path: "LocalPod")
        let developmentPodsGroup = PBXGroup(sourceTree: .sourceRoot, name: "Development Pods")
        localPodGroup.parent = developmentPodsGroup
        let resourcesGroup = PBXGroup(sourceTree: .group, name: "Resources", path: "Resources")
        resourcesGroup.parent = localPodGroup

        // Dummy file without localization
        let dummyJSON = dummyJSONStub(parent: resourcesGroup)

        // Localization with two languages
        let localizationGroup = localicationPBXGroupStub(parent: resourcesGroup)
        let localizationChildren = localizationChildrenStub(parent: localizationGroup)
        let localizableStrings = localizationVariantGroupStub(parent: localizationGroup, children: localizationChildren)

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

    // MARK: - Stub data

    private func dummyJSONStub(parent: PBXGroup) -> PBXFileElement {
        let dummyJSON = PBXFileElement.mock(
            name: "dummy.json",
            path: "dummy.json",
            parent: parent
        )
        return dummyJSON
    }

    private func localicationPBXGroupStub(parent: PBXGroup) -> PBXGroup {
        let localizationGroup = PBXGroup(
            sourceTree: .group,
            name: "Localization",
            path: "Localization"
        )
        localizationGroup.parent = parent
        return localizationGroup
    }

    private func localizationVariantGroupStub(parent: PBXGroup, children: [PBXFileElement]) -> PBXVariantGroup {
        let localizableStrings = PBXVariantGroup.mock(
            children: children,
            name: "Localizable.strings",
            path: ".",
            parent: parent
        )
        return localizableStrings
    }

    private func localizationChildrenStub(parent: PBXGroup) -> [PBXFileElement] {
        let localizableStringsRu = PBXFileElement.mock(
            name: "Localizable.strings",
            path: "ru.lproj/Localizable.strings",
            parent: parent
        )
        let localizableStringsEn = PBXFileElement.mock(
            name: "Localizable.strings",
            path: "en.lproj/Localizable.strings",
            parent: parent
        )
        return [localizableStringsRu, localizableStringsEn]
    }
}
