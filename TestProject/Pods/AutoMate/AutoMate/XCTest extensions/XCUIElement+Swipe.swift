//
//  XCUIElement+Swipe.swift
//  AutoMate
//
//  Created by Bartosz Janda on 06.04.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

// swiftlint:disable file_length

import Foundation
import XCTest

extension XCUIElement {

    // MARK: Properties
    /// Default number of swipes.
    public class var defaultSwipesCount: Int { return 15 }

    // MARK: Methods
    #if os(iOS)
    /// Perform swipe gesture on this view by swiping between provided points.
    ///
    /// It is an alternative to `swipeUp`, `swipeDown`, `swipeLeft` and `swipeBottom` methods provided by `XCTest`.
    /// It lets you specify coordinates on the screen (relative to the view on which the method is called).
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let scroll = app.scrollViews.element
    /// scroll.swipe(from: CGVector(dx: 0, dy: 0), to: CGVector(dx: 1, dy: 1))
    /// ```
    ///
    /// - Parameters:
    ///   - startVector: Relative point from which to start swipe.
    ///   - stopVector: Relative point to end swipe.
    public func swipe(from startVector: CGVector, to stopVector: CGVector) {
        let pt1 = coordinate(withNormalizedOffset: startVector)
        let pt2 = coordinate(withNormalizedOffset: stopVector)
        pt1.press(forDuration: 0.05, thenDragTo: pt2)
    }
    #endif

    #if os(iOS)
    /// Swipes scroll view to reveal given element.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let scroll = app.scrollViews.element
    /// let button = scroll.buttons.element
    /// scroll.swipe(to: button)
    /// ```
    ///
    /// - note:
    ///   `XCTest` automatically does the scrolling during `tap()`, but the method is still useful in some situations, for example to reveal element from behind keyboard, navigation bar or user defined element.
    /// - note:
    ///   This method assumes that element is scrollable and at least partially visible on the screen.
    ///
    /// - Parameters:
    ///   - element: Element to scroll to.
    ///   - avoid: Table of `AvoidableElement` that should be avoid while swiping, by default keyboard and navigation bar are passed.
    ///   - app: Application instance to use when searching for keyboard to avoid.
    ///   - orientation: Device orientation.
    public func swipe(to element: XCUIElement, avoid viewsToAvoid: [AvoidableElement] = [.keyboard, .navigationBar], from app: XCUIApplication = XCUIApplication(), orientation: UIDeviceOrientation = XCUIDevice.shared.orientation) {
        let scrollableArea = self.scrollableArea(avoid: viewsToAvoid, from: app, orientation: orientation)

        // Distance from scrollable area center to element center.
        func distanceVector() -> CGVector {
            return scrollableArea.center.vector(to: element.frame.center)
        }

        // Scroll until center of the element will be visible.
        var oldDistance = distanceVector().manhattanDistance
        while !scrollableArea.contains(element.frame.center) {

            // Max swipe offset in both directions.
            let maxOffset = maxSwipeOffset(in: scrollableArea)

            // Max possible distance to swipe (in points).
            // It cannot be bigger than `maxOffset`.
            let vector = distanceVector()
            let maxVector = CGVector(
                dx: max(min(vector.dx, maxOffset.width), -maxOffset.width),
                dy: max(min(vector.dy, maxOffset.height), -maxOffset.height)
            )

            // Max possible distance to swipe (normalized).
            let maxNormalizedVector = normalize(vector: maxVector)

            // Center point.
            let center = centerPoint(in: scrollableArea)

            // Start and stop vectors.
            let (startVector, stopVector) = swipeVectors(from: center, vector: maxNormalizedVector)

            // Swipe.
            swipe(from: startVector, to: stopVector)

            // Stop scrolling if distance to element was not changed.
            let newDistance = distanceVector().manhattanDistance
            guard oldDistance > newDistance else {
                break
            }
            oldDistance = newDistance
        }
    }
    #endif

    #if os(iOS)
    /// Swipes scroll view to given direction until condition will be satisfied.
    ///
    /// A useful method to scroll collection view to reveal an element.
    /// In collection view, only a few cells are available in the hierarchy.
    /// To scroll to given element you have to provide swipe direction.
    /// It is not possible to detect when the end of the scroll was reached, that is why the maximum number of swipes is required (by default 10).
    /// The method will stop when the maximum number of swipes is reached or when the condition will be satisfied.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let collectionView = app.collectionViews.element
    /// let element = collectionView.staticTexts["More"]
    /// collectionView.swipe(to: .down, until: element.exists)
    /// ```
    ///
    /// - Parameters:
    ///   - direction: Swipe direction.
    ///   - times: Maximum number of swipes (by default 10).
    ///   - viewsToAvoid: Table of `AvoidableElement` that should be avoid while swiping, by default keyboard and navigation bar are passed.
    ///   - app: Application instance to use when searching for keyboard to avoid.
    ///   - orientation: Device orientation.
    ///   - condition: The condition to satisfy.
    public func swipe(to direction: SwipeDirection,
                      times: Int = XCUIElement.defaultSwipesCount,
                      avoid viewsToAvoid: [AvoidableElement] = [.keyboard, .navigationBar],
                      from app: XCUIApplication = XCUIApplication(),
                      orientation: UIDeviceOrientation = XCUIDevice.shared.orientation,
                      until condition: @autoclosure () -> Bool) {
        let scrollableArea = self.scrollableArea(avoid: viewsToAvoid, from: app, orientation: orientation)

        // Swipe `times` times in the provided direction.
        for _ in 0..<times {

            // Stop scrolling when condition will be satisfied.
            guard !condition() else {
                break
            }

            // Max swipe offset in both directions.
            let maxOffset = maxSwipeOffset(in: scrollableArea)

            /// Calculates vector for given direction.
            let vector: CGVector
            switch direction {
            case .up: vector = CGVector(dx: 0, dy: -maxOffset.height)
            case .down: vector = CGVector(dx: 0, dy: maxOffset.height)
            case .left: vector = CGVector(dx: -maxOffset.width, dy: 0)
            case .right: vector = CGVector(dx: maxOffset.width, dy: 0)
            }

            // Max possible distance to swipe (normalized).
            let maxNormalizedVector = normalize(vector: vector)

            // Center point.
            let center = centerPoint(in: scrollableArea)

            // Start and stop vectors.
            let (startVector, stopVector) = swipeVectors(from: center, vector: maxNormalizedVector)

            // Swipe.
            swipe(from: startVector, to: stopVector)
        }
    }
    #endif

    #if os(iOS)
    /// Swipes scroll view to given direction until element would exist.
    ///
    /// A useful method to scroll collection view to reveal an element.
    /// In collection view, only a few cells are available in the hierarchy.
    /// To scroll to given element you have to provide swipe direction.
    /// It is not possible to detect when the end of the scroll was reached, that is why the maximum number of swipes is required (by default 10).
    /// The method will stop when the maximum number of swipes is reached or when the given element will appear in the view hierarchy.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let collectionView = app.collectionViews.element
    /// let element = collectionView.staticTexts["More"]
    /// collectionView.swipe(to: .down, untilExist: element)
    /// ```
    ///
    /// - note:
    ///   This method will not scroll until the view will be visible. To do this call `swipe(to:untilVisible:times:avoid:app:)` after this method.
    ///
    /// - Parameters:
    ///   - direction: Swipe direction.
    ///   - element: Element to swipe to.
    ///   - times: Maximum number of swipes (by default 10).
    ///   - viewsToAvoid: Table of `AvoidableElement` that should be avoid while swiping, by default keyboard and navigation bar are passed.
    ///   - app: Application instance to use when searching for keyboard to avoid.
    public func swipe(to direction: SwipeDirection, untilExist element: XCUIElement, times: Int = XCUIElement.defaultSwipesCount, avoid viewsToAvoid: [AvoidableElement] = [.keyboard, .navigationBar], from app: XCUIApplication = XCUIApplication()) {

        swipe(to: direction, times: times, avoid: viewsToAvoid, from: app, until: element.exists)
    }
    #endif

    #if os(iOS)
    /// Swipes scroll view to given direction until element would be visible.
    ///
    /// A useful method to scroll collection view to reveal an element.
    /// In collection view, only a few cells are available in the hierarchy.
    /// To scroll to given element you have to provide swipe direction.
    /// It is not possible to detect when the end of the scroll was reached, that is why the maximum number of swipes is required (by default 10).
    /// The method will stop when the maximum number of swipes is reached or when the given element will be visible.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let collectionView = app.collectionViews.element
    /// let element = collectionView.staticTexts["More"]
    /// collectionView.swipe(to: .down, untilVisible: element)
    /// ```
    ///
    /// - note:
    ///   This method will not scroll until the view will be visible. To do this call `swipe(to:avoid:from:)` after this method.
    ///
    /// - Parameters:
    ///   - direction: Swipe direction.
    ///   - element: Element to swipe to.
    ///   - times: Maximum number of swipes (by default 10).
    ///   - viewsToAvoid: Table of `AvoidableElement` that should be avoid while swiping, by default keyboard and navigation bar are passed.
    ///   - app: Application instance to use when searching for keyboard to avoid.
    public func swipe(to direction: SwipeDirection, untilVisible element: XCUIElement, times: Int = XCUIElement.defaultSwipesCount, avoid viewsToAvoid: [AvoidableElement] = [.keyboard, .navigationBar], from app: XCUIApplication = XCUIApplication()) {

        swipe(to: direction, times: times, avoid: viewsToAvoid, from: app, until: element.isVisible)
    }
    #endif
}

// MARK: - Internal
#if os(iOS)
extension XCUIElement {
    // MARK: Properties
    /// Proportional horizontal swipe length.
    ///
    /// - note:
    /// To avoid swipe to back `swipeLengthX` is lower than `swipeLengthY`.
    var swipeLengthX: CGFloat {
        return 0.7
    }

    /// Proportional vertical swipe length.
    var swipeLengthY: CGFloat {
        return 0.7
    }

    // MARK: Methods
    /// Calculates scrollable area of the element by removing overlapping elements like keybard or navigation bar.
    ///
    /// - Parameters:
    ///   - viewsToAvoid: Table of `AvoidableElement` that should be avoid while swiping, by default keyboard and navigation bar are passed.
    ///   - app: Application instance to use when searching for keyboard to avoid.
    ///   - orientation: Device orientation.
    /// - Returns: Scrollable area of the element.
    func scrollableArea(avoid viewsToAvoid: [AvoidableElement] = [.keyboard, .navigationBar], from app: XCUIApplication = XCUIApplication(), orientation: UIDeviceOrientation) -> CGRect {

        let scrollableArea = viewsToAvoid.reduce(frame) {
            $1.overlapReminder(of: $0, in: app, orientation: orientation)
        }
//        assert(scrollableArea.height > 0, "Scrollable view is completely hidden.")
        return scrollableArea
    }

    /// Maximum available swipe offsets (in points) in the scrollable area.
    ///
    /// It takes `swipeLengthX` and `swipeLengthY` to calculate values.
    ///
    /// - Parameter scrollableArea: Scrollable area of the element.
    /// - Returns: Maximum available swipe offsets (in points).
    func maxSwipeOffset(in scrollableArea: CGRect) -> CGSize {
        return CGSize(
            width: scrollableArea.width * swipeLengthX,
            height: scrollableArea.height * swipeLengthY
        )
    }

    /// Normalize vector. From points to normalized values (<0;1>).
    ///
    /// - Parameter vector: Vector to normalize.
    /// - Returns: Normalized vector.
    func normalize(vector: CGVector) -> CGVector {
        return CGVector(
            dx: vector.dx / frame.width,
            dy: vector.dy / frame.height
        )
    }

    /// Returns center point of the scrollable area in the element in the normalized coordinate space.
    ///
    /// - Parameter scrollableArea: Scrollable area of the element.
    /// - Returns: Center point of the scrollable area in the element in the normalized coordinate space.
    func centerPoint(in scrollableArea: CGRect) -> CGPoint {
        return CGPoint(
            x: (scrollableArea.midX - frame.minX) / frame.width,
            y: (scrollableArea.midY - frame.minY) / frame.height
        )
    }

    /// Calculates swipe vectors from center point and swipe vector.
    ///
    /// Generated vectors can be used by `swipe(from:,to:)`.
    ///
    /// - Parameters:
    ///   - center: Center point of the scrollable area. Use `centerPoint(with:)` to calculate this value.
    ///   - vector: Swipe vector in the normalized coordinate space.
    /// - Returns: Swipes vector to use by `swipe(from:,to:)`.
    func swipeVectors(from center: CGPoint, vector: CGVector) -> (startVector: CGVector, stopVector: CGVector) {
        // Start vector.
        let startVector = CGVector(
            dx: center.x + vector.dx / 2,
            dy: center.y + vector.dy / 2
        )

        // Stop vector.
        let stopVector = CGVector(
            dx: center.x - vector.dx / 2,
            dy: center.y - vector.dy / 2
        )

        return (startVector, stopVector)
    }

    /// Calculates frame for given orientation.
    /// Due an open [issue](https://openradar.appspot.com/31529903). Coordinates works correctly only in portrait orientation.
    ///
    /// - Parameters:
    ///   - orientation: Device 
    ///   - app: Application instance to use when searching for keyboard to avoid.
    /// - Returns: Calculated frame for given orientation.
    func frame(for orientation: UIDeviceOrientation, in app: XCUIApplication) -> CGRect {

        // Supports only landscape left, landscape right and upside down.
        // For all other unsupported orientations the default frame returned.
        guard orientation == .landscapeLeft
            || orientation == .landscapeRight
            || orientation == .portraitUpsideDown else {
                return frame
        }

        switch orientation {
        case .landscapeLeft:
            return CGRect(x: frame.minY, y: app.frame.width - frame.maxX, width: frame.height, height: frame.width)
        case .landscapeRight:
            return CGRect(x: app.frame.height - frame.maxY, y: frame.minX, width: frame.height, height: frame.width)
        case .portraitUpsideDown:
            return CGRect(x: app.frame.width - frame.maxX, y: app.frame.height - frame.maxY, width: frame.width, height: frame.height)
        default:
            preconditionFailure("Not supported orientation")
        }
    }
}
#endif

// MARK: - AvoidableElement
#if os(iOS)
/// Each case relates to element of user interface that can overlap scrollable area.
///
/// - `navigationBar`: equivalent of `UINavigationBar`.
/// - `keyboard`: equivalent of `UIKeyboard`.
/// - `other(XCUIElement, CGRectEdge)`: equivalent of user defined `XCUIElement` with `CGRectEdge` on which it appears.
/// If more than one navigation bar or any other predefined `AvoidableElement` is expected, use `.other` case.
/// Predefined cases assume there is only one element of their type.
public enum AvoidableElement {
    /// Equivalent of `UINavigationBar`.
    case navigationBar
    /// Equivalent of `UIKeyboard`.
    case keyboard
    /// Equivalent of user defined `XCUIElement` with `CGRectEdge` on which it appears.
    case other(element: XCUIElement, edge: CGRectEdge)

    /// Edge on which `XCUIElement` appears.
    var edge: CGRectEdge {
        switch self {
        case .navigationBar: return .minYEdge
        case .keyboard: return .maxYEdge
        case .other(_, let edge): return edge
        }
    }

    /// Finds `XCUIElement` depending on case.
    ///
    /// - Parameter app: XCUIAppliaction to search through, `XCUIApplication()` by default.
    /// - Returns: `XCUIElement` equivalent of enum case.
    func element(in app: XCUIApplication = XCUIApplication()) -> XCUIElement {
        switch self {
        case .navigationBar: return app.navigationBars.element
        case .keyboard: return app.keyboards.element
        case .other(let element, _): return element
        }
    }

    /// Calculates rect that reminds scrollable through substract overlaping part of `XCUIElement`.
    ///
    /// - Parameters:
    ///   - rect: CGRect that is overlapped.
    ///   - app: XCUIApplication in which overlapping element can be found.
    /// - Returns: Part of rect not overlapped by element.
    func overlapReminder(of rect: CGRect, in app: XCUIApplication, orientation: UIDeviceOrientation) -> CGRect {

        let overlappingElement = element(in: app)
        guard overlappingElement.exists else { return rect }

        let overlappingElementFrame: CGRect
        if case .keyboard = self {
            overlappingElementFrame = overlappingElement.frame(for: orientation, in: app)
        } else {
            overlappingElementFrame = overlappingElement.frame
        }
        let overlap: CGFloat

        switch edge {
        case .maxYEdge:
            overlap = rect.maxY - overlappingElementFrame.minY
        case .minYEdge:
            overlap = overlappingElementFrame.maxY - rect.minY
        default:
            return rect
        }

        return rect.divided(atDistance: max(overlap, 0),
                            from: edge).remainder
    }
}
#endif

// MARK: - SwipeDirection
/// Swipe direction.
///
/// - `up`: Swipe up.
/// - `down`: Swipe down.
/// - `left`: Swipe to the left.
/// - `right`: Swipe to the right.
public enum SwipeDirection {
    /// Swipe up.
    case up // swiftlint:disable:this identifier_name
    /// Swipe down.
    case down
    /// Swipe to the left.
    case left
    /// Swipe to the right.
    case right
}
