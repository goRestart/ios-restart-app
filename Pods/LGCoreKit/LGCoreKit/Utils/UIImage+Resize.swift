//
//  UIImage+Resize.swift
//  LGCoreKit
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

extension UIImage {

    // Returns a copy of the image, resized proportionally to a max side.
    func resizedImageToMaxSide(_ side: CGFloat, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        var w = self.size.width
        var h = self.size.height

        // resize to max size = kLetGoMaxProductImageSide
        if w <= side && h <= side {
            return self
        }
        else if w > h { // cut width to side and calculate height
            h = h * side / w
            w = side
        }
        else { // cut height to side and calculate width
            w = w * side / h
            h = side
        }
        return self.resizedImageToSize(CGSize(width: w, height: h), interpolationQuality: interpolationQuality)
    }

    // Returns a copy of the image, resized to a new size with certain interpolation quality.
    func resizedImageToSize(_ size: CGSize, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        var needsToBeTransposed = false
        if self.imageOrientation == .left || self.imageOrientation == .leftMirrored || self.imageOrientation == .right || self.imageOrientation == .rightMirrored {
            needsToBeTransposed = true
        }
        return self.resizedImageToSize(size, transform: self.transformForOrientationWithSize(size), needsToBeTransposed: needsToBeTransposed, interpolationQuality: interpolationQuality)
    }

    // Returns a copy of the image, resized to match a content mode in certain bounds, with a given interpolation quality.
    func resizedImageWithContentMode(_ contentMode: UIViewContentMode, size: CGSize, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        let horizontalRatio = size.width / self.size.width
        let verticalRatio = size.height / self.size.height
        var finalRatio: CGFloat

        switch (contentMode) {
        case .scaleAspectFill:
            finalRatio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            finalRatio = min(horizontalRatio, verticalRatio)
        default:
            finalRatio = 1.0
        }

        let newSize = CGSize(width: self.size.width * finalRatio, height: self.size.height * finalRatio)
        return self.resizedImageToSize(newSize, interpolationQuality: interpolationQuality)
    }

    // Returns a copy of the image transformed by means of an affine transform and scaled to the new size.
    // Also, it sets the orientation to UIImageOrientation.Up.
    func resizedImageToSize(_ size: CGSize, transform: CGAffineTransform, needsToBeTransposed: Bool, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        // Calculate frame
        let newFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height).integral

        // Generate a context for the new size
        guard let imageRef = self.cgImage, let colorSpace = imageRef.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: Int(newFrame.size.width), height: Int(newFrame.size.height),
                                                  bitsPerComponent: imageRef.bitsPerComponent, bytesPerRow: 0, space: colorSpace,
                                                  bitmapInfo: imageRef.bitmapInfo.rawValue) else { return nil }
        // Apply transform to context.
        context.concatenate(transform)

        // Use quality level for interpolation.
        context.interpolationQuality = interpolationQuality

        // Scale the image by drawing it in the resized context.
        context.draw(imageRef, in: needsToBeTransposed ? CGRect(x: 0, y: 0, width: newFrame.size.height, height: newFrame.size.width) : newFrame)

        // Return the resized image from the context.
        guard let resultCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: resultCGImage)
    }

    // Returns a transform for correctly displaying the image given its orientation.
    func transformForOrientationWithSize(_ size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        // modify transform depending on side orientation
        if self.imageOrientation == .down || self.imageOrientation == .downMirrored { // EXIF 3 & 4
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        }
        else if self.imageOrientation == .left || self.imageOrientation == .leftMirrored { // EXIF 6 & 5
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        }
        else if self.imageOrientation == .right || self.imageOrientation == .rightMirrored { // EXIF 7 & 8
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
        }

        // modify transform for mirrored orientations
        if self.imageOrientation == .upMirrored || self.imageOrientation == .downMirrored { // EXIF 2 & 4
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        else if self.imageOrientation == .leftMirrored || self.imageOrientation == .rightMirrored { // EXIF 5 & 7
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        return transform
    }
    
    /**
    Resizes the current image and returns its data, if possible.
    
    :return: The data of the resized image, if possible.
    */
    func resizeImageData() -> Data? {
        guard let resizedImage = self.resizedImageToMaxSide(LGCoreKitConstants.productImageMaxSide,
            interpolationQuality: .medium) else { return nil }
        return UIImageJPEGRepresentation(resizedImage, LGCoreKitConstants.productImageJPEGQuality)
    }
}
