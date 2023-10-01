import XcodeProj

final class Product {
    let name: String
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

    init(name: String, type: PBXProductType, parentFolderName: String?) {
        self.name = name
        self.type = type
        self.parentFolderName = parentFolderName
    }
}

// MARK: - Hashable

extension Product: Hashable {
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.nameWithParent == rhs.nameWithParent
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nameWithParent)
    }
}
