import Rainbow
@testable import RugbyFoundation
import XcbeautifyLib
import XCTest

// swiftlint:disable line_length
// swiftlint:disable file_length

final class BuildLogFormatterTests: XCTestCase {
    private var workingDirectory: IFolderMock!

    override func setUp() {
        super.setUp()
        workingDirectory = IFolderMock()
        workingDirectory.underlyingPath = "/Users/swiftyfinch/Developer/Git/Rugby/Example"
        Rainbow.outputTarget = .console
    }

    override func tearDown() {
        super.tearDown()
        workingDirectory = nil
    }

    private func makeSut(colored: Bool) -> IBuildLogFormatter {
        Rainbow.enabled = colored
        return BuildLogFormatter(workingDirectory: workingDirectory, colored: Rainbow.enabled)
    }

    private func act(sut: IBuildLogFormatter, input: String) throws -> [(text: String, type: OutputType)] {
        var output: [(text: String, type: OutputType)] = []
        let lines = input.components(separatedBy: .newlines)
        try lines.forEach { line in
            try sut.format(line: line, output: { output.append(($0, $1)) })
        }
        try sut.finish(output: { output.append(($0, $1)) })
        return output
    }
}

// MARK: - No Color

extension BuildLogFormatterTests {
    func test_formatStandardError() throws {
        let sut = makeSut(colored: false)
        let input = """
        /Users/swiftyfinch/Developer/Git/Rugby/Example/Pods/Alamofire/Source/Request.swift:1528:33: error: 'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()')
                                        stream: @escaping Handler<some Any, some Any>) {
                                        ^
        """
        let expected = """
        'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()').
        Pods/Alamofire/Source/Request.swift:1528:33:
        stream: @escaping Handler<some Any, some Any>) {
        ^
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output[0].text, expected)
        XCTAssertEqual(output[0].type, .error)
    }

    func test_formatStandardErrors() throws {
        let sut = makeSut(colored: false)
        let input = """
        /Users/swiftyfinch/Developer/Git/Rugby/Example/Pods/Alamofire/Source/Request.swift:1528:33: error: 'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()')
                                        stream: @escaping Handler<some Any, some Any>) {
                                        ^
        /Users/swiftyfinch/Developer/Git/Rugby/Example/Pods/Alamofire/Source/Request.swift:1549:28: error: 'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()')
                                   stream: @escaping Handler<some Any, some Any>) {
                                   ^
        """
        let expected0 = """
        'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()').
        Pods/Alamofire/Source/Request.swift:1528:33:
        stream: @escaping Handler<some Any, some Any>) {
        ^
        """
        let expected1 = """
        'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()').
        Pods/Alamofire/Source/Request.swift:1549:28:
        stream: @escaping Handler<some Any, some Any>) {
        ^
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 2)
        XCTAssertEqual(output[0].text, expected0)
        XCTAssertEqual(output[0].type, .error)
        XCTAssertEqual(output[1].text, expected1)
        XCTAssertEqual(output[1].type, .error)
    }

    func test_formatManyStandardErrors() throws {
        let sut = makeSut(colored: false)
        let input = """
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:1: error: expressions are not allowed at the top level
        exension Bundle {
        ^
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:9: error: consecutive statements on a line must be separated by ';'
        exension Bundle {
                ^
                ;
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:6:12: error: static properties may only be declared on a type
            static let resourcesBundle: Bundle! = {
            ~~~~~~~^

        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:10: error: expressions are not allowed at the top level
        exension Bundle {
                 ^
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:1: error: cannot find 'exension' in scope
        exension Bundle {
        ^~~~~~~~
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:10: error: no exact matches in call to initializer
        exension Bundle {
                 ^
        """
        let expected0 = """
        Expressions are not allowed at the top level.
        LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:1:
        exension Bundle {
        ^
        """
        let expected1 = """
        Consecutive statements on a line must be separated by \';\'.
        LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:9:
        exension Bundle {
                ^
        """
        let expected2 = """
        Static properties may only be declared on a type.
        LocalPods/LocalPod/Sources/Bundle+Resources.swift:6:12:
        static let resourcesBundle: Bundle! = {
        ~~~~~~~^
        """
        let expected3 = """
        Expressions are not allowed at the top level.
        LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:10:
        exension Bundle {
                 ^
        """
        let expected4 = """
        Cannot find \'exension\' in scope.
        LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:1:
        exension Bundle {
        ^~~~~~~~
        """
        let expected5 = """
        No exact matches in call to initializer.
        LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:10:
        exension Bundle {
                 ^
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 6)
        XCTAssertEqual(output[0].text, expected0)
        XCTAssertEqual(output[0].type, .error)
        XCTAssertEqual(output[1].text, expected1)
        XCTAssertEqual(output[1].type, .error)
        XCTAssertEqual(output[2].text, expected2)
        XCTAssertEqual(output[2].type, .error)
        XCTAssertEqual(output[3].text, expected3)
        XCTAssertEqual(output[3].type, .error)
        XCTAssertEqual(output[4].text, expected4)
        XCTAssertEqual(output[4].type, .error)
        XCTAssertEqual(output[5].text, expected5)
        XCTAssertEqual(output[5].type, .error)
    }

    func test_formatMultipleCommandsProduceError() throws {
        let sut = makeSut(colored: false)
        let input = """
        error: Multiple commands produce '/Users/swiftyfinch/Developer/Git/Rugby/Example/.rugby/build/Debug-iphonesimulator/LocalPodResourceBundleTestsResources.bundle/dummy.json'
            note: Target 'LocalPod-framework-LocalPodResourceBundleTestsResources' (project 'Pods') has copy command from '/Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/ResourceBundleTests/dummy.json' to '/Users/swiftyfinch/Developer/Git/Rugby/Example/.rugby/build/Debug-iphonesimulator/LocalPodResourceBundleTestsResources.bundle/dummy.json'
        """
        let expected = """
        Multiple commands produce '.rugby/build/Debug-iphonesimulator/LocalPodResourceBundleTestsResources.bundle/dummy.json'
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output[0].text, expected)
        XCTAssertEqual(output[0].type, .error)
    }

    func test_formatUnableToLoadContentsError() throws {
        let sut = makeSut(colored: false)
        let input = """
        error: Unable to load contents of file list: '/Target Support Files/SnapKit-framework/SnapKit-framework-xcframeworks-input-files.xcfilelist' (in target 'SnapKit-framework' from project 'Pods')
        """
        let expected = """
        Unable to load contents of file list: '/Target Support Files/SnapKit-framework/SnapKit-framework-xcframeworks-input-files.xcfilelist' (in target 'SnapKit-framework' from project 'Pods')
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output[0].text, expected)
        XCTAssertEqual(output[0].type, .error)
    }

    func test_formatBuildInputFileCannotBeFoundError() throws {
        let sut = makeSut(colored: false)
        let input = """
        error: Build input file cannot be found: '/Users/swiftyfinch/Developer/Git/Rugby/Example/.rugby/build/Debug-iphonesimulator/SnapKit/SnapKit.framework/SnapKit'. Did you forget to declare this file as an output of a script phase or custom build rule which produces it? (in target 'SnapKit' from project 'Pods')
        """
        let expected = """
        Build input file cannot be found: '.rugby/build/Debug-iphonesimulator/SnapKit/SnapKit.framework/SnapKit'. Did you forget to declare this file as an output of a script phase or custom build rule which produces it? (in target 'SnapKit' from project 'Pods')
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output[0].text, expected)
        XCTAssertEqual(output[0].type, .error)
    }
}

// MARK: - Colored

extension BuildLogFormatterTests {
    func test_formatStandardError_colored() throws {
        let sut = makeSut(colored: true)
        let input = """
        /Users/swiftyfinch/Developer/Git/Rugby/Example/Pods/Alamofire/Source/Request.swift:1528:33: error: 'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()')
                                        stream: @escaping Handler<some Any, some Any>) {
                                        ^
        """
        let expected = """
        \("'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()').".red)
        \("Pods/Alamofire/Source/Request.swift:1528:33:".yellow)
        \("stream: @escaping Handler<some Any, some Any>) {".white)
        \("^".cyan)
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output[0].text, expected)
        XCTAssertEqual(output[0].type, .error)
    }

    func test_formatStandardErrors_colored() throws {
        let sut = makeSut(colored: true)
        let input = """
        /Users/swiftyfinch/Developer/Git/Rugby/Example/Pods/Alamofire/Source/Request.swift:1528:33: error: 'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()')
                                        stream: @escaping Handler<some Any, some Any>) {
                                        ^
        /Users/swiftyfinch/Developer/Git/Rugby/Example/Pods/Alamofire/Source/Request.swift:1549:28: error: 'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()')
                                   stream: @escaping Handler<some Any, some Any>) {
                                   ^
        """
        let expected0 = """
        \("'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()').".red)
        \("Pods/Alamofire/Source/Request.swift:1528:33:".yellow)
        \("stream: @escaping Handler<some Any, some Any>) {".white)
        \("^".cyan)
        """
        let expected1 = """
        \("'some' cannot appear in parameter position in parameter type 'DataStreamRequest.Handler<some Any, some Any>' (aka '(DataStreamRequest.Stream<some Any, some Any>) throws -> ()').".red)
        \("Pods/Alamofire/Source/Request.swift:1549:28:".yellow)
        \("stream: @escaping Handler<some Any, some Any>) {".white)
        \("^".cyan)
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 2)
        XCTAssertEqual(output[0].text, expected0)
        XCTAssertEqual(output[0].type, .error)
        XCTAssertEqual(output[1].text, expected1)
        XCTAssertEqual(output[1].type, .error)
    }

    func test_formatManyStandardErrors_colored() throws {
        let sut = makeSut(colored: true)
        let input = """
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:1: error: expressions are not allowed at the top level
        exension Bundle {
        ^
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:9: error: consecutive statements on a line must be separated by ';'
        exension Bundle {
                ^
                ;
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:6:12: error: static properties may only be declared on a type
            static let resourcesBundle: Bundle! = {
            ~~~~~~~^

        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:10: error: expressions are not allowed at the top level
        exension Bundle {
                 ^
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:1: error: cannot find 'exension' in scope
        exension Bundle {
        ^~~~~~~~
        /Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:10: error: no exact matches in call to initializer
        exension Bundle {
                 ^
        """
        let expected0 = """
        \("Expressions are not allowed at the top level.".red)
        \("LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:1:".yellow)
        \("exension Bundle {".white)
        \("^".cyan)
        """
        let expected1 = """
        \("Consecutive statements on a line must be separated by \';\'.".red)
        \("LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:9:".yellow)
        \("exension Bundle {".white)
        \("        ^".cyan)
        """
        let expected2 = """
        \("Static properties may only be declared on a type.".red)
        \("LocalPods/LocalPod/Sources/Bundle+Resources.swift:6:12:".yellow)
        \("static let resourcesBundle: Bundle! = {".white)
        \("~~~~~~~^".cyan)
        """
        let expected3 = """
        \("Expressions are not allowed at the top level.".red)
        \("LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:10:".yellow)
        \("exension Bundle {".white)
        \("         ^".cyan)
        """
        let expected4 = """
        \("Cannot find \'exension\' in scope.".red)
        \("LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:1:".yellow)
        \("exension Bundle {".white)
        \("^~~~~~~~".cyan)
        """
        let expected5 = """
        \("No exact matches in call to initializer.".red)
        \("LocalPods/LocalPod/Sources/Bundle+Resources.swift:5:10:".yellow)
        \("exension Bundle {".white)
        \("         ^".cyan)
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 6)
        XCTAssertEqual(output[0].text, expected0)
        XCTAssertEqual(output[0].type, .error)
        XCTAssertEqual(output[1].text, expected1)
        XCTAssertEqual(output[1].type, .error)
        XCTAssertEqual(output[2].text, expected2)
        XCTAssertEqual(output[2].type, .error)
        XCTAssertEqual(output[3].text, expected3)
        XCTAssertEqual(output[3].type, .error)
        XCTAssertEqual(output[4].text, expected4)
        XCTAssertEqual(output[4].type, .error)
        XCTAssertEqual(output[5].text, expected5)
        XCTAssertEqual(output[5].type, .error)
    }

    func test_formatMultipleCommandsProduceError_colored() throws {
        let sut = makeSut(colored: true)
        let input = """
        error: Multiple commands produce '/Users/swiftyfinch/Developer/Git/Rugby/Example/.rugby/build/Debug-iphonesimulator/LocalPodResourceBundleTestsResources.bundle/dummy.json'
            note: Target 'LocalPod-framework-LocalPodResourceBundleTestsResources' (project 'Pods') has copy command from '/Users/swiftyfinch/Developer/Git/Rugby/Example/LocalPods/LocalPod/ResourceBundleTests/dummy.json' to '/Users/swiftyfinch/Developer/Git/Rugby/Example/.rugby/build/Debug-iphonesimulator/LocalPodResourceBundleTestsResources.bundle/dummy.json'
        """
        let expected = """
        Multiple commands produce '.rugby/build/Debug-iphonesimulator/LocalPodResourceBundleTestsResources.bundle/dummy.json'
        """.red

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output[0].text, expected)
        XCTAssertEqual(output[0].type, .error)
    }

    func test_formatUnableToLoadContentsError_colored() throws {
        let sut = makeSut(colored: true)
        let input = """
        error: Unable to load contents of file list: '/Target Support Files/SnapKit-framework/SnapKit-framework-xcframeworks-input-files.xcfilelist' (in target 'SnapKit-framework' from project 'Pods')
        """
        let expected = """
        Unable to load contents of file list: '/Target Support Files/SnapKit-framework/SnapKit-framework-xcframeworks-input-files.xcfilelist' (in target 'SnapKit-framework' from project 'Pods')
        """.red

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output[0].text, expected)
        XCTAssertEqual(output[0].type, .error)
    }

    func test_formatBuildInputFileCannotBeFoundError_colored() throws {
        let sut = makeSut(colored: true)
        let input = """
        error: Build input file cannot be found: '/Users/swiftyfinch/Developer/Git/Rugby/Example/.rugby/build/Debug-iphonesimulator/SnapKit/SnapKit.framework/SnapKit'. Did you forget to declare this file as an output of a script phase or custom build rule which produces it? (in target 'SnapKit' from project 'Pods')
        """
        let expected = """
        Build input file cannot be found: '.rugby/build/Debug-iphonesimulator/SnapKit/SnapKit.framework/SnapKit'. Did you forget to declare this file as an output of a script phase or custom build rule which produces it? (in target 'SnapKit' from project 'Pods')
        """.red

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output[0].text, expected)
        XCTAssertEqual(output[0].type, .error)
    }
}

// MARK: - Tests

extension BuildLogFormatterTests {
    func test_tests() throws {
        let sut = makeSut(colored: false)
        let input = """
        Testing started
        Test Suite 'All tests' started at 2024-02-25 23:06:26.677.
        Test Suite 'LocalPod-framework-Unit-Tests.xctest' started at 2024-02-25 23:06:26.677.
        Test Suite 'ResourcesBundleTests' started at 2024-02-25 23:06:26.677.
        Test Case '-[LocalPod_framework_Unit_Tests.ResourcesBundleTests testAccessToResourcesBundle]' started.
        Test Case '-[LocalPod_framework_Unit_Tests.ResourcesBundleTests testAccessToResourcesBundle]' passed (0.002 seconds).
        Test Case '-[LocalPod_framework_Unit_Tests.ResourcesBundleTests testAccessToTestResourcesBundle]' started.
        Test Case '-[LocalPod_framework_Unit_Tests.ResourcesBundleTests testAccessToTestResourcesBundle]' passed (0.001 seconds).
        Test Suite 'ResourcesBundleTests' passed at 2024-02-25 23:06:26.681.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.004) seconds
        Test Suite 'LocalPod-framework-Unit-Tests.xctest' passed at 2024-02-25 23:06:26.681.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.004) seconds
        Test Suite 'All tests' passed at 2024-02-25 23:06:26.681.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.005) seconds
        Test Suite 'All tests' started at 2024-02-25 23:06:28.041.
        Test Suite 'LocalPod-framework-Unit-ResourceBundleTests.xctest' started at 2024-02-25 23:06:28.042.
        Test Suite 'ResourceBundleTests' started at 2024-02-25 23:06:28.042.
        Test Case '-[LocalPod_framework_Unit_ResourceBundleTests.ResourceBundleTests testAccessToResourcesBundle]' started.
        Test Case '-[LocalPod_framework_Unit_ResourceBundleTests.ResourceBundleTests testAccessToResourcesBundle]' passed (0.002 seconds).
        Test Case '-[LocalPod_framework_Unit_ResourceBundleTests.ResourceBundleTests testAccessToTestResourcesBundle]' started.
        Test Case '-[LocalPod_framework_Unit_ResourceBundleTests.ResourceBundleTests testAccessToTestResourcesBundle]' passed (0.001 seconds).
        Test Suite 'ResourceBundleTests' passed at 2024-02-25 23:06:28.045.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.003) seconds
        Test Suite 'LocalPod-framework-Unit-ResourceBundleTests.xctest' passed at 2024-02-25 23:06:28.045.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.003) seconds
        Test Suite 'All tests' passed at 2024-02-25 23:06:28.045.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.004) seconds

        Test session results, code coverage, and logs:
            /Users/swiftyfinch/Library/Developer/Xcode/DerivedData/Pods-guuswvdxibpkovaskeldlnpbgyfo/Logs/Test/Test-RugbyPods-2024.02.25_23-05-40-+0500.xcresult
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 8)
        let outputText = output.map(\.text).joined(separator: "\n")
        XCTAssertEqual(
            outputText,
            """
            ⚑ LocalPod-framework-Unit-Tests
              ResourcesBundleTests:
              ✓ testAccessToResourcesBundle (0.002 seconds)
              ✓ testAccessToTestResourcesBundle (0.001 seconds)
            ⚑ LocalPod-framework-Unit-ResourceBundleTests
              ResourceBundleTests:
              ✓ testAccessToResourcesBundle (0.002 seconds)
              ✓ testAccessToTestResourcesBundle (0.001 seconds)
            """
        )

        XCTAssertEqual(output[0].type, .test)
        XCTAssertEqual(output[1].type, .test)
        XCTAssertEqual(output[2].type, .testCase)
        XCTAssertEqual(output[3].type, .testCase)
        XCTAssertEqual(output[4].type, .test)
        XCTAssertEqual(output[5].type, .test)
        XCTAssertEqual(output[6].type, .testCase)
        XCTAssertEqual(output[7].type, .testCase)
    }

    func test_tests_colored() throws {
        let sut = makeSut(colored: true)
        let input = """
        Testing started
        Test Suite 'All tests' started at 2024-02-25 23:06:26.677.
        Test Suite 'LocalPod-framework-Unit-Tests.xctest' started at 2024-02-25 23:06:26.677.
        Test Suite 'ResourcesBundleTests' started at 2024-02-25 23:06:26.677.
        Test Case '-[LocalPod_framework_Unit_Tests.ResourcesBundleTests testAccessToResourcesBundle]' started.
        Test Case '-[LocalPod_framework_Unit_Tests.ResourcesBundleTests testAccessToResourcesBundle]' passed (0.002 seconds).
        Test Case '-[LocalPod_framework_Unit_Tests.ResourcesBundleTests testAccessToTestResourcesBundle]' started.
        Test Case '-[LocalPod_framework_Unit_Tests.ResourcesBundleTests testAccessToTestResourcesBundle]' passed (0.001 seconds).
        Test Suite 'ResourcesBundleTests' passed at 2024-02-25 23:06:26.681.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.004) seconds
        Test Suite 'LocalPod-framework-Unit-Tests.xctest' passed at 2024-02-25 23:06:26.681.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.004) seconds
        Test Suite 'All tests' passed at 2024-02-25 23:06:26.681.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.005) seconds
        Test Suite 'All tests' started at 2024-02-25 23:06:28.041.
        Test Suite 'LocalPod-framework-Unit-ResourceBundleTests.xctest' started at 2024-02-25 23:06:28.042.
        Test Suite 'ResourceBundleTests' started at 2024-02-25 23:06:28.042.
        Test Case '-[LocalPod_framework_Unit_ResourceBundleTests.ResourceBundleTests testAccessToResourcesBundle]' started.
        Test Case '-[LocalPod_framework_Unit_ResourceBundleTests.ResourceBundleTests testAccessToResourcesBundle]' passed (0.002 seconds).
        Test Case '-[LocalPod_framework_Unit_ResourceBundleTests.ResourceBundleTests testAccessToTestResourcesBundle]' started.
        Test Case '-[LocalPod_framework_Unit_ResourceBundleTests.ResourceBundleTests testAccessToTestResourcesBundle]' passed (0.001 seconds).
        Test Suite 'ResourceBundleTests' passed at 2024-02-25 23:06:28.045.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.003) seconds
        Test Suite 'LocalPod-framework-Unit-ResourceBundleTests.xctest' passed at 2024-02-25 23:06:28.045.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.003) seconds
        Test Suite 'All tests' passed at 2024-02-25 23:06:28.045.
             Executed 2 tests, with 0 failures (0 unexpected) in 0.003 (0.004) seconds

        Test session results, code coverage, and logs:
            /Users/swiftyfinch/Library/Developer/Xcode/DerivedData/Pods-guuswvdxibpkovaskeldlnpbgyfo/Logs/Test/Test-RugbyPods-2024.02.25_23-05-40-+0500.xcresult
        """

        // Act
        let output = try act(sut: sut, input: input)

        // Assert
        XCTAssertEqual(output.count, 8)
        XCTAssertEqual(output[0].text, "\("⚑".yellow) \("LocalPod-framework-Unit-Tests".green)")
        XCTAssertEqual(output[0].type, .test)
        XCTAssertEqual(output[1].text, "  ResourcesBundleTests:".green)
        XCTAssertEqual(output[1].type, .test)
        XCTAssertEqual(output[2].text, "  \("✓".green)\(" testAccessToResourcesBundle (0.002 seconds)".applyingStyle(.default))")
        XCTAssertEqual(output[2].type, .testCase)
        XCTAssertEqual(output[3].text, "  \("✓".green)\(" testAccessToTestResourcesBundle (0.001 seconds)".applyingStyle(.default))")
        XCTAssertEqual(output[3].type, .testCase)
        XCTAssertEqual(output[4].text, "\("⚑".yellow) \("LocalPod-framework-Unit-ResourceBundleTests".green)")
        XCTAssertEqual(output[4].type, .test)
        XCTAssertEqual(output[5].text, "  ResourceBundleTests:".green)
        XCTAssertEqual(output[5].type, .test)
        XCTAssertEqual(output[6].text, "  \("✓".green)\(" testAccessToResourcesBundle (0.002 seconds)".applyingStyle(.default))")
        XCTAssertEqual(output[6].type, .testCase)
        XCTAssertEqual(output[7].text, "  \("✓".green)\(" testAccessToTestResourcesBundle (0.001 seconds)".applyingStyle(.default))")
        XCTAssertEqual(output[7].type, .testCase)
    }
}

// swiftlint:enable line_length
// swiftlint:enable file_length
