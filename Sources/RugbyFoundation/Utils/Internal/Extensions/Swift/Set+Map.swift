//
//  Set+Map.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 28.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

extension Set {
    func map<ElementOfResult>(
        _ transform: (Element) throws -> ElementOfResult
    ) rethrows -> Set<ElementOfResult> {
        try reduce(into: []) { collection, element in
            let transformed = try transform(element)
            collection.insert(transformed)
        }
    }

    func compactMap<ElementOfResult>(
        _ transform: (Element) throws -> ElementOfResult?
    ) rethrows -> Set<ElementOfResult> {
        try reduce(into: []) { collection, element in
            guard let transformed = try transform(element) else { return }
            collection.insert(transformed)
        }
    }

    func flatMap<SegmentOfResult>(
        _ transform: (Element) throws -> SegmentOfResult
    ) rethrows -> Set<SegmentOfResult.Element> where SegmentOfResult: Sequence {
        try reduce(into: []) { collection, element in
            try collection.formUnion(transform(element))
        }
    }

    func partition(
        _ isLeftSide: (Element) throws -> Bool
    ) rethrows -> (Set<Element>, Set<Element>) {
        let matched = try filter(isLeftSide)
        return (matched, subtracting(matched))
    }
}
