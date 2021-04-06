//
//  PBXProj+RemoveFrameworkPaths.swift
//  
//
//  Created by Vyacheslav Khorkov on 06.04.2021.
//

import XcodeProj

extension XcodeProj {
    @discardableResult
    func removeFrameworkPaths(frameworksGroups: Set<String> = ["Frameworks", "Products"],
                              products: Set<String>) -> Bool {
        var hasChanges = false
        let frameworks = pbxproj.groups.filter {
            ($0.name.map(frameworksGroups.contains) ?? false) && $0.parent?.parent == nil
        }
        frameworks.forEach {
            $0.children.forEach { child in
                if let name = child.name, products.contains(name) {
                    pbxproj.delete(object: child)
                    (child.parent as? PBXGroup)?.children.removeAll(where: { child.uuid == $0.uuid })
                    hasChanges = true
                } else if let path = child.path, products.contains(path) {
                    pbxproj.delete(object: child)
                    (child.parent as? PBXGroup)?.children.removeAll(where: { child.uuid == $0.uuid })
                    hasChanges = true
                }
            }
        }
        return hasChanges
    }
}
