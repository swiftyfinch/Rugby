//
//  PBXTarget+RecursiveDependencies.swift
//  
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//

import XcodeProj

extension PBXTarget {
    func recursiveDependencies() -> [String: PBXTargetDependency] {
        var result: [String: PBXTargetDependency] = [:]
        for dependency in dependencies {
            guard let name = dependency.displayName else { continue }
            result[name] = dependency
            if let names = dependency.target?.recursiveDependencies() {
                result.merge(names, uniquingKeysWith: { lhs, _ in lhs })
            }
        }
        return result
    }
}
