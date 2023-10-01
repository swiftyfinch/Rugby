final class ProductHasher {
    private let foundationHasher: FoundationHasher

    init(foundationHasher: FoundationHasher) {
        self.foundationHasher = foundationHasher
    }

    func hashContext(_ product: Product) -> [String: String?] {
        ["name": product.name,
         "type": product.type.rawValue,
         "parentFolderName": product.parentFolderName]
    }
}
