//
//  CoreGraphics.swift
//  AutoMate
//
//  Created by Bartosz Janda on 05.04.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import CoreGraphics

extension CGRect {

    /// Returns center point of the rectangle.
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

extension CGPoint {

    /// Returns vector between two points.
    ///
    /// - Parameter point: Destination point.
    /// - Returns: Vectory between `self` and `point`.
    func vector(to point: CGPoint) -> CGVector {
        return CGVector(dx: point.x - x, dy: point.y - y)
    }
}

extension CGVector {
    /// Returns Manhattan distance.
    var manhattanDistance: CGFloat {
        return abs(dx) + abs(dy)
    }
}
