import Fish
@testable import RugbyFoundation
import XCTest

final class TestplanEditorTests: XCTestCase {
    private var sut: ITestplanEditor!
    private var workingDirectory: IFolder!
    private var xcodeProject: IInternalXcodeProjectMock!

    override func setUp() async throws {
        try await super.setUp()
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        let testsFolder = try Folder.create(at: testsFolderURL.path)
        workingDirectory = try testsFolder.createFolder(named: "workingDirectory")
        xcodeProject = IInternalXcodeProjectMock()
        sut = TestplanEditor(xcodeProject: xcodeProject, workingDirectory: workingDirectory)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        workingDirectory = nil
        xcodeProject = nil
    }
}

extension TestplanEditorTests {
    func test_expandTestplanPath_error() throws {
        let path = workingDirectory.subpath("Rugby")

        // Act
        var resultError: Error?
        do {
            _ = try sut.expandTestplanPath(path)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(
            (resultError as? TestplanEditorError)?.localizedDescription,
            "Incorrect testplan path: \(path)"
        )
    }

    func test_expandTestplanPath() throws {
        let path0 = try workingDirectory.createFolder(named: "Test").createFile(named: "Rugby.xctestplan").path
        let path1 = try workingDirectory.createFolder(named: "Test2").createFile(named: "Rugby").path
        let path2 = try workingDirectory.createFile(named: "Rugby.xctestplan").path

        // Assert
        XCTAssertEqual(
            try sut.expandTestplanPath(path0),
            workingDirectory.subpath("Test/Rugby.xctestplan")
        )
        XCTAssertEqual(
            try sut.expandTestplanPath(URL(fileURLWithPath: path0).deletingPathExtension().path),
            workingDirectory.subpath("Test/Rugby.xctestplan")
        )
        XCTAssertEqual(
            try sut.expandTestplanPath(path1),
            workingDirectory.subpath("Test2/Rugby")
        )
        XCTAssertEqual(
            try sut.expandTestplanPath(path2),
            workingDirectory.subpath("Rugby.xctestplan")
        )
    }

    func test_createTestplan() throws {
        let expectedRawTestplanData = Data("""
        {
          "configurations" : [
            {
              "id" : "30DD38ED-9F3D-47C6-B30E-3ED2DE294EE1",
              "name" : "Test Scheme Action",
              "options" : {

              }
            }
          ],
          "defaultOptions" : {
            "codeCoverage" : false,
            "targetForVariableExpansion" : {
              "containerPath" : "container:Example.xcodeproj",
              "identifier" : "230878162A8D3D6900AEB6A7",
              "name" : "ExampleFrameworks"
            }
          },
          "testTargets" : [
            {
              "parallelizable" : true,
              "target" : {
                "containerPath" : "container:Pods.xcodeproj",
                "identifier" : "localPodFrameworkUnitTests_uuid",
                "name" : "LocalPod-framework-Unit-Tests"
              }
            }
          ],
          "version" : 1
        }
        """.utf8)
        let json = try JSONSerialization.jsonObject(with: expectedRawTestplanData)
        let expectedTestplanData = try JSONSerialization.data(
            withJSONObject: json,
            options: [.prettyPrinted, .sortedKeys]
        )

        let testsFolder = try workingDirectory.createFolder(named: "tests")
        let templateName = "ExampleFrameworks.xctestplan"
        let testplanTemplate = try workingDirectory.createFile(
            named: templateName,
            contents: """
            {
              "configurations" : [
                {
                  "id" : "30DD38ED-9F3D-47C6-B30E-3ED2DE294EE1",
                  "name" : "Test Scheme Action",
                  "options" : {

                  }
                }
              ],
              "defaultOptions" : {
                "codeCoverage" : false,
                "targetForVariableExpansion" : {
                  "containerPath" : "container:Example.xcodeproj",
                  "identifier" : "230878162A8D3D6900AEB6A7",
                  "name" : "ExampleFrameworks"
                }
              },
              "testTargets" : [
                {
                  "parallelizable" : true,
                  "target" : {
                    "containerPath" : "container:Example.xcodeproj",
                    "identifier" : "2308782B2A8D3E3A00AEB6A7",
                    "name" : "ExampleFrameworksTests"
                  }
                },
                {
                  "parallelizable" : true,
                  "target" : {
                    "containerPath" : "container:../Pods/Pods.xcodeproj",
                    "identifier" : "9FC54710DA1E4DFE1328C2E13F374466",
                    "name" : "LocalPod-framework-Unit-ResourceBundleTests"
                  }
                },
                {
                  "parallelizable" : true,
                  "target" : {
                    "containerPath" : "container:../Pods/Pods.xcodeproj",
                    "identifier" : "6DE522075EFDB1984E48E6FC929F0DC0",
                    "name" : "LocalPod-framework-Unit-Tests"
                  }
                }
              ],
              "version" : 1
            }
            """
        )

        let project = IProjectMock()
        let localPodFrameworkUnitTests = IInternalTargetMock()
        localPodFrameworkUnitTests.underlyingProject = project
        project.underlyingPath = "Pods/Pods.xcodeproj"
        localPodFrameworkUnitTests.underlyingUuid = "localPodFrameworkUnitTests_uuid"
        localPodFrameworkUnitTests.underlyingName = "LocalPod-framework-Unit-Tests"
        let testTargets = [localPodFrameworkUnitTests.uuid: localPodFrameworkUnitTests]

        xcodeProject.readWorkspaceProjectPathsReturnValue = [
            "\(workingDirectory.path)/Example/Example.xcodeproj",
            "\(workingDirectory.path)/Pods/Pods.xcodeproj"
        ]

        // Act
        let testplanPath = try sut.createTestplan(
            testplanTemplatePath: testplanTemplate.path,
            testTargets: testTargets,
            inFolderPath: testsFolder.path
        )

        // Assert
        XCTAssertEqual(testplanPath.path, "\(workingDirectory.path)/tests/Rugby.xctestplan")
        let testplan = try testsFolder.file(named: "Rugby.xctestplan")
        XCTAssertEqual(try testplan.readData(), expectedTestplanData)
    }
}
