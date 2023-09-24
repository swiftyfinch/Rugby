//
//  ProductHasher.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 03.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

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
