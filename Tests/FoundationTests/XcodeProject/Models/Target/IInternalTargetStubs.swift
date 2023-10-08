@testable import RugbyFoundation

extension Target {
    static var rugbyFramework: IInternalTargetMock {
        let target = IInternalTargetMock()
        target.name = "Rugby"
        target.uuid = "FAEEE7E885B9E4DB1C9624B817351F24"
        target.hashContext = "rugby_target_context"
        target.hash = "7108f75"
        target.product = .init(name: "Rugby", moduleName: "Rugby", type: .framework, parentFolderName: "Rugby")
        return target
    }

    static var fishBundle: IInternalTargetMock {
        let target = IInternalTargetMock()
        target.name = "Fish"
        target.uuid = "B1C9624B817351F24FAEEE7E885B9E4D"
        target.hashContext = "fish_bundle_context"
        target.hash = "f577d09"
        target.product = .init(name: "Fish", moduleName: "Fish", type: .bundle, parentFolderName: "Fish")
        return target
    }

    static var fishFramework: IInternalTargetMock {
        let target = IInternalTargetMock()
        target.name = "Fish"
        target.uuid = "817351F24FAEEE7B1C9624BE885B9E4D"
        target.hashContext = "fish_target_context"
        target.hash = "3c6ddd5"
        target.product = .init(name: "Fish", moduleName: "Fish", type: .framework, parentFolderName: "Fish")
        return target
    }

    static var keyboardLayoutGuideLib: IInternalTargetMock {
        let target = IInternalTargetMock()
        target.name = "Keyboard+LayoutGuide"
        target.uuid = "24B81731C96B9E51F24EE785AE4DBFE8"
        target.hashContext = "Keyboard+LayoutGuide_context"
        target.hash = "e4d65a6"
        target.product = .init(
            name: "Keyboard+LayoutGuide",
            moduleName: "KeyboardLayoutGuide",
            type: .staticLibrary,
            parentFolderName: "Keyboard+LayoutGuide"
        )
        return target
    }
}
