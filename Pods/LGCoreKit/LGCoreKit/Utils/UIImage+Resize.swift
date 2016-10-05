//
//  UIImage+Resize.swift
//  LGCoreKit
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

extension UIImage {

    // Returns a copy of the image, resized proportionally to a max side.
    func resizedImageToMaxSide(side: CGFloat, interpolationQuality: CGInterpolationQuality) -> UIImage? {
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
        return self.resizedImageToSize(CGSizeMake(w, h), interpolationQuality: interpolationQuality)
    }

    // Returns a copy of the image, resized to a new size with certain interpolation quality.
    func resizedImageToSize(size: CGSize, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        var needsToBeTransposed = false
        if self.imageOrientation == .Left || self.imageOrientation == .LeftMirrored || self.imageOrientation == .Right || self.imageOrientation == .RightMirrored {
            needsToBeTransposed = true
        }
        return self.resizedImageToSize(size, transform: self.transformForOrientationWithSize(size), needsToBeTransposed: needsToBeTransposed, interpolationQuality: interpolationQuality)
    }

    // Returns a copy of the image, resized to match a content mode in certain bounds, with a given interpolation quality.
    func resizedImageWithContentMode(contentMode: UIViewContentMode, size: CGSize, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        let horizontalRatio = size.width / self.size.width
        let verticalRatio = size.height / self.size.height
        var finalRatio: CGFloat

        switch (contentMode) {
        case .ScaleAspectFill:
            finalRatio = max(horizontalRatio, verticalRatio)
        case .ScaleAspectFit:
            finalRatio = min(horizontalRatio, verticalRatio)
        default:
            finalRatio = 1.0
        }

        let newSize = CGSizeMake(self.size.width * finalRatio, self.size.height * finalRatio)
        return self.resizedImageToSize(newSize, interpolationQuality: interpolationQuality)
    }

    // Returns a copy of the image transformed by means of an affine transform and scaled to the new size.
    // Also, it sets the orientation to UIImageOrientation.Up.
    func resizedImageToSize(size: CGSize, transform: CGAffineTransform, needsToBeTransposed: Bool, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        // Calculate frame
        let newFrame = CGRectIntegral(CGRectMake(0, 0, size.width, size.height))

        // Generate a context for the new size
        guard let imageRef = self.CGImage, colorSpace = CGImageGetColorSpace(imageRef) else { return nil }
        guard let context = CGBitmapContextCreate(nil, Int(newFrame.size.width), Int(newFrame.size.height),
                                                  CGImageGetBitsPerComponent(imageRef), 0, colorSpace,
                                                  CGImageGetBitmapInfo(imageRef).rawValue) else { return nil }
        // Apply transform to context.
        CGContextConcatCTM(context, transform)

        // Use quality level for interpolation.
        CGContextSetInterpolationQuality(context, interpolationQuality)

        // Scale the image by drawing it in the resized context.
        CGContextDrawImage(context, needsToBeTransposed ? CGRectMake(0, 0, newFrame.size.height, newFrame.size.width) : newFrame, imageRef)

        // Return the resized image from the context.
        guard let resultCGImage = CGBitmapContextCreateImage(context) else { return nil }
        return UIImage(CGImage: resultCGImage)
    }

    // Returns a transform for correctly displaying the image given its orientation.
    func transformForOrientationWithSize(size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransformIdentity
        // modify transform depending on side orientation
        if self.imageOrientation == .Down || self.imageOrientation == .DownMirrored { // EXIF 3 & 4
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        else if self.imageOrientation == .Left || self.imageOrientation == .LeftMirrored { // EXIF 6 & 5
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        else if self.imageOrientation == .Right || self.imageOrientation == .RightMirrored { // EXIF 7 & 8
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        }

        // modify transform for mirrored orientations
        if self.imageOrientation == .UpMirrored || self.imageOrientation == .DownMirrored { // EXIF 2 & 4
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        }
        else if self.imageOrientation == .LeftMirrored || self.imageOrientation == .RightMirrored { // EXIF 5 & 7
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        }

        return transform
    }
    
    /**
    Resizes the current image and returns its data, if possible.
    
    :return: The data of the resized image, if possible.
    */
    func resizeImageData() -> NSData? {
        guard let resizedImage = self.resizedImageToMaxSide(LGCoreKitConstants.productImageMaxSide,
            interpolationQuality: .Medium) else { return nil }
        return UIImageJPEGRepresentation(resizedImage, LGCoreKitConstants.productImageJPEGQuality)
    }
}
