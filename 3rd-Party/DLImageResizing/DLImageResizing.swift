//
//  DLImageResizing.swift
//  DLImageResizing
//
//  Created by Nacho on 9/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

extension UIImage {
    
    // MARK: - Image resizing.
    
    // Returns a copy of this image, cropped to certain bounds.
    func croppedImage(bounds: CGRect) -> UIImage? {
        if let imageRef = CGImageCreateWithImageInRect(self.CGImage!, bounds) {
            let croppedImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: self.imageOrientation)
            return croppedImage
        }
        return self
    }

    // Returns a copy of this image, cropped to its center.
    func croppedCenteredImage() -> UIImage? {
        let minSize = min(self.size.width, self.size.height)
        let originX = round((self.size.width - minSize) / 2.0)
        let originY = round((self.size.height - minSize) / 2.0)
        let bounds = CGRectMake(originX, originY, minSize, minSize)
        return self.croppedImage(bounds)
    }
    
    // Returns a copy of this image, squared to thumbnail size.
    // If transparentBorder is non-zero, adds a transparent border to the image, resulting in an antialiasing when 
    // rotating the image using CoreAnimation.
    func thumbnailImageOfSize(thumbnailSize: CGFloat, transparentBorder borderSize: UInt, cornerRadius: UInt, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        // first we resize the image to a thumbnail size
        let resizedImage = self.resizedImageWithContentMode(.ScaleAspectFit, size: CGSizeMake(thumbnailSize, thumbnailSize), interpolationQuality: interpolationQuality)
        if resizedImage == nil { return nil }
        // then we crop the edges
        let croppedFrame = CGRectMake(round((resizedImage!.size.width - thumbnailSize) / 2.0), round((resizedImage!.size.height - thumbnailSize) / 2.0), thumbnailSize, thumbnailSize)
        let croppedImage = resizedImage!.croppedImage(croppedFrame)
            
        // take transparent border into account
        let finalImage = borderSize > 0 ? croppedImage?.transparentBorderedImage(borderSize) ?? croppedImage : croppedImage
        // return final image
        return finalImage?.roundedCornersImageOfSize(CGFloat(cornerRadius), borderSize: borderSize) ?? nil
    }
    
    // Returns a copy of the image, resized proportionally to a max side.
    func resizedImageToMaxSide(side: CGFloat, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        var w = self.size.width
        var h = self.size.height
        // resize to max size = kLetGoMaxProductImageSide
        
        let maxProductImageSide: CGFloat = 1024
        
        if w <= maxProductImageSide && h <= maxProductImageSide { return self }
        else if w > h { // cut width to maxProductImageSide and calculate height
            h = h * maxProductImageSide / w
            w = maxProductImageSide
        } else { // cut height to maxProductImageSide and calculate width
            w = w * maxProductImageSide / h
            h = maxProductImageSide
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
        // calculate frames and get initial CGImage
        let newFrame = CGRectIntegral(CGRectMake(0, 0, size.width, size.height))
        let imageRef = self.CGImage
        
        // Generate a context for the new size
        let context = CGBitmapContextCreate(nil, Int(newFrame.size.width), Int(newFrame.size.height), CGImageGetBitsPerComponent(imageRef!),
            0, CGImageGetColorSpace(imageRef!)!, CGImageGetBitmapInfo(imageRef!).rawValue)
        
        // Apply transform to context.
        CGContextConcatCTM(context!, transform);
        
        // Use quality level for interpolation.
        CGContextSetInterpolationQuality(context!, interpolationQuality);
        
        // Scale the image by drawing it in the resized context.
        CGContextDrawImage(context!, needsToBeTransposed ? CGRectMake(0, 0, newFrame.size.height, newFrame.size.width) : newFrame, imageRef!);
        
        // Return the resized image from the context.
        if let resultCGImage = CGBitmapContextCreateImage(context!) {
            return UIImage(CGImage: resultCGImage)
        }
        return self
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
    
    // MARK: - Rounded corners.
    
    // Returns a copy of this image, with rounded corners.
    // If transparentBorder is non-zero, adds a transparent border to the image, resulting in an antialiasing when
    // rotating the image using CoreAnimation.
    func roundedCornersImageOfSize(size: CGFloat, borderSize: UInt) -> UIImage? {
        // We need an alpha layer in the image.
        let image: UIImage! = self.imageWithAlpha()
        if image == nil { return nil }
        // Create a context
        let cgImage = image.CGImage
        if let context = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), CGImageGetBitsPerComponent(cgImage!), 0, CGImageGetColorSpace(cgImage!)!, CGImageGetBitmapInfo(cgImage!).rawValue) {
            // Create a clipping path with the rounded corners
            CGContextBeginPath(context)
            self.addRoundedRectToPath(CGRectMake(CGFloat(borderSize), CGFloat(borderSize), image.size.width - CGFloat(borderSize)*2, image.size.height - CGFloat(borderSize)*2), context: context, ovalWidth: size, ovalHeight: size)
            CGContextClosePath(context)
            CGContextClip(context)
            
            // draw the image in the clipped context
            CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), cgImage!)
            
            // create the image and return it
            if let clippedImage = CGBitmapContextCreateImage(context) {
                return UIImage(CGImage: clippedImage, scale: 1.0, orientation: self.imageOrientation)
            }
            
        }
        
        return self
    }
    
    // Creates a rounded rect to be added to a path in a drawing context
    func addRoundedRectToPath(rect: CGRect, context: CGContextRef, ovalWidth: CGFloat, ovalHeight: CGFloat) {
        // safety check: if we don't have a rect...
        if ovalWidth == 0 || ovalHeight == 0 { CGContextAddRect(context, rect); return }
    
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextScaleCTM(context, ovalWidth, ovalHeight)
        let fw = CGRectGetWidth(rect) / ovalWidth
        let fh = CGRectGetHeight(rect) / ovalHeight
        CGContextMoveToPoint(context, fw, fh/2)
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1)
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1)
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1)
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1)
        CGContextClosePath(context)
        CGContextRestoreGState(context)
    }
    
    // MARK: - Alpha layers
    
    // Returns true if the image has an alpha layer.
    internal func hasAlpha() -> Bool {
        let alpha = CGImageGetAlphaInfo(self.CGImage!)
        return (alpha == .First || alpha == .Last || alpha == .PremultipliedFirst || alpha == .PremultipliedLast)
    }
    
    // Returns a copy of the image after adding an alpha channel if needed
    func imageWithAlpha() -> UIImage? {
        if self.hasAlpha() { return nil }
        
        let cgImage = self.CGImage
        let width = CGImageGetWidth(cgImage!)
        let height = CGImageGetHeight(cgImage!)
        
        // bitsPerComponent and bitmapInfo hardcoded for avoiding an "unsupported parameter combination" error message
        let alphaInfoAsBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let context = CGBitmapContextCreate(nil, width, height, 8, 0, CGImageGetColorSpace(cgImage!)!, CGBitmapInfo.ByteOrderDefault.union(alphaInfoAsBitmapInfo).rawValue)
        
        // draw the image in the context and return it
        CGContextDrawImage(context!, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), cgImage!)
        if let cgAlphaImage = CGBitmapContextCreateImage(context!) {
            return UIImage(CGImage: cgAlphaImage, scale: 1.0, orientation: self.imageOrientation)
        }
        return self
    }
    
    // Returns a copy of the image with a transparent border of certain size. Adds an alpha layer if necessary.
    func transparentBorderedImage(borderSize: UInt) -> UIImage? {
        let image = self.imageWithAlpha()
        if image == nil { return nil }
        let newFrame = CGRectMake(0, 0, image!.size.width + CGFloat(borderSize)*2, image!.size.height + CGFloat(borderSize)*2)
        // generate the context for drawing the image
        let cgImage = image!.CGImage
        let context = CGBitmapContextCreate(nil, Int(newFrame.size.width), Int(newFrame.size.height), CGImageGetBitsPerComponent(cgImage!), 0, CGImageGetColorSpace(cgImage!)!, CGImageGetBitmapInfo(cgImage!).rawValue)
        // we'll draw the image at the center, with a space for the borders.
        let centerLocation = CGRectMake(CGFloat(borderSize), CGFloat(borderSize), image!.size.width, image!.size.height)
        CGContextDrawImage(context!, centerLocation, cgImage!)
        let borderImage = CGBitmapContextCreateImage(context!)
        
        // create the transparent border image mask
        let maskImage = self.newBorderMask(borderSize, size: newFrame.size)
        if let transparentBorderImage = CGImageCreateWithMask(borderImage!, maskImage!) {
            return UIImage(CGImage: transparentBorderImage, scale: 1.0, orientation: self.imageOrientation)
        }
        return self
    }

    // Creates and returns a mask with transparent borders and opaque center content
    // Size must include the entire mask (opaque + transparent)
    func newBorderMask(borderSize: UInt, size: CGSize) -> CGImageRef? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        // build a context for the new size
        let alphaInfoAsBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, CGBitmapInfo.ByteOrderDefault.union(alphaInfoAsBitmapInfo).rawValue)
        
        // we'll fill it initially with a transparent layer.
        CGContextSetFillColorWithColor(context!, UIColor.blackColor().CGColor)
        CGContextFillRect(context!, CGRectMake(0, 0, size.width, size.height))
        
        // now the inner opaque part.
        CGContextSetFillColorWithColor(context!, UIColor.whiteColor().CGColor)
        CGContextFillRect(context!, CGRectMake(CGFloat(borderSize), CGFloat(borderSize), size.width - CGFloat(borderSize) * 2, size.height - CGFloat(borderSize) * 2))
        
        // return the image from the context
        return CGBitmapContextCreateImage(context!)
    }

}
