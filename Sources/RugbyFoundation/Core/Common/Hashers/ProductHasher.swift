// MARK: - Interface

protocol IProductHasher: AnyObject {
    func hashContext(_ product: Product) -> [String: String?]
}

// MARK: - Implementation

final class ProductHasher {}

extension ProductHasher: IProductHasher {
    func hashContext(_ product: Product) -> [String: String?] {
        ["name": product.name,
         "type": product.type.rawValue,
         "parentFolderName": product.parentFolderName]
    }
}
