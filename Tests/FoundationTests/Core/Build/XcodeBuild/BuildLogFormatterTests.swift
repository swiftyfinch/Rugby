import Rainbow
@testable import RugbyFoundation
import XcbeautifyLib
import XCTest

// swiftlint:disable line_length
// swiftlint:disable function_body_length

final class BuildLogFormatterTests: XCTestCase {
    private var workingDirectory: IFolderMock!

    override func setUp() {
        super.setUp()
        workingDirectory = IFolderMock()
        workingDirectory.underlyingPath = "/Users/swiftyfinch/Developer/Git/Rugby/Example"
    }

    override func tearDown() {
        super.tearDown()
        workingDirectory = nil
    }

    private func makeSut(colored: Bool) -> IBuildLogFormatter {
        BuildLogFormatter(workingDirectory: workingDirectory, colored: colored)
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
        Rainbow.enabled = false
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
        Rainbow.enabled = false
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
        Rainbow.enabled = false
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
        Rainbow.enabled = false
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
        Rainbow.enabled = false
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
        Rainbow.enabled = false
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
        Rainbow.enabled = true
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
        Rainbow.enabled = true
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
        Rainbow.enabled = true
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
        Rainbow.enabled = true
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
        Rainbow.enabled = true
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
        Rainbow.enabled = true
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

// swiftlint:enable line_length
// swiftlint:enable function_body_length
