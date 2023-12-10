import Rainbow
@testable import RugbyFoundation
import XCTest

final class TargetTreePainterTests: XCTestCase {
    private var sut: ITargetTreePainter!

    override func setUp() {
        super.setUp()
        Rainbow.enabled = false
        sut = TargetTreePainter()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

extension TargetTreePainterTests {
    func test_paint() {
        let keyboardLayoutGuide = IInternalTargetMock()
        keyboardLayoutGuide.underlyingName = "Keyboard+LayoutGuide"
        keyboardLayoutGuide.underlyingUuid = "test_keyboardLayoutGuide"
        keyboardLayoutGuide.hash = "9fa8c7b"
        let kingfisher = IInternalTargetMock()
        kingfisher.underlyingName = "Kingfisher"
        kingfisher.underlyingUuid = "test_kingfisher"
        kingfisher.hash = "577879d"
        let localPodResources = IInternalTargetMock()
        localPodResources.underlyingName = "LocalPod-LocalPodResources"
        localPodResources.underlyingUuid = "test_localPodResources"
        localPodResources.hash = "9feb7bf"
        let alamofire = IInternalTargetMock()
        alamofire.underlyingName = "Alamofire"
        alamofire.underlyingUuid = "test_alamofire"
        alamofire.hash = "af22339"
        let moya = IInternalTargetMock()
        moya.underlyingName = "Moya"
        moya.underlyingUuid = "test_moya"
        moya.hash = "fa6acbb"
        moya.explicitDependencies = [alamofire.uuid: alamofire]
        let snapKit = IInternalTargetMock()
        snapKit.underlyingName = "SnapKit"
        snapKit.underlyingUuid = "test_snapKit"
        snapKit.hash = "f6aa8a7"
        let localPod = IInternalTargetMock()
        localPod.underlyingName = "LocalPod"
        localPod.underlyingUuid = "test_localPod"
        localPod.hash = "0dd242a"
        localPod.explicitDependencies = [
            moya.uuid: moya,
            localPodResources.uuid: localPodResources
        ]
        let targets: TargetsMap = [
            keyboardLayoutGuide.uuid: keyboardLayoutGuide,
            kingfisher.uuid: kingfisher,
            localPodResources.uuid: localPodResources,
            alamofire.uuid: alamofire,
            moya.uuid: moya,
            snapKit.uuid: snapKit,
            localPod.uuid: localPod
        ]

        // Act
        let output = sut.paint(targets: targets)

        // Assert
        XCTAssertEqual(
            output,
            """
            ┣━ Keyboard+LayoutGuide (9fa8c7b)
            ┣━ Kingfisher (577879d)
            ┣━ LocalPod (0dd242a)
            ┃  ┣━ LocalPod-LocalPodResources (9feb7bf)
            ┃  ┗━ Moya (fa6acbb)
            ┃     ┗━ Alamofire (af22339)
            ┗━ SnapKit (f6aa8a7)
            """
        )
    }
}
