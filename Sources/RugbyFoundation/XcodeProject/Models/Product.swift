import XcodeProj

final class Product {
    let name: String
    let moduleName: String?
    let type: PBXProductType
    let parentFolderName: String?
    var context: [AnyHashable: Any] = [:]

    // MARK: - Computed Properties

    var fileName: String {
        let nameWithoutExtension: String
        switch type {
        case .staticLibrary:
            nameWithoutExtension = "lib\(name)"
        default:
            nameWithoutExtension = name
        }
        return type.fileExtension.map { "\(nameWithoutExtension).\($0)" } ?? nameWithoutExtension
    }

    var nameWithParent: String {
        parentFolderName.map { "\($0)/\(fileName)" } ?? fileName
    }

    init(name: String,
         moduleName: String?,
         type: PBXProductType,
         parentFolderName: String?) {
        self.name = name
        self.moduleName = moduleName
        self.type = type
        self.parentFolderName = parentFolderName
    }
}
