@testable import RugbyFoundation
import XCTest

final class TargetsHasherTests: XCTestCase {
    private var sut: ITargetsHasher!
    private var foundationHasher: FoundationHasherMock!
    private var swiftVersionProvider: ISwiftVersionProviderMock!
    private var buildPhaseHasher: IBuildPhaseHasherMock!
    private var cocoaPodsScriptsHasher: ICocoaPodsScriptsHasherMock!
    private var configurationsHasher: IConfigurationsHasherMock!
    private var productHasher: IProductHasherMock!
    private var buildRulesHasher: IBuildRulesHasherMock!

    override func setUp() {
        super.setUp()
        foundationHasher = FoundationHasherMock()
        swiftVersionProvider = ISwiftVersionProviderMock()
        buildPhaseHasher = IBuildPhaseHasherMock()
        cocoaPodsScriptsHasher = ICocoaPodsScriptsHasherMock()
        configurationsHasher = IConfigurationsHasherMock()
        productHasher = IProductHasherMock()
        buildRulesHasher = IBuildRulesHasherMock()
        sut = TargetsHasher(
            foundationHasher: foundationHasher,
            swiftVersionProvider: swiftVersionProvider,
            buildPhaseHasher: buildPhaseHasher,
            cocoaPodsScriptsHasher: cocoaPodsScriptsHasher,
            configurationsHasher: configurationsHasher,
            productHasher: productHasher,
            buildRulesHasher: buildRulesHasher
        )
    }

    override func tearDown() {
        super.tearDown()
        foundationHasher = nil
        swiftVersionProvider = nil
        buildPhaseHasher = nil
        cocoaPodsScriptsHasher = nil
        configurationsHasher = nil
        productHasher = nil
        buildRulesHasher = nil
        sut = nil
    }
}
