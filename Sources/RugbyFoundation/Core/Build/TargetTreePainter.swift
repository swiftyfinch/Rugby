// MARK: - Interface

protocol ITargetTreePainter {
    func paint(targets: [String: Target]) -> String
}

// MARK: - Implementation

final class TargetTreePainter {
    private let inMiddle = "┣━"
    private let leaf = "┗━"
    private let pipe = "┃"
}

private extension TargetTreePainter {
    final class Tree {
        let name: String
        let isRoot: Bool
        let isCollapsed: Bool
        let info: String?
        let subtrees: [Tree]

        init(name: String, isRoot: Bool = false, info: String?, isCollapsed: Bool, subtrees: [Tree] = []) {
            self.name = name
            self.isRoot = isRoot
            self.info = info
            self.isCollapsed = isCollapsed
            self.subtrees = subtrees
        }
    }

    func depthOfTree(root: Target, allowed: [String: Target]) -> Int {
        var foundTreeDepths: [Target: Int] = [:]
        return depthOfTree(root: root, allowed: allowed, foundTreeDepths: &foundTreeDepths, depth: 0)
    }

    private func buildTree(targets: [String: Target]) -> Tree {
        var seen: Set<String> = []
        return buildTree(name: "root", isRoot: true, targets: targets.values, seen: &seen, allowed: targets)
    }

    private func renderTree(_ tree: Tree) -> String {
        var output = ""
        renderTree(tree, output: &output, depth: 0, last: false, prefix: "")
        return output
    }
}

private extension TargetTreePainter {
    func depthOfTree(root: Target,
                     allowed: [String: Target],
                     foundTreeDepths: inout [Target: Int],
                     depth: Int) -> Int {
        var maxDepth = depth
        for dependency in root.explicitDependencies.values {
            guard allowed.contains(dependency.uuid) else { continue }
            if let foundDepth = foundTreeDepths[dependency] {
                maxDepth = max(maxDepth, depth + foundDepth)
                continue
            }
            let treeDepth = depthOfTree(
                root: dependency,
                allowed: allowed,
                foundTreeDepths: &foundTreeDepths,
                depth: depth + 1
            )
            foundTreeDepths[dependency] = treeDepth
            maxDepth = max(maxDepth, treeDepth)
        }
        return maxDepth
    }

    func buildTree(name: String,
                   isRoot: Bool = false,
                   isCollapsed: Bool = false,
                   info: String? = nil,
                   targets: some Sequence<Target>,
                   seen: inout Set<String>,
                   allowed: [String: Target]) -> Tree {
        Tree(
            name: name,
            isRoot: isRoot,
            info: info,
            isCollapsed: isCollapsed,
            subtrees: targets
                .map { target in
                    (target: target, maxDepth: depthOfTree(root: target, allowed: allowed))
                }
                .sorted { $0.maxDepth > $1.maxDepth }
                .map(\.target)
                .reduce(into: []) { subtrees, target in
                    guard allowed.contains(target.uuid) else { return }
                    if seen.insert(target.uuid).inserted {
                        subtrees.append(
                            buildTree(name: target.name,
                                      isCollapsed: false,
                                      info: target.hash,
                                      targets: target.explicitDependencies.values,
                                      seen: &seen,
                                      allowed: allowed)
                        )
                    } /* else if !isRoot { // It's generate too many lines
                         subtrees.append(
                             Tree(name: target.name, info: target.hash, isCollapsed: true)
                         )
                     }*/
                }
                .sorted(by: { $0.name < $1.name })
        )
    }

    func renderTree(_ tree: Tree,
                    output: inout String,
                    depth: Int,
                    last: Bool,
                    prefix: String) {
        if !tree.isRoot {
            if output.isNotEmpty { output.append("\n") }

            let arrow = last ? leaf : inMiddle
            output.append("\(prefix)\(arrow) ".yellow)

            let name = tree.isCollapsed ? "*\(tree.name)" : tree.name
            output.append(name.green)

            if let info = tree.info { output.append(" (\(info))".yellow) }
        }

        for (index, subtree) in tree.subtrees.enumerated() {
            renderTree(subtree,
                       output: &output,
                       depth: depth + 1,
                       last: index + 1 == tree.subtrees.count,
                       prefix: depth > 0 ? "\(prefix)\(last ? "   " : "\(pipe)  ")" : prefix)
        }
    }
}

// MARK: - ITargetTreePainter

extension TargetTreePainter: ITargetTreePainter {
    public func paint(targets: [String: Target]) -> String {
        let tree = buildTree(targets: targets)
        return renderTree(tree)
    }
}
