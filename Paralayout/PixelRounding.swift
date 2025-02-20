//
//  Copyright © 2020 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

/// The ratio of pixels to points, either of a UIScreen, a UIView's screen, or an explicit value.
@MainActor
public protocol ScaleFactorProviding {

    var pixelsPerPoint: CGFloat { get }

}

extension UIScreen: ScaleFactorProviding {

    public var pixelsPerPoint: CGFloat {
        scale
    }

}

extension UIView: ScaleFactorProviding {

    public var pixelsPerPoint: CGFloat {
        let scaleFromTraits = traitCollection.displayScale

        // The trait collection is the authority for display scale, but sometimes the trait collection does not have a
        // value for the scale, in which case it will return 0, breaking all the things.
        if scaleFromTraits > 0 {
            return scaleFromTraits
        }

        #if os(iOS)
        return (window?.screen ?? UIScreen.main).pixelsPerPoint
        #endif
    }

}

// MARK: -

extension CGFloat {

    // MARK: - Public Methods

    /// Returns the coordinate value (in points) floored to the nearest pixel, e.g. 0.6 @2x -> 0.5, not 0.0.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    @MainActor
    public func flooredToPixel(in scaleFactor: ScaleFactorProviding) -> CGFloat {
        flooredToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the coordinate value (in points) floored to the nearest pixel, e.g. 0.6 @2x -> 0.5, not 0.0.
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func flooredToPixel(in scale: CGFloat) -> CGFloat {
        adjustedToPixel(scale) { floor($0) }
    }

    /// Returns the coordinate value (in points) ceiled to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 1.0.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    @MainActor
    public func ceiledToPixel(in scaleFactor: ScaleFactorProviding) -> CGFloat {
        ceiledToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the coordinate value (in points) ceiled to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 1.0.
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceiledToPixel(in scale: CGFloat) -> CGFloat {
        adjustedToPixel(scale) { ceil($0) }
    }

    /// Returns the coordinate value (in points) rounded to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 0.0.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    @MainActor
    public func roundedToPixel(in scaleFactor: ScaleFactorProviding) -> CGFloat {
        roundedToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the coordinate value (in points) rounded to the nearest pixel, e.g. 0.4 @2x -> 0.5, not 0.0.
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundedToPixel(in scale: CGFloat) -> CGFloat {
        // Invoke the namespaced Darwin.round() function since round() is ambiguous (it's also a mutating instance
        // method).
        adjustedToPixel(scale) { Darwin.round($0) }
    }

    // MARK: - Private Methods

    private func adjustedToPixel(_ scale: CGFloat, _ adjustment: (CGFloat) -> CGFloat) -> CGFloat {
        (scale > 0.0) ? (adjustment(self * scale) / scale) : self
    }
}

extension CGPoint {

    /// Returns the coordinate values (in points) floored to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not
    /// (0.0, 1.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    @MainActor
    public func flooredToPixel(in scaleFactor: ScaleFactorProviding) -> CGPoint {
        flooredToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the coordinate values (in points) floored to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not
    /// (0.0, 1.0).
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func flooredToPixel(in scale: CGFloat) -> CGPoint {
        CGPoint(x: x.flooredToPixel(in: scale), y: y.flooredToPixel(in: scale))
    }

    /// Returns the coordinate values (in points) ceiled to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not
    /// (1.0, 2.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    @MainActor
    public func ceiledToPixel(in scaleFactor: ScaleFactorProviding) -> CGPoint {
        ceiledToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the coordinate values (in points) ceiled to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not
    /// (1.0, 2.0).
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceiledToPixel(in scale: CGFloat) -> CGPoint {
        CGPoint(x: x.ceiledToPixel(in: scale), y: y.ceiledToPixel(in: scale))
    }

    /// Returns the coordinate values (in points) rounded to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not
    /// (0.0, 1.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    @MainActor
    public func roundedToPixel(in scaleFactor: ScaleFactorProviding) -> CGPoint {
        roundedToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the coordinate values (in points) rounded to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not
    /// (0.0, 1.0).
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundedToPixel(in scale: CGFloat) -> CGPoint {
        CGPoint(x: x.roundedToPixel(in: scale), y: y.roundedToPixel(in: scale))
    }
}

extension CGSize {

    /// Return the size (in points) floored to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not (0.0, 1.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    @MainActor
    public func flooredToPixel(in scaleFactor: ScaleFactorProviding) -> CGSize {
        flooredToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Return the size (in points) floored to the nearest pixel, e.g. (0.6, 1.1) @2x -> (0.5, 1.0), not (0.0, 1.0).
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func flooredToPixel(in scale: CGFloat) -> CGSize {
        CGSize(width: width.flooredToPixel(in: scale), height: height.flooredToPixel(in: scale))
    }

    /// Returns the size (in points) ceiled to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not (1.0, 2.0)).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    @MainActor
    public func ceiledToPixel(in scaleFactor: ScaleFactorProviding) -> CGSize {
        ceiledToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the size (in points) ceiled to the nearest pixel, e.g. (0.4, 1.1) @2x -> (0.5, 1.5), not (1.0, 2.0)).
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func ceiledToPixel(in scale: CGFloat) -> CGSize {
        CGSize(width: width.ceiledToPixel(in: scale), height: height.ceiledToPixel(in: scale))
    }

    /// Returns the size (in points) rounded to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not (0.0, 1.0).
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: The adjusted coordinate.
    @MainActor
    public func roundedToPixel(in scaleFactor: ScaleFactorProviding) -> CGSize {
        roundedToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the size (in points) rounded to the nearest pixel, e.g. (0.4, 0.5) @2x -> (0.5, 0.5), not (0.0, 1.0).
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: The adjusted coordinate.
    public func roundedToPixel(in scale: CGFloat) -> CGSize {
        CGSize(width: width.roundedToPixel(in: scale), height: height.roundedToPixel(in: scale))
    }

}

extension CGRect {

    /// Returns the rect, outset if necessary to align each edge to the nearest pixel at the specified scale.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosing the original rect.
    @MainActor
    public func expandedToPixel(in scaleFactor: ScaleFactorProviding) -> CGRect {
        expandedToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the rect, outset if necessary to align each edge to the nearest pixel at the specified scale.
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosing the original rect.
    public func expandedToPixel(in scale: CGFloat) -> CGRect {
        CGRect(
            left: minX.flooredToPixel(in: scale),
            top: minY.flooredToPixel(in: scale),
            right: maxX.ceiledToPixel(in: scale),
            bottom: maxY.ceiledToPixel(in: scale)
        )
    }

    /// Returns the rect, inset if necessary to align each edge to the nearest pixel at the specified scale.
    ///
    /// - parameter scaleFactor: The pixel scale to use, e.g. a UIScreen, UIView, or explicit value (pass `0` to *not*
    /// snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosed by the original rect.
    @MainActor
    public func contractedToPixel(in scaleFactor: ScaleFactorProviding) -> CGRect {
        contractedToPixel(in: scaleFactor.pixelsPerPoint)
    }

    /// Returns the rect, inset if necessary to align each edge to the nearest pixel at the specified scale.
    ///
    /// - parameter scale: The pixel scale to use (pass `0` to *not* snap to pixel).
    /// - returns: A new rect with pixel-aligned boundaries, enclosed by the original rect.
    public func contractedToPixel(in scale: CGFloat) -> CGRect {
        CGRect(
            left: minX.ceiledToPixel(in: scale),
            top: minY.ceiledToPixel(in: scale),
            right: maxX.flooredToPixel(in: scale),
            bottom: maxY.flooredToPixel(in: scale)
        )
    }

}
