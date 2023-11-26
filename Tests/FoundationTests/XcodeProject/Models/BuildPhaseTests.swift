import Fish
@testable import RugbyFoundation
import XcodeProj
import XCTest

final class BuildPhaseTests: XCTestCase {
    func test_init() throws {
        let developmentPodsGroup = PBXGroup(sourceTree: .sourceRoot, name: "LocalPods")
        let localPodGroup = PBXGroup(sourceTree: .group, name: "LocalPod")
        localPodGroup.parent = developmentPodsGroup
        let resourcesGroup = PBXGroup(sourceTree: .group, name: "LocalPod", path: "../LocalPods")
        resourcesGroup.parent = localPodGroup

        // Dummy file without localization
        let dummyJSON = dummyJSONStub(parent: resourcesGroup)

        // Localization with two languages
        let localizationGroup = localicationPBXGroupStub(parent: resourcesGroup)
        let localizationChildren = localizationChildrenStub(parent: localizationGroup)
        let localizableStrings = localizationVariantGroupStub(parent: localizationGroup, children: localizationChildren)

        // Broken path file
        let brokenPathFile = brokenFileElementPathStub(parent: localPodGroup)

        let buildFiles = [
            dummyJSON,
            localizableStrings,
            brokenPathFile
        ].map(PBXBuildFile.mock(file:))
        let pbxPhase = PBXResourcesBuildPhase(
            files: buildFiles,
            inputFileListPaths: nil,
            outputFileListPaths: nil,
            buildActionMask: PBXBuildPhase.defaultBuildActionMask,
            runOnlyForDeploymentPostprocessing: false
        )
        let expectedFiles = [
            "\(Folder.current.path)/LocalPods/LocalPod/Resources/dummy.json",
            "\(Folder.current.path)/LocalPods/Localization/LocalPod/Resources/ru.lproj/Localizable.strings",
            "\(Folder.current.path)/LocalPods/Localization/LocalPod/Resources/en.lproj/Localizable.strings"
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
            path: "LocalPod/Resources/dummy.json",
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
            path: "LocalPod/Resources",
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

    private func brokenFileElementPathStub(parent: PBXGroup) -> PBXFileElement {
        PBXFileElement.mock(
            name: "Localizable.stringsdict",
            path: "Example", // Broken path
            parent: parent
        )
    }
}
