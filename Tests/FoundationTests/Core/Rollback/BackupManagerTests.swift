import Fish
@testable import RugbyFoundation
import XCTest

final class BackupManagerTests: XCTestCase {
    private var sut: IBackupManager!
    private var workingDirectory: IFolder!
    private var backupFolder: IFolder!

    override func setUp() async throws {
        try await super.setUp()
        let tmp = FileManager.default.temporaryDirectory
        let testsFolderURL = tmp.appendingPathComponent(UUID().uuidString)
        workingDirectory = try Folder.create(at: testsFolderURL.path)
        let localRugbyFolder = try workingDirectory.createFolder(named: ".rugby")
        backupFolder = try localRugbyFolder.createFolder(named: "backup")
        sut = BackupManager(
            backupFolderPath: backupFolder.path,
            workingDirectory: workingDirectory,
            hasBackupKey: "RUGBY_HAS_BACKUP"
        )
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        workingDirectory = nil
        backupFolder = nil
    }
}

extension BackupManagerTests {
    func test_backup_tmp() async throws {
        let pods = try workingDirectory.createFolder(named: "Pods")
        let projectFolder = try pods.createFolder(named: "Pods.xcodeproj")
        try projectFolder.createFile(named: "project.pbxproj", contents: "test_pbxproj_content")
        let workspace = try projectFolder.createFolder(named: "project.xcworkspace")
        try workspace.createFile(named: "contents.xcworkspacedata", contents: "test_workspace_content")
        let targetSupportFiles = try pods.createFolder(named: "Target Support Files")
        let alamofire = try targetSupportFiles.createFolder(named: "Alamofire-framework")
        try alamofire.createFile(named: "Alamofire-framework.debug.xcconfig",
                                 contents: "test_alamofire.debug.xcconfig_content")
        try alamofire.createFile(named: "Alamofire-framework.release.xcconfig",
                                 contents: "test_alamofire.release.xcconfig_content")
        let podsExample = try targetSupportFiles.createFolder(named: "Pods-ExampleFrameworks")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-resources.sh",
                                   contents: "test_podsExample.resources_content")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-frameworks.sh",
                                   contents: "test_podsExample.frameworks_content")

        let xcodeProject = IXcodeProjectMock()
        xcodeProject.folderPathsReturnValue = [projectFolder.path]

        // Act
        try await sut.backup(xcodeProject, kind: .tmp)

        // Assert
        XCTAssertTrue(File.isExist(at: backupFolder.subpath("tmp/Pods/Pods/Pods.xcodeproj/project.pbxproj")))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "tmp/Pods/Pods/Pods.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
        )))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "tmp/Pods/Pods/Target Support Files/Alamofire-framework/Alamofire-framework.debug.xcconfig"
        )))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "tmp/Pods/Pods/Target Support Files/Alamofire-framework/Alamofire-framework.release.xcconfig"
        )))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "tmp/Pods/Pods/Target Support Files/Pods-ExampleFrameworks/Pods-ExampleFrameworks-frameworks.sh"
        )))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "tmp/Pods/Pods/Target Support Files/Pods-ExampleFrameworks/Pods-ExampleFrameworks-resources.sh"
        )))
    }

    func test_backup_original() async throws {
        let pods = try workingDirectory.createFolder(named: "Pods")
        let projectFolder = try pods.createFolder(named: "Pods.xcodeproj")
        try projectFolder.createFile(named: "project.pbxproj", contents: "test_pbxproj_content")
        let workspace = try projectFolder.createFolder(named: "project.xcworkspace")
        try workspace.createFile(named: "contents.xcworkspacedata", contents: "test_workspace_content")
        let targetSupportFiles = try pods.createFolder(named: "Target Support Files")
        let alamofire = try targetSupportFiles.createFolder(named: "Alamofire-framework")
        try alamofire.createFile(named: "Alamofire-framework.debug.xcconfig",
                                 contents: "test_alamofire.debug.xcconfig_content")
        try alamofire.createFile(named: "Alamofire-framework.release.xcconfig",
                                 contents: "test_alamofire.release.xcconfig_content")
        let podsExample = try targetSupportFiles.createFolder(named: "Pods-ExampleFrameworks")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-resources.sh",
                                   contents: "test_podsExample.resources_content")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-frameworks.sh",
                                   contents: "test_podsExample.frameworks_content")

        let xcodeProject = IXcodeProjectMock()
        xcodeProject.folderPathsReturnValue = [projectFolder.path]
        xcodeProject.containsBuildSettingsKeyReturnValue = false

        // Act
        try await sut.backup(xcodeProject, kind: .original)

        // Assert
        XCTAssertEqual(xcodeProject.containsBuildSettingsKeyReceivedInvocations, ["RUGBY_HAS_BACKUP"])
        XCTAssertTrue(File.isExist(at: backupFolder.subpath("original/Pods/Pods/Pods.xcodeproj/project.pbxproj")))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "original/Pods/Pods/Pods.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
        )))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "original/Pods/Pods/Target Support Files/Alamofire-framework/Alamofire-framework.debug.xcconfig"
        )))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "original/Pods/Pods/Target Support Files/Alamofire-framework/Alamofire-framework.release.xcconfig"
        )))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "original/Pods/Pods/Target Support Files/Pods-ExampleFrameworks/Pods-ExampleFrameworks-frameworks.sh"
        )))
        XCTAssertTrue(File.isExist(at: backupFolder.subpath(
            "original/Pods/Pods/Target Support Files/Pods-ExampleFrameworks/Pods-ExampleFrameworks-resources.sh"
        )))
    }

    func test_backup_original_alreadyHasBackup() async throws {
        let pods = try workingDirectory.createFolder(named: "Pods")
        let projectFolder = try pods.createFolder(named: "Pods.xcodeproj")
        try projectFolder.createFile(named: "project.pbxproj", contents: "test_pbxproj_content")
        let workspace = try projectFolder.createFolder(named: "project.xcworkspace")
        try workspace.createFile(named: "contents.xcworkspacedata", contents: "test_workspace_content")
        let targetSupportFiles = try pods.createFolder(named: "Target Support Files")
        let alamofire = try targetSupportFiles.createFolder(named: "Alamofire-framework")
        try alamofire.createFile(named: "Alamofire-framework.debug.xcconfig",
                                 contents: "test_alamofire.debug.xcconfig_content")
        try alamofire.createFile(named: "Alamofire-framework.release.xcconfig",
                                 contents: "test_alamofire.release.xcconfig_content")
        let podsExample = try targetSupportFiles.createFolder(named: "Pods-ExampleFrameworks")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-resources.sh",
                                   contents: "test_podsExample.resources_content")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-frameworks.sh",
                                   contents: "test_podsExample.frameworks_content")

        let xcodeProject = IXcodeProjectMock()
        xcodeProject.folderPathsReturnValue = [projectFolder.path]
        xcodeProject.containsBuildSettingsKeyReturnValue = true

        // Act
        try await sut.backup(xcodeProject, kind: .original)

        // Assert
        XCTAssertEqual(xcodeProject.containsBuildSettingsKeyReceivedInvocations, ["RUGBY_HAS_BACKUP"])
        try XCTAssertTrue(backupFolder.isEmpty())
    }
}

extension BackupManagerTests {
    func test_restore_tmp() async throws {
        let tmpFolder = try backupFolder.createFolder(named: "tmp")
        let pods = try tmpFolder.createFolder(named: "Pods").createFolder(named: "Pods")
        let projectFolder = try pods.createFolder(named: "Pods.xcodeproj")
        try projectFolder.createFile(named: "project.pbxproj", contents: "test_pbxproj_content")
        let workspace = try projectFolder.createFolder(named: "project.xcworkspace")
        try workspace.createFile(named: "contents.xcworkspacedata", contents: "test_workspace_content")
        let targetSupportFiles = try pods.createFolder(named: "Target Support Files")
        let alamofire = try targetSupportFiles.createFolder(named: "Alamofire-framework")
        try alamofire.createFile(named: "Alamofire-framework.debug.xcconfig",
                                 contents: "test_alamofire.debug.xcconfig_content")
        try alamofire.createFile(named: "Alamofire-framework.release.xcconfig",
                                 contents: "test_alamofire.release.xcconfig_content")
        let podsExample = try targetSupportFiles.createFolder(named: "Pods-ExampleFrameworks")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-resources.sh",
                                   contents: "test_podsExample.resources_content")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-frameworks.sh",
                                   contents: "test_podsExample.frameworks_content")

        // Act
        try await sut.asyncRestore(.tmp)

        // Assert
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath("Pods/Pods.xcodeproj/project.pbxproj")))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Pods.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
        )))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Target Support Files/Alamofire-framework/Alamofire-framework.debug.xcconfig"
        )))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Target Support Files/Alamofire-framework/Alamofire-framework.release.xcconfig"
        )))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Target Support Files/Pods-ExampleFrameworks/Pods-ExampleFrameworks-frameworks.sh"
        )))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Target Support Files/Pods-ExampleFrameworks/Pods-ExampleFrameworks-resources.sh"
        )))
    }

    func test_restore_original() async throws {
        let originalFolder = try backupFolder.createFolder(named: "original")
        let pods = try originalFolder.createFolder(named: "Pods").createFolder(named: "Pods")
        let projectFolder = try pods.createFolder(named: "Pods.xcodeproj")
        try projectFolder.createFile(named: "project.pbxproj", contents: "test_pbxproj_content")
        let xcschemes = try projectFolder.createFolder(named: "xcuserdata/swiftyfinch.xcuserdatad/xcschemes")
        try xcschemes.createFile(named: "Pods-ExampleFrameworks.xcscheme")
        let workspace = try projectFolder.createFolder(named: "project.xcworkspace")
        try workspace.createFile(named: "contents.xcworkspacedata", contents: "test_workspace_content")
        let targetSupportFiles = try pods.createFolder(named: "Target Support Files")
        let alamofire = try targetSupportFiles.createFolder(named: "Alamofire-framework")
        try alamofire.createFile(named: "Alamofire-framework.debug.xcconfig",
                                 contents: "test_alamofire.debug.xcconfig_content")
        try alamofire.createFile(named: "Alamofire-framework.release.xcconfig",
                                 contents: "test_alamofire.release.xcconfig_content")
        let podsExample = try targetSupportFiles.createFolder(named: "Pods-ExampleFrameworks")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-resources.sh",
                                   contents: "test_podsExample.resources_content")
        try podsExample.createFile(named: "Pods-ExampleFrameworks-frameworks.sh",
                                   contents: "test_podsExample.frameworks_content")

        let currentXCSchemes = try workingDirectory.createFolder(
            named: "Pods/Pods.xcodeproj/xcuserdata/swiftyfinch.xcuserdatad/xcschemes"
        )
        try currentXCSchemes.createFile(named: "RugbyPods.xcscheme")

        // Act
        try await sut.asyncRestore(.original)

        // Assert
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath("Pods/Pods.xcodeproj/project.pbxproj")))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Pods.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
        )))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Target Support Files/Alamofire-framework/Alamofire-framework.debug.xcconfig"
        )))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Target Support Files/Alamofire-framework/Alamofire-framework.release.xcconfig"
        )))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Target Support Files/Pods-ExampleFrameworks/Pods-ExampleFrameworks-frameworks.sh"
        )))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Target Support Files/Pods-ExampleFrameworks/Pods-ExampleFrameworks-resources.sh"
        )))
        XCTAssertTrue(File.isExist(at: workingDirectory.subpath(
            "Pods/Pods.xcodeproj/xcuserdata/swiftyfinch.xcuserdatad/xcschemes/Pods-ExampleFrameworks.xcscheme"
        )))
        XCTAssertFalse(File.isExist(at: workingDirectory.subpath(
            "Pods/Pods.xcodeproj/xcuserdata/swiftyfinch.xcuserdatad/xcschemes/RugbyPods.xcscheme"
        )))
    }

    func test_restore_missingBackup() {
        var resultError: Error?
        do {
            try sut.restore(.original)
        } catch {
            resultError = error
        }

        // Assert
        XCTAssertEqual(resultError as? BackupManagerError, .missingBackup)
        XCTAssertEqual(resultError?.localizedDescription, "Can't find backup.")
    }
}
